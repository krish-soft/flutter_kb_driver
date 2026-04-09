import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver_status_controller.dart';
import 'package:kb_driver/core/data/presentation/controllers/user/dashboard_controller.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
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
      appBar: CommonAppBar(title: AppStrings.textDashboard.tr),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.getDashboardData();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// WELCOME
              Text(
                AppStrings.textWelcomeBack.tr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                AppStrings.textDeliveryOverview.tr,
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// STATUS
              _statusCard(),

              const SizedBox(height: 20),

              /// EARNINGS (MOVED UP)
              _earningsCard(),

              const SizedBox(height: 20),

              /// DELIVERY STATS
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      AppStrings.textRequestedDeliveries.tr,
                      controller.requestedDeliveries.value.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _statCard(
                      AppStrings.textActiveDeliveries.tr,
                      controller.activeDeliveries.value.toString(),
                      Icons.local_shipping,
                      Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _statCard(
                      AppStrings.textTotalDeliveries.tr,
                      controller.totalDeliveries.value.toString(),
                      Icons.inventory,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// SMALL RATING CARD
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(width: 120, child: _ratingCard()),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  /// STATUS CARD
  Widget _statusCard() {
    return Obx(() {
      bool online = statusController.isOnline.value;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: online
                ? [const Color(0xff22c55e), const Color(0xff16a34a)]
                : [
                    const Color.fromARGB(255, 239, 26, 26),
                    const Color.fromARGB(255, 242, 109, 109),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.circle, color: Colors.white, size: 10),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? AppStrings.textOnline.tr : AppStrings.textOffline.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  online
                      ? AppStrings.textReadyToReceiveDeliveryRequests.tr
                      : AppStrings.textSwitchOnlineToReceiveDeliveries.tr,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// DELIVERY STAT CARD
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  /// SMALL RATING CARD
  Widget _ratingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.star, color: Colors.purple, size: 20),

          const SizedBox(height: 4),

          Text(
            controller.averageRating.value.toStringAsFixed(1),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          Text(
            AppStrings.textRating.tr,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  LinearGradient _balanceGradient(double balance) {
    if (balance > 0) {
      return const LinearGradient(
        colors: [Color(0xff22c55e), Color(0xff16a34a)],
      );
    } else if (balance < 0) {
      return const LinearGradient(
        colors: [Color(0xffef4444), Color(0xffb91c1c)],
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xff6b7280), Color(0xff374151)],
      );
    }
  }

  /// EARNINGS CARD
  Widget _earningsCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: _balanceGradient(controller.availableBalance.value),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.textAvailableEarnings.tr,
              style: const TextStyle(color: Colors.white70),
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
              "${AppStrings.textPendingSettlement.tr} ₹${controller.pendingBalance.value.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    });
  }
}
