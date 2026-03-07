import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/shipment_controller.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late ShipmentController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(ShipmentController());
    controller.loadRequestedShipments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: AppStrings.screenRequests.tr),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.shipments.isEmpty) {
          return Center(
            child: Text(
              "No shipment requests",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.shipments.length,
          itemBuilder: (context, index) {
            final shipment = controller.shipments[index];
            final origin = shipment["origin"];
            final destination = shipment["destination"];
            final payable = shipment["shipment_payable"];

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          shipment["shipment_number"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tripAssigned.withOpacity(.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "REQUESTED",
                            style: TextStyle(
                              color: AppColors.tripAssigned,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// ROUTE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 10,
                              color: AppColors.success,
                            ),
                            Container(
                              width: 2,
                              height: 32,
                              color: AppColors.divider,
                            ),
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.danger,
                            ),
                          ],
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// PICKUP
                              Text(
                                "${origin["line1"]}, ${origin["city"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// DROP
                              Text(
                                destination != null
                                    ? "${destination["line1"]}, ${destination["city"]}"
                                    : "Destination not provided",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// PACKAGE INFO
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "${shipment["total_packages"]} Packages",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// EARNINGS BOX
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            color: AppColors.success,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            "You Earn ₹${payable["final_payable_amount"]}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ACTION BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            title: "Reject",
                            background: AppColors.danger,
                            onPressed: () {
                              controller.rejectShipment(
                                shipment["driver_shipment_id"],
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: AppButton(
                            title: "Accept",
                            background: AppColors.primary,
                            onPressed: () {
                              controller.acceptShipment(
                                shipment["driver_shipment_id"],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
