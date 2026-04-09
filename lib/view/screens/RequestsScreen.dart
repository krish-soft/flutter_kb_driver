import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/shipment_controller.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late ShipmentController controller;

  final VibrateManager _vibrateManager = VibrateManager();

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
        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadRequestedShipments();
          },

          child: controller.isLoading.value
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                )
              /// EMPTY LIST
              : controller.shipments.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Text(
                          AppStrings.textNoRequests.tr,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              /// DATA LIST
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                    color: AppColors.tripAssigned.withOpacity(
                                      .15,
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// PICKUP
                                      Text(
                                        origin != null
                                            ? "${origin["line1"] ?? ""}, ${origin["village"] ?? ""}, ${origin["city"] ?? ""}"
                                            : "Origin not provided",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      /// DROP
                                      Text(
                                        destination != null
                                            ? "${destination["line1"] ?? ""}, ${destination["village"] ?? ""}, ${destination["city"] ?? ""}"
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

                            const SizedBox(height: 20),

                            /// ACTION BUTTONS
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    title: AppStrings.textReject.tr,
                                    background: AppColors.danger,
                                    onPressed: () {
                                      _vibrateManager.vibrateMedium();
                                      controller.rejectShipment(
                                        shipment["driver_shipment_id"],
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: AppButton(
                                    title: AppStrings.textAccept.tr,
                                    background: AppColors.primary,
                                    onPressed: () {
                                      _vibrateManager.vibrateMedium();
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
                ),
        );
      }),
    );
  }
}
