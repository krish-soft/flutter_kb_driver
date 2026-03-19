import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/shipment_controller.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';
import 'package:kb_driver/view/components/common_chip.dart';
import 'package:kb_driver/view/screens/delivery/ActiveDeliveryDetailScreen.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  final ShipmentController controller = Get.put(ShipmentController());

  final VibrateManager _vibrateManager = VibrateManager();

  @override
  void initState() {
    super.initState();
    controller.loadNeedToDeliverShipments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: AppStrings.screenActiveDelivery.tr),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activeShipments.isEmpty) {
          return Center(child: Text(AppStrings.textNoShipments.tr));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activeShipments.length,

          itemBuilder: (context, index) {
            final shipment = controller.activeShipments[index];
            final origin = shipment["origin"];
            final destination = shipment["destination"];

            return GestureDetector(
              onTap: () {
                _vibrateManager.vibrateButton();
                Get.to(() => ActiveDeliveryDetailScreen(shipment: shipment));
              },

              child: Container(
                margin: const EdgeInsets.only(bottom: 16),

                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 4),
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

                          CommonChip(text: shipment["shipment_status"]),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 10,
                          //     vertical: 4,
                          //   ),

                          //   decoration: BoxDecoration(
                          //     color: AppColors.tripAssigned.withOpacity(.15),
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),

                          //   child: Text(
                          //     shipment["shipment_status"],
                          //     style: const TextStyle(
                          //       color: AppColors.tripAssigned,
                          //       fontSize: 12,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                      if (shipment["shipment_status"]
                              .toString()
                              .toLowerCase() !=
                          "completed") ...[
                        const SizedBox(height: 14),

                        /// ROUTE VISUAL
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
                                  height: 30,
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
                                    "${origin["line1"]}, ${origin["village"] ?? ''}, ${origin["city"] ?? ''}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  /// DELIVERY
                                  Text(
                                    "${destination["line1"] ?? ''}, ${destination["village"] ?? ''}, ${destination["city"] ?? ''}",
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
                      ],
                      const SizedBox(height: 16),

                      /// FOOTER INFO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// TYPE
                          CommonChip(
                            text: shipment["shipment_type"].toUpperCase(),
                            isType: true,
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 10,
                          //     vertical: 6,
                          //   ),

                          //   decoration: BoxDecoration(
                          //     color: AppColors.tripPickup.withOpacity(.15),
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),

                          //   child: Text(
                          //     shipment["shipment_type"].toUpperCase(),
                          //     style: const TextStyle(
                          //       color: AppColors.tripPickup,
                          //       fontWeight: FontWeight.w600,
                          //       fontSize: 12,
                          //     ),
                          //   ),
                          // ),

                          /// PACKAGES
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory_2,
                                size: 18,
                                color: AppColors.primary,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                "${shipment["total_packages"]} Packages",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
