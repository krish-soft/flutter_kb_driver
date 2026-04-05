import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/utils/message_manager.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/shipment_controller.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/view/components/common_chip.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';
import 'package:kb_driver/view/screens/delivery/ShipmentPackagesScreen.dart';

class ActiveDeliveryDetailScreen extends StatelessWidget {
  final dynamic shipment;

  ActiveDeliveryDetailScreen({super.key, required this.shipment});

  final ShipmentController controller = Get.find<ShipmentController>();
  final VibrateManager _vibratorManager = VibrateManager();

  /// Enable OTP validation (optional)
  // final bool otpEnabled = false;

  /// Open Google Maps
  void openDirection(String? lat, String? lng) async {
    if (lat == null || lng == null) return;

    final url = "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng";

    await launchUrl(Uri.parse(url));
  }

  /// Capture delivery photo
  Future<String?> capturePhoto() async {
    final picker = ImagePicker();

    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );

    return file?.path;
  }

  /// Build address string
  String buildAddress(dynamic addr) {
    return [
      addr["addr_name"],
      addr["line1"],
      addr["line2"],
      addr["village"],
      addr["city"],
      addr["state"],
      addr["postal_code"],
    ].where((e) => e != null && e.toString().isNotEmpty).join(", ");
  }

  /// DELIVERY CONFIRMATION SHEET
  void openDeliveryConfirmSheet(bool otpEnabled) {
    final TextEditingController otpController = TextEditingController();
    final TextEditingController requestIdController = TextEditingController();

    requestDeliveryConfirmOtp() async {
      ApiResponseModel res = await controller.requestDeliveryConfirmationOtp(
        shipment["driver_shipment_id"],
      );

      if (res.isSuccess == true) {
        requestIdController.text = res.data["request_id"];
      } else {}
    }

    String? imagePath;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setStateSheet) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.textCompleteDelivery.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// PHOTO PREVIEW
                if (imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(imagePath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 10),

                /// TAKE PHOTO
                AppButton(
                  title: AppStrings.textCapturePhoto.tr,
                  background: AppColors.info,
                  onPressed: () async {
                    final path = await capturePhoto();

                    if (path != null) {
                      setStateSheet(() {
                        imagePath = path;
                      });
                    }
                  },
                ),

                const SizedBox(height: 15),

                /// OTP FIELD (OPTIONAL)
                if (otpEnabled)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          /// OTP INPUT
                          Expanded(
                            child: TextField(
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppStrings.textEnterOtp.tr,
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// REQUEST OTP BUTTON
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: requestDeliveryConfirmOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              child: Text(
                                AppStrings.textRequestOtp.tr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        AppStrings.textAskReceiverOtp.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                /// CONFIRM BUTTON
                AppButton(
                  title: AppStrings.textConfirmDelivery.tr,
                  background: AppColors.success,
                  onPressed: () async {
                    _vibratorManager.vibrateButton();
                    if (imagePath == null) {
                      // Get.snackbar("Error", AppStrings.textPhotoRequired.tr);
                      MessageManager.showError(AppStrings.textPhotoRequired.tr);
                      return;
                    }

                    if (otpEnabled && otpController.text.isEmpty) {
                      // Get.snackbar("Error", AppStrings.textOtpRequired.tr);
                      MessageManager.showError(AppStrings.textOtpRequired.tr);
                      return;
                    }

                    // Get.back();

                    final ApiResponseModel res = await controller
                        .completeShipment(
                          shipment["driver_shipment_id"],
                          imagePath!,
                          otpEnabled ? otpController.text.trim() : null,
                          otpEnabled ? requestIdController.text.trim() : null,
                        );

                    /// Refresh shipment list
                    // controller.loadNeedToDeliverShipments();
                    if (res.isSuccess == true) {
                      Get.back(); // close bottom sheet

                      controller.loadNeedToDeliverShipments();

                      Get.back(); // go back screen ONLY on success
                    } else {
                      MessageManager.showError(res.message.toString());
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      /// ✅ GET UPDATED SHIPMENT FROM CONTROLLER
      final updatedShipment = controller.activeShipments.firstWhere(
        (e) => e["driver_shipment_id"] == shipment["driver_shipment_id"],
        orElse: () => shipment,
      );

      // final bool otpEnabled =
      //     updatedShipment["shipment_type"]?.toString().toLowerCase() ==
      //     "dispatch";

      final bool otpEnabled =
          updatedShipment['is_delivery_confirmation_otp_required'];

      final origin = updatedShipment["origin"];
      final destination = updatedShipment["destination"];
      final payable = updatedShipment["shipment_payable"];

      final status = updatedShipment["driver_shipment_status"]
          .toString()
          .toLowerCase();

      final bool canStart = status == "pending" || status == "accepted";
      final bool canComplete = status == "in_transit";
      final bool delivered = status == "delivered" || status == "completed";

      return Scaffold(
        backgroundColor: AppColors.background,

        appBar: CommonAppBar(
          title: updatedShipment["shipment_number"],
          showBack: true,
        ),

        body: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            /// Shipment Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 5),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    updatedShipment["shipment_number"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      CommonChip(
                        text: updatedShipment["shipment_type"],
                        isType: true,
                      ),
                      const SizedBox(width: 8),
                      CommonChip(
                        text: updatedShipment["driver_shipment_status"],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Hide address when delivered
            if (!delivered) ...[
              _addressCard(
                title: AppStrings.textPickupAddress.tr,
                icon: Icons.store,
                color: AppColors.primary,
                address: buildAddress(origin),
                lat: origin["lat"],
                lng: origin["lng"],
              ),

              const SizedBox(height: 12),
              ...[
                destination != null
                    ? _addressCard(
                        title: AppStrings.textDeliveryAddress.tr,
                        icon: Icons.home,
                        color: AppColors.success,
                        address: buildAddress(destination),
                        lat: destination["lat"],
                        lng: destination["lng"],
                      )
                    : Text('No Destination Address Provided'),
              ],

              const SizedBox(height: 16),
            ],

            /// Shipment Information
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: AppColors.white,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         AppStrings.textShipmentInformation.tr,
            //         style: const TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 16,
            //         ),
            //       ),

            //       const SizedBox(height: 10),

            //       _infoRow(
            //         AppStrings.textTotalPackages.tr,
            //         "${updatedShipment["total_packages"]}",
            //       ),

            //       _infoRow(
            //         AppStrings.textTotalWeight.tr,
            //         "${payable["total_weight"]} kg",
            //       ),

            //       _infoRow(
            //         AppStrings.textTotalQuantity.tr,
            //         "${payable["total_quantity"]}",
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 16),
            _shipmentPackagesSummaryBlock(updatedShipment),

            const SizedBox(height: 16),

            /// View Packages
            AppButton(
              title: AppStrings.textViewPackages.tr,
              background: AppColors.info,
              onPressed: () {
                _vibratorManager.vibrateButton();
                Get.to(() => ShipmentPackagesScreen(shipment: updatedShipment));
              },
            ),

            const SizedBox(height: 20),

            /// Start Delivery
            AppButton(
              title: AppStrings.textStartDelivery.tr,
              background: canStart ? AppColors.success : AppColors.textDisabled,
              onPressed: canStart
                  ? () {
                      _vibratorManager.vibrateButton();
                      controller.startShipment(
                        updatedShipment["driver_shipment_id"],
                      );
                    }
                  : null,
            ),

            const SizedBox(height: 12),

            /// Complete Delivery
            AppButton(
              title: AppStrings.textCompleteDelivery.tr,
              background: canComplete
                  ? AppColors.danger
                  : AppColors.textDisabled,
              onPressed: canComplete
                  ? () {
                      _vibratorManager.vibrateButton();
                      openDeliveryConfirmSheet(otpEnabled);
                    }
                  : null,
            ),
          ],
        ),
      );
    });
  }

  Widget _shipmentPackagesSummaryBlock(dynamic shipment) {
    final List summary =
        (shipment?["shipment_packages_summary"] as List?) ?? [];

    if (summary.isEmpty) {
      return const SizedBox();
    }

    num safeNum(dynamic v) {
      if (v == null) return 0;
      if (v is int || v is double) return v;
      return num.tryParse(v.toString()) ?? 0;
    }

    /// OVERALL TOTALS
    num totalPackages = 0;
    Map<String, num> unitTotals = {};

    for (final item in summary) {
      final packSize = safeNum(item["pack_size"]);
      final qty = safeNum(item["total_packages"]);
      final unit = item["pack_unit"] ?? "";

      final total = packSize * qty;

      totalPackages += qty;

      unitTotals[unit] = (unitTotals[unit] ?? 0) + total;
    }

    String totalWeightText = unitTotals.entries
        .map((e) => "${e.value} ${e.key}")
        .join(" + ");

    /// STATUS TOTALS
    Map<String, num> statusPackages = {};
    Map<String, Map<String, num>> statusUnits = {};

    for (final item in summary) {
      final packSize = safeNum(item["pack_size"]);
      final unit = item["pack_unit"] ?? "";
      final statusMap = (item["status_summary"] as Map?) ?? {};

      statusMap.forEach((status, qtyValue) {
        final qty = safeNum(qtyValue);

        statusPackages[status] = (statusPackages[status] ?? 0) + qty;

        statusUnits.putIfAbsent(status, () => {});

        final weight = packSize * qty;

        statusUnits[status]![unit] = (statusUnits[status]![unit] ?? 0) + weight;
      });
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// BLOCK TITLE
            const Text(
              "Shipment Packages Summary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: "Overall"),
                Tab(text: "Status"),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 220,
              child: TabBarView(
                children: [
                  /// OVERALL TAB
                  Scrollbar(
                    child: ListView(
                      children: [
                        ...summary.map((item) {
                          final productName = item["product_name"] ?? "-";
                          final packType = item["pack_type_unit"] ?? "-";

                          final packSize = safeNum(item["pack_size"]);
                          final qty = safeNum(item["total_packages"]);
                          final unit = item["pack_unit"] ?? "";

                          final total = packSize * qty;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "$qty $packType × ${packSize}$unit",
                                  ),
                                ),

                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "$total $unit",
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        Divider(color: Colors.grey.shade300),

                        /// TOTAL ROW
                        Row(
                          children: [
                            const Expanded(
                              flex: 4,
                              child: Text(
                                "TOTAL",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            Expanded(
                              flex: 4,
                              child: Text(
                                "$totalPackages Packages",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                totalWeightText,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// STATUS TAB
                  Scrollbar(
                    child: ListView(
                      children: statusPackages.entries.map((entry) {
                        final status = entry.key;
                        final pkgCount = entry.value;

                        final unitMap = statusUnits[status] ?? {};

                        final weightText = unitMap.entries
                            .map((e) => "${e.value} ${e.key}")
                            .join(" + ");

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 4,
                                child: Text("$pkgCount Packages"),
                              ),

                              Expanded(
                                flex: 2,
                                child: Text(
                                  weightText,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Widget _shipmentPackagesSummaryBlock(dynamic shipment) {
  //   final List summary =
  //       (shipment?["shipment_packages_summary"] as List?) ?? [];

  //   if (summary.isEmpty) {
  //     return const SizedBox();
  //   }

  //   num safeNum(dynamic v) {
  //     if (v == null) return 0;
  //     if (v is int || v is double) return v;
  //     return num.tryParse(v.toString()) ?? 0;
  //   }

  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: AppColors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         /// TITLE
  //         const Text(
  //           "Product Summary",
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //         ),

  //         const SizedBox(height: 12),

  //         /// SCROLL AREA
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           child: SizedBox(
  //             width: 430,
  //             child: Column(
  //               children: [
  //                 /// HEADER
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(vertical: 8),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.shade100,
  //                     borderRadius: BorderRadius.circular(6),
  //                   ),
  //                   child: const Row(
  //                     children: [
  //                       SizedBox(
  //                         width: 150,
  //                         child: Text(
  //                           "Product",
  //                           style: TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                       ),

  //                       SizedBox(
  //                         width: 80,
  //                         child: Text(
  //                           "Type",
  //                           style: TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                       ),

  //                       SizedBox(
  //                         width: 60,
  //                         child: Text(
  //                           "Size",
  //                           style: TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                       ),

  //                       SizedBox(
  //                         width: 60,
  //                         child: Text(
  //                           "Qty",
  //                           style: TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                       ),

  //                       SizedBox(
  //                         width: 80,
  //                         child: Text(
  //                           "Total",
  //                           style: TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 const SizedBox(height: 6),

  //                 /// ROWS
  //                 ...summary.map((item) {
  //                   final productName = item?["product_name"] ?? "-";
  //                   final packType = item?["pack_type_unit"] ?? "-";

  //                   final packSize = safeNum(item?["pack_size"]);
  //                   final qty = safeNum(item?["total_packages"]);

  //                   final packUnit = item?["pack_unit"] ?? "";

  //                   final total = packSize * qty;

  //                   return Container(
  //                     padding: const EdgeInsets.symmetric(vertical: 10),
  //                     decoration: BoxDecoration(
  //                       border: Border(
  //                         bottom: BorderSide(color: Colors.grey.shade200),
  //                       ),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         SizedBox(
  //                           width: 150,
  //                           child: Text(
  //                             productName,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                         ),

  //                         SizedBox(width: 80, child: Text(packType)),

  //                         SizedBox(width: 60, child: Text(packSize.toString())),

  //                         SizedBox(
  //                           width: 60,
  //                           child: Container(
  //                             alignment: Alignment.center,
  //                             padding: const EdgeInsets.symmetric(vertical: 4),
  //                             decoration: BoxDecoration(
  //                               color: Colors.blue.shade50,
  //                               borderRadius: BorderRadius.circular(4),
  //                             ),
  //                             child: Text(qty.toString()),
  //                           ),
  //                         ),

  //                         SizedBox(
  //                           width: 80,
  //                           child: Container(
  //                             alignment: Alignment.center,
  //                             padding: const EdgeInsets.symmetric(vertical: 4),
  //                             decoration: BoxDecoration(
  //                               color: Colors.green.shade50,
  //                               borderRadius: BorderRadius.circular(4),
  //                             ),
  //                             child: Text(
  //                               "$total $packUnit",
  //                               style: const TextStyle(
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }).toList(),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _addressCard({
    required String title,
    required IconData icon,
    required Color color,
    required String address,
    required String? lat,
    required String? lng,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  openDirection(lat, lng);
                },
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(address),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
