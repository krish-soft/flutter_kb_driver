import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver_status_controller.dart';
import 'package:kb_driver/core/data/presentation/controllers/user/dashboard_controller.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.put(DashboardController());
  final DriverStatusController statusController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Dashboard"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// WELCOME
            const Text(
              "Welcome back",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            const Text(
              "Here is your delivery overview",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// STATUS
            _statusCard(),

            const SizedBox(height: 20),

            /// DELIVERIES FIRST
            _deliveriesCard(),

            const SizedBox(height: 16),

            /// RATINGS
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Rating",
                    controller.averageRating.value.toStringAsFixed(1),
                    Icons.star,
                    Colors.orange,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    "Reviews",
                    controller.totalRatings.value.toString(),
                    Icons.rate_review,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// EARNINGS
            _earningsCard(),

            const SizedBox(height: 40),
          ],
        );
      }),
    );
  }

  /// STATUS CARD WITH RIPPLE
  Widget _statusCard() {
    return Obx(() {
      bool online = statusController.isOnline.value;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: online
                ? [const Color(0xff22c55e), const Color(0xff16a34a)]
                : [const Color(0xff9ca3af), const Color(0xff6b7280)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            RippleDot(color: Colors.white),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? "Online" : "Offline",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  online
                      ? "Ready to receive delivery requests"
                      : "Switch online to receive deliveries",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// DELIVERIES BIG CARD
  Widget _deliveriesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.local_shipping, size: 36, color: Colors.blue),

          const SizedBox(height: 10),

          Text(
            controller.totalDeliveries.value.toString(),
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          const Text("Total Deliveries", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// SMALL STAT CARD
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// EARNINGS CARD
  Widget _earningsCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Available Earnings",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 6),

            Text(
              "₹ ${controller.availableBalance.value.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Pending Settlement ₹${controller.pendingBalance.value.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    });
  }
}

/// RIPPLE DOT ANIMATION
class RippleDot extends StatefulWidget {
  final Color color;

  const RippleDot({super.key, required this.color});

  @override
  State<RippleDot> createState() => _RippleDotState();
}

class _RippleDotState extends State<RippleDot>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              double scale = 1 + controller.value;
              double opacity = 1 - controller.value;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(opacity * 0.4),
                  ),
                ),
              );
            },
          ),

          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
