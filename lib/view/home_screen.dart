import 'package:flutter/material.dart';
import 'package:kb_driver/view/bottom/ActiveDeliveryScreen.dart';
import 'package:kb_driver/view/bottom/DashboardScreen.dart';
import 'package:kb_driver/view/bottom/MoreScreen.dart';
import 'package:kb_driver/view/bottom/RequestsScreen.dart';
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
        title: Text(_isOnline ? "Go Offline?" : "Go Online?"),
        content: Text(
          _isOnline
              ? "You will stop receiving delivery requests."
              : "You will start receiving delivery requests.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
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
        margin: const EdgeInsets.only(bottom: 6),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          elevation: 10,
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
          elevation: 0,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.dashboard_customize, "Dashboard", 0),

                _navItem(Icons.assignment_outlined, "Requests", 1),

                const SizedBox(width: 40),

                _navItem(Icons.two_wheeler, "Active", 2),

                _navItem(Icons.menu, "More", 3),
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
