import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/driver_controller.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver_status_controller.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/core/services/driver_background_service.dart';
import 'package:kb_driver/core/services/driver_service.dart';
import 'package:kb_driver/core/services/permission_service.dart';
import 'package:kb_driver/utils/preference_manager.dart';
import 'package:kb_driver/view/screens/ActiveDeliveryScreen.dart';
import 'package:kb_driver/view/screens/DashboardScreen.dart';
import 'package:kb_driver/view/screens/MoreScreen.dart';
import 'package:kb_driver/view/screens/RequestsScreen.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = false;

  bool _hasRequest = false;
  int _numberOfRequests = 0;
  bool _hasActiveDelivery = false;

  final VibrateManager _vibrateManager = VibrateManager();
  final DriverController _driverController = Get.put(DriverController());
  final DriverStatusController _driverStatusController =
      Get.find<DriverStatusController>();

  final List<Widget> _screens = const [
    DashboardScreen(),
    RequestsScreen(),
    ActiveDeliveryScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _init();
    _listenForNewShipments();
  }

  Future<void> _init() async {
    await _checkPermissions();
    await _restoreDriverState();
  }

  Future<void> _checkPermissions() async {
    await PermissionService.requestRequiredPermissions();
  }

  /// RESTORE DRIVER STATUS
  /// RESTORE DRIVER STATUS
  Future<void> _restoreDriverState() async {
    bool localStatus = PreferenceManager.getIsDriverOnline();

    if (!mounted) return;

    setState(() {
      _isOnline = localStatus;
    });

    /// Start services if locally online
    if (_isOnline) {
      if (!DriverService.isRunning()) {
        _startDriverService();
      }

      await DriverBackgroundService.startService();
    } else {
      /// ensure stopped if local says offline
      _stopDriverService();
      await DriverBackgroundService.stopService();
    }

    /// verify with server if local says offline
    if (!localStatus) {
      final res = await _driverController.getDriverOnlineStatus();

      if (res.isSuccess == true) {
        bool serverStatus = res.data?['isOnline'] ?? false;

        if (!mounted) return;

        setState(() {
          _isOnline = serverStatus;
        });

        _driverStatusController.updateStatus(serverStatus);

        if (serverStatus) {
          if (!DriverService.isRunning()) {
            _startDriverService();
          }

          await DriverBackgroundService.startService();
        } else {
          _stopDriverService();
          await DriverBackgroundService.stopService();
        }
      }
      //
    }
  }

  /// START DRIVER SERVICE
  void _startDriverService() {
    // if (DriverService.isRunning()) return;

    // DriverService.startService(() async {
    //   print("Driver service running...");

    //   /// CHECK NEW REQUEST
    //   // final req = await _driverController.checkForNewRequests();

    //   // /// CHECK ACTIVE DELIVERY
    //   // final active = await _driverController.getActiveDelivery();

    //   if (!mounted) return;

    //   // setState(() {
    //   //   _hasRequest = req.hasRequest;
    //   //   _hasActiveDelivery = active != null;
    //   // });
    // });
  }

  void _stopDriverService() {
    if (DriverService.isRunning()) {
      DriverService.stopService();
    }
  }

  void _listenForNewShipments() {
    FlutterBackgroundService().on("newShipment").listen((event) {
      final data = event?["data"];

      if (data['has_requested_shipments'] == true) {
        if (!mounted) return;

        setState(() {
          _hasRequest = true;
          _numberOfRequests = data['number_of_requested_shipments'] ?? 0;
        });
      }
    });
  }

  /// TOGGLE ONLINE / OFFLINE
  Future<void> _toggleDriverStatus() async {
    await _vibrateManager.vibrateMedium();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          _isOnline ? AppStrings.textGoOffline.tr : AppStrings.textGetOnline.tr,
        ),
        content: Text(
          _isOnline
              ? AppStrings.textMessageOffline.tr
              : AppStrings.textMessageOnline.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.textCancel.tr),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.textConfirm.tr),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await _driverController.updateDriverOnlineStatus(!_isOnline);

    if (res.isSuccess == true) {
      bool newStatus = !_isOnline;

      if (!mounted) return;

      setState(() {
        _isOnline = newStatus;
      });

      // await PreferenceManager.setIsDriverOnline(newStatus);
      _driverStatusController.updateStatus(newStatus);

      if (newStatus) {
        _startDriverService();
        await DriverBackgroundService.startService();
      } else {
        _stopDriverService();
        await DriverBackgroundService.stopService();
      }
    }
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _screens[_currentIndex],
      ),

      /// FAB
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          elevation: 12,
          backgroundColor: _isOnline ? Colors.green : Colors.red,
          onPressed: _toggleDriverStatus,
          child: Icon(
            _isOnline ? Icons.drive_eta : Icons.no_transfer,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Bottom Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 12,
          elevation: 6,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  Icons.dashboard_customize,
                  AppStrings.screenDashboard.tr,
                  0,
                ),

                _navItem(
                  Icons.assignment_outlined,
                  AppStrings.screenRequests.tr,
                  1,
                  showBadge: _hasRequest,
                  badgeCount: _numberOfRequests,
                ),

                const SizedBox(width: 40),

                _navItem(
                  Icons.local_shipping_outlined,
                  AppStrings.screenActiveDelivery.tr,
                  2,
                  showBadge: _hasActiveDelivery,
                ),

                _navItem(Icons.menu, AppStrings.screenMore.tr, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// NAV ITEM WITH BADGE
  ///
  Widget _navItem(
    IconData icon,
    String label,
    int index, {
    bool showBadge = false,
    int? badgeCount, // optional count
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () async {
        await _vibrateManager.vibrateButton();

        setState(() {
          _currentIndex = index;

          if (index == 1) _hasRequest = false;
          if (index == 2) _hasActiveDelivery = false;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected ? Colors.green : Colors.grey,
              ),

              if (showBadge)
                Positioned(
                  right: -4,
                  top: -2,
                  child: Container(
                    padding: badgeCount != null
                        ? const EdgeInsets.symmetric(horizontal: 5, vertical: 2)
                        : EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: badgeCount != null
                        ? Text(
                            badgeCount > 99 ? '99+' : badgeCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  // Widget _navItem(
  //   IconData icon,
  //   String label,
  //   int index, {
  //   bool showBadge = false,
  // }) {
  //   final isSelected = _currentIndex == index;

  //   return GestureDetector(
  //     onTap: () async {
  //       await _vibrateManager.vibrateButton();

  //       setState(() {
  //         _currentIndex = index;

  //         if (index == 1) _hasRequest = false;
  //         if (index == 2) _hasActiveDelivery = false;
  //       });
  //     },
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Stack(
  //           children: [
  //             Icon(
  //               icon,
  //               size: 26,
  //               color: isSelected ? Colors.green : Colors.grey,
  //             ),

  //             if (showBadge)
  //               Positioned(
  //                 right: 0,
  //                 top: 0,
  //                 child: Container(
  //                   width: 10,
  //                   height: 10,
  //                   decoration: const BoxDecoration(
  //                     color: Colors.red,
  //                     shape: BoxShape.circle,
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),

  //         const SizedBox(height: 4),

  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 12,
  //             fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
  //             color: isSelected ? Colors.green : Colors.grey,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
