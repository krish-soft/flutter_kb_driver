import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class ShipmentPackagesScreen extends StatefulWidget {
  final dynamic shipment;

  const ShipmentPackagesScreen({super.key, required this.shipment});

  @override
  State<ShipmentPackagesScreen> createState() => _ShipmentPackagesScreenState();
}

class _ShipmentPackagesScreenState extends State<ShipmentPackagesScreen> {
  late List packages;
  late String shipmentType;

  Map<int, String> statusMap = {};

  @override
  void initState() {
    super.initState();

    shipmentType = widget.shipment["shipment_type"];
    packages = widget.shipment["shipmentPackages"];

    for (var pkg in packages) {
      statusMap[pkg["shipment_package_id"]] = getDefaultStatus(pkg);
    }
  }

  String getStatusField() {
    if (shipmentType == "pickup") {
      return "shipment_package_seller_status";
    }

    if (shipmentType == "dispatch") {
      return "shipment_package_buyer_status";
    }

    return "shipment_package_transfer_status";
  }

  String getDefaultStatus(dynamic pkg) {
    if (shipmentType == "pickup") {
      return pkg["shipment_package_seller_status"] ?? "picked_up";
    }

    if (shipmentType == "dispatch") {
      return pkg["shipment_package_buyer_status"] ?? "delivered";
    }

    return pkg["shipment_package_transfer_status"] ?? "received";
  }

  List<String> getStatusOptions() {
    if (shipmentType == "pickup") {
      return ["picked_up", "not_picked_up"];
    }

    if (shipmentType == "dispatch") {
      return ["delivered", "not_delivered"];
    }

    return ["received", "not_received"];
  }

  Color getStatusColor(String status) {
    if (status.contains("not")) {
      return AppColors.danger;
    }

    return AppColors.success;
  }

  void submitStatus() {
    final field = getStatusField();

    List payload = [];

    for (var pkg in packages) {
      final id = pkg["shipment_package_id"];

      payload.add({"shipment_package_id": id, field: statusMap[id]});
    }

    final body = {
      "driver_shipment_id": widget.shipment["driver_shipment_id"],
      "packages": payload,
    };

    /// TODO: call API
    print(body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const CommonAppBar(title: "Shipment Packages", showBack: true),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: packages.length,

              itemBuilder: (context, index) {
                final pkg = packages[index];
                final id = pkg["shipment_package_id"];

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
                        /// package header
                        Row(
                          children: [
                            const Icon(
                              Icons.inventory_2,
                              color: AppColors.primary,
                            ),

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
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// status options
                        Wrap(
                          spacing: 10,

                          children: getStatusOptions().map((status) {
                            final selected = statusMap[id] == status;

                            return ChoiceChip(
                              label: Text(status),

                              selected: selected,

                              selectedColor: getStatusColor(status),

                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),

                              onSelected: (_) {
                                setState(() {
                                  statusMap[id] = status;
                                });
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
          ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: AppButton(
              title: "Update Package Status",
              background: AppColors.warning,
              onPressed: submitStatus,
            ),
          ),
        ],
      ),
    );
  }
}
