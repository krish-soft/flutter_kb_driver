import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
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

  final VibrateManager _vibrateManager = VibrateManager();

  final List<Widget> _screens = const [
    DashboardScreen(),
    RequestsScreen(),
    ActiveDeliveryScreen(),
    MoreScreen(),
  ];

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _toggleDriverStatus() async {
    _vibrateManager.vibrateMedium();

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

    if (confirm == true) {
      setState(() {
        _isOnline = !_isOnline;
      });
    }
  }

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
                ),

                const SizedBox(width: 40),

                _navItem(
                  Icons.two_wheeler,
                  AppStrings.screenActiveDelivery.tr,
                  2,
                ),

                _navItem(Icons.menu, AppStrings.screenMore.tr, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () async {
        _vibrateManager.vibrateButton();

        setState(() {
          _currentIndex = index;
        });
      },

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: isSelected ? Colors.green : Colors.grey),

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
}
