import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/shipment_controller.dart';

class ShipmentPackagesScreen extends StatefulWidget {
  final dynamic shipment;

  const ShipmentPackagesScreen({super.key, required this.shipment});

  @override
  State<ShipmentPackagesScreen> createState() => _ShipmentPackagesScreenState();
}

class _ShipmentPackagesScreenState extends State<ShipmentPackagesScreen> {
  late List packages;
  late String shipmentType;
  late String driverShipmentStatus;

  final ShipmentController controller = Get.find<ShipmentController>();

  @override
  void initState() {
    super.initState();

    shipmentType = widget.shipment["shipment_type"];
    driverShipmentStatus = widget.shipment["driver_shipment_status"];

    packages = widget.shipment["shipmentPackages"];
  }

  bool get isCompleted => driverShipmentStatus == "completed";

  /// options based on shipment type
  List<String> getStatusOptions() {
    if (shipmentType == "pickup") {
      return ["picked_up", "not_picked_up"];
    }

    if (shipmentType == "dispatch") {
      return ["delivered"];
    }

    return ["received", "not_received"];
  }

  /// secondary status
  String getTypeStatus(dynamic pkg) {
    if (shipmentType == "pickup") {
      return pkg["shipment_package_seller_status"];
    }

    if (shipmentType == "dispatch") {
      return pkg["shipment_package_buyer_status"];
    }

    return pkg["shipment_package_transfer_status"];
  }

  /// main package status
  String getMainStatus(dynamic pkg) {
    return pkg["shipment_package_status"];
  }

  Color getStatusColor(String status) {
    if (status.contains("not")) return AppColors.danger;
    if (status.contains("pending")) return AppColors.warning;

    return AppColors.success;
  }

  /// update API
  Future<void> updateStatus(
    int driverShipmentId,
    int packageId,
    String status,
    int index,
  ) async {
    if (isCompleted) return;

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

  @override
  Widget build(BuildContext context) {
    final driverShipmentId = widget.shipment["driver_shipment_id"];

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const CommonAppBar(title: "Shipment Packages", showBack: true),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packages.length,

        itemBuilder: (context, index) {
          final pkg = packages[index];

          final mainStatus = getMainStatus(pkg);
          final typeStatus = getTypeStatus(pkg);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),

            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: AppColors.shadow, blurRadius: 6),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),

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
                            fontSize: 15,
                          ),
                        ),
                      ),

                      Text(
                        "${pkg["pack_size"]} ${pkg["unit"]}",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// MAIN STATUS
                  Row(
                    children: [
                      const Text(
                        "Main Status: ",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      Text(
                        mainStatus,
                        style: TextStyle(
                          color: getStatusColor(mainStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// TYPE STATUS
                  Row(
                    children: [
                      Text(
                        "$shipmentType Status: ",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      Text(
                        typeStatus,
                        style: TextStyle(
                          color: getStatusColor(typeStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// OPTIONS
                  Wrap(
                    spacing: 10,

                    children: getStatusOptions().map((status) {
                      final selected = typeStatus == status;

                      return ChoiceChip(
                        label: Text(status),

                        selected: selected,

                        selectedColor: getStatusColor(status),

                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),

                        onSelected: isCompleted
                            ? null
                            : (_) {
                                updateStatus(
                                  driverShipmentId,
                                  pkg["shipment_package_id"],
                                  status,
                                  index,
                                );
                              },
                      );
                    }).toList(),
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
