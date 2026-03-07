import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/shipment_controller.dart';

class ShipmentPackagesScreen extends StatefulWidget {
  final dynamic shipment;

  const ShipmentPackagesScreen({super.key, required this.shipment});

  @override
  State<ShipmentPackagesScreen> createState() => _ShipmentPackagesScreenState();
}

class _ShipmentPackagesScreenState extends State<ShipmentPackagesScreen> {
  final ShipmentController controller = Get.find<ShipmentController>();

  final VibrateManager _vibrateManager = VibrateManager();

  late List packages;
  late String shipmentType;
  late String driverShipmentStatus;

  @override
  void initState() {
    super.initState();

    packages = widget.shipment["shipmentPackages"];
    shipmentType = widget.shipment["shipment_type"];
    driverShipmentStatus = widget.shipment["driver_shipment_status"];
  }

  bool get shipmentCompleted =>
      driverShipmentStatus == "completed" ||
      driverShipmentStatus == "delivered";

  String getMainStatus(pkg) {
    return pkg["shipment_package_status"] ?? "pending";
  }

  String getTypeStatus(pkg) {
    if (shipmentType == "pickup") {
      return pkg["shipment_package_seller_status"] ?? "pending";
    }

    if (shipmentType == "dispatch") {
      return pkg["shipment_package_buyer_status"] ?? "pending";
    }

    return pkg["shipment_package_transfer_status"] ?? "pending";
  }

  Color statusColor(String status) {
    if (status.contains("not")) return AppColors.danger;
    if (status.contains("pending")) return AppColors.warning;
    return AppColors.success;
  }

  List<String> getOptions() {
    if (shipmentType == "pickup") {
      return ["picked_up", "not_picked_up"];
    }

    if (shipmentType == "dispatch") {
      return ["delivered"];
    }

    return ["received", "not_received"];
  }

  /// API Update
  Future<void> updateStatus(
    int driverShipmentId,
    int packageId,
    String status,
    int index,
  ) async {
    if (shipmentCompleted) return;

    if (shipmentType == "pickup") {
      await controller.updatePkgSellerStatus(
        driverShipmentId,
        packageId,
        status,
      );

      packages[index]["shipment_package_seller_status"] = status;
    } else if (shipmentType == "dispatch") {
      await controller.updatePkgBuyerStatus(
        driverShipmentId,
        packageId,
        status,
      );

      packages[index]["shipment_package_buyer_status"] = status;
    } else {
      await controller.updatePkgTransferStatus(
        driverShipmentId,
        packageId,
        status,
      );

      packages[index]["shipment_package_transfer_status"] = status;
    }

    setState(() {});
  }

  /// Confirm Dialog
  void confirmUpdate(pkg, status, index) {
    Get.dialog(
      AlertDialog(
        title: const Text("Confirm Status"),
        content: Text("Update package ${pkg["package_number"]} to '$status'?"),
        actions: [
          TextButton(
            onPressed: () {
              _vibrateManager.vibrateMedium();
              Get.back();
            },
            child: Text(AppStrings.textCancel.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              _vibrateManager.vibrateMedium();
              Get.back();
              await updateStatus(
                widget.shipment["driver_shipment_id"],
                pkg["shipment_package_id"],
                status,
                index,
              );
            },
            child: Text(AppStrings.textConfirm.tr),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet selector
  void openStatusSelector(pkg, index) {
    final options = getOptions();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.textSelectStatus.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            ...options.map((status) {
              return ListTile(
                title: Text(status),
                leading: Icon(Icons.circle, color: statusColor(status)),
                onTap: () {
                  _vibrateManager.vibrateButton();
                  Get.back();
                  confirmUpdate(pkg, status, index);
                },
              );
            }),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget badge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor(status),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget statusTable(mainStatus, typeStatus) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text("Main Status", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                badge(mainStatus),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  "$shipmentType Status",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                badge(typeStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: CommonAppBar(
        title: AppStrings.textShipmentPackages.tr,
        showBack: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packages.length,

        itemBuilder: (context, index) {
          final pkg = packages[index];

          final mainStatus = getMainStatus(pkg);
          final typeStatus = getTypeStatus(pkg);

          return GestureDetector(
            onTap: shipmentCompleted
                ? null
                : () {
                    _vibrateManager.vibrateButton();
                    openStatusSelector(pkg, index);
                  },

            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 6),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// HEADER
                  Row(
                    children: [
                      const Icon(Icons.inventory_2, color: AppColors.primary),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          pkg["package_number"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      Text(
                        "${pkg["pack_size"]} ${pkg["unit"]}",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  /// STATUS TABLE
                  statusTable(mainStatus, typeStatus),

                  const SizedBox(height: 6),

                  if (!shipmentCompleted)
                    Text(
                      AppStrings.textTapToUpdateStatus.tr,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
