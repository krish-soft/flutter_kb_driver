import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/utils/message_manager.dart';
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
  final VibrateManager vibrate = VibrateManager();

  late List packages;
  late String shipmentType;

  final Set<int> selectedPackageIds = <int>{};

  int selectedIndex = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    packages = widget.shipment["shipmentPackages"] ?? [];
    shipmentType = widget.shipment["shipment_type"] ?? "";
  }

  String getMainNumber(pkg) {
    if (shipmentType.contains("pickup")) {
      if (shipmentType.contains("market")) {
        return pkg["package_number_market"] ?? pkg["package_number"] ?? "-";
      }

      return pkg["package_number_seller"] ?? pkg["package_number"] ?? "-";
    }

    if (shipmentType.contains("dispatch")) {
      if (shipmentType.contains("market")) {
        return pkg["package_number_market"] ?? pkg["package_number"] ?? "-";
      }

      return pkg["package_number_buyer"] ?? pkg["package_number"] ?? "-";
    }

    return pkg["package_number"] ?? "-";
  }

  String getStatus(pkg) {
    return pkg["shipment_package_status"] ?? "pending";
  }

  Color statusColor(String status) {
    if (status.contains("return")) return AppColors.warning;
    if (status.contains("damage")) return AppColors.danger;
    if (status.contains("lost")) return AppColors.danger;
    if (status.contains("not")) return AppColors.danger;
    if (status.contains("pending")) return AppColors.warning;
    return AppColors.success;
  }

  List<String> getOptions() {
    if (shipmentType.contains("pickup")) {
      return ["picked_up", "not_picked_up"];
    }

    if (shipmentType.contains("dispatch")) {
      return ["delivered", "damaged", "lost"]; // temporary option
    }

    return ["picked_up", "delivered"];
    // return ["received", "not_received"];
  }

  int? getPackageId(dynamic pkg) {
    final dynamic id = pkg["shipment_package_id"];

    if (id is int) return id;
    if (id is String) return int.tryParse(id);

    return null;
  }

  bool isSelected(dynamic pkg) {
    final id = getPackageId(pkg);
    if (id == null) return false;

    return selectedPackageIds.contains(id);
  }

  void togglePackageSelection(dynamic pkg) {
    final id = getPackageId(pkg);
    if (id == null) return;

    setState(() {
      if (selectedPackageIds.contains(id)) {
        selectedPackageIds.remove(id);
      } else {
        selectedPackageIds.add(id);
      }
    });
  }

  void toggleSelectAll() {
    final ids = packages
        .map<int?>((p) => getPackageId(p))
        .whereType<int>()
        .toList();

    setState(() {
      if (ids.isNotEmpty && selectedPackageIds.length == ids.length) {
        selectedPackageIds.clear();
      } else {
        selectedPackageIds
          ..clear()
          ..addAll(ids);
      }
    });
  }

  Future<void> updateBulkStatus(String status) async {
    if (loading) return;

    final packageIds = selectedPackageIds.toList();
    if (packageIds.isEmpty) {
      MessageManager.showError("Select at least one package.");
      return;
    }

    vibrate.vibrateMedium();

    setState(() {
      loading = true;
    });

    try {
      ApiResponseModel res = await controller.updatePkgStatusBulk(
        widget.shipment["driver_shipment_id"],
        packageIds,
        status,
      );

      if (res.isSuccess == true) {
        for (final pkg in packages) {
          final id = getPackageId(pkg);
          if (id != null && selectedPackageIds.contains(id)) {
            pkg["shipment_package_status"] = status;
          }
        }

        selectedPackageIds.clear();
        vibrate.vibrateSelection();
      } else {
        MessageManager.showError(res.message);
      }
    } catch (e) {
      MessageManager.showError(AppStrings.textStatusUpdateFailed.tr);
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> updateStatus(String status) async {
    if (loading) return;

    final pkg = packages[selectedIndex];

    vibrate.vibrateMedium();

    setState(() {
      loading = true;
    });

    try {
      ApiResponseModel res = await controller.updatePkgStatus(
        widget.shipment["driver_shipment_id"],
        pkg["shipment_package_id"],
        status,
      );

      if (res.isSuccess == true) {
        packages[selectedIndex]["shipment_package_status"] = status;
        vibrate.vibrateSelection();
      }
    } catch (e) {
      MessageManager.showError(AppStrings.textStatusUpdateFailed.tr);
      // Get.snackbar(
      //   AppStrings.textError.tr,
      //   e.toString(),
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    }

    setState(() {
      loading = false;
    });
  }

  /// LEFT PANEL
  Widget packageList() {
    final selectableCount = packages
        .map<int?>((p) => getPackageId(p))
        .whereType<int>()
        .length;
    final allSelected =
        selectableCount > 0 && selectedPackageIds.length == selectableCount;

    return Container(
      width: 190,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: allSelected,
                  onChanged: (_) => toggleSelectAll(),
                ),
                const Expanded(
                  child: Text(
                    "Select All",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  "${selectedPackageIds.length}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final pkg = packages[index];
                final status = getStatus(pkg);

                return GestureDetector(
                  onTap: () {
                    vibrate.vibrateMedium();

                    setState(() => selectedIndex = index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? AppColors.primary.withOpacity(.08)
                          : Colors.white,
                      border: const Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isSelected(pkg),
                              onChanged: (_) => togglePackageSelection(pkg),
                            ),
                            Expanded(
                              child: Text(
                                getMainNumber(pkg),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            "${pkg["pack_size"]} ${pkg["unit"]}",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(status),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// RIGHT PANEL BLOCK
  Widget infoBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  /// RIGHT PANEL
  Widget packageDetails() {
    if (packages.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text("No packages found."),
        ),
      );
    }

    final pkg = packages[selectedIndex];
    final status = getStatus(pkg);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoBlock(
                      AppStrings.textPackage.tr,
                      pkg["package_number"] ?? "-",
                    ),

                    infoBlock(
                      AppStrings.textSeller.tr,
                      pkg["package_number_seller"] ?? "-",
                    ),

                    infoBlock(
                      AppStrings.textBuyer.tr,
                      pkg["package_number_buyer"] ?? "-",
                    ),

                    infoBlock(
                      AppStrings.textMarket.tr,
                      pkg["package_number_market"] ?? "-",
                    ),

                    //  Divider
                    const Divider(height: 30, thickness: 1),

                    infoBlock(
                      AppStrings.textProductName.tr,
                      "${pkg["product"]['name']}",
                    ),

                    infoBlock(
                      AppStrings.textPackSize.tr,
                      "${pkg["pack_size"]} ${pkg["unit"]}",
                    ),

                    //  Divider
                    const Divider(height: 30, thickness: 1),

                    infoBlock(AppStrings.textShipmentType.tr, shipmentType),

                    Row(
                      children: [
                        Text(
                          AppStrings.textStatus.tr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor(status),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),

            if (selectedPackageIds.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bulk update for ${selectedPackageIds.length} package(s)",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: getOptions().map((s) {
                        return ElevatedButton(
                          onPressed: () => updateBulkStatus(s),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusColor(s),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          child: Text(s.replaceAll("_", " ").toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            if (loading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: getOptions().map((s) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () => updateStatus(s),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor(s),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: Text(s.replaceAll("_", " ").toUpperCase()),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
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
      body: Row(children: [packageList(), packageDetails()]),
    );
  }
}
