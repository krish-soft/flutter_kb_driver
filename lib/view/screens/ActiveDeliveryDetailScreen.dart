import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver/shipment_controller.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/view/components/common_chip.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';
import 'package:kb_driver/view/screens/ShipmentPackagesScreen.dart';

class ActiveDeliveryDetailScreen extends StatelessWidget {
  final dynamic shipment;

  ActiveDeliveryDetailScreen({super.key, required this.shipment});

  final ShipmentController controller = Get.find<ShipmentController>();

  /// Open Google Maps
  void openDirection(String? lat, String? lng) async {
    if (lat == null || lng == null) return;

    final url = "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng";

    await launchUrl(Uri.parse(url));
  }

  /// Capture delivery proof photo (compressed)
  Future<String?> capturePhoto() async {
    final picker = ImagePicker();

    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );

    return file?.path;
  }

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

  @override
  Widget build(BuildContext context) {
    final origin = shipment["origin"];
    final destination = shipment["destination"];
    final payable = shipment["shipment_payable"];

    /// BUTTON STATUS LOGIC
    final status = shipment["driver_shipment_status"].toString().toLowerCase();

    final bool canStart = status == "pending" || status == "accepted";

    final bool canComplete = status == "in_transit";

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: CommonAppBar(title: shipment["shipment_number"], showBack: true),

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
                  shipment["shipment_number"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    CommonChip(text: shipment["shipment_type"], isType: true),

                    const SizedBox(width: 8),

                    CommonChip(text: shipment["driver_shipment_status"]),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// Pickup Address
          _addressCard(
            title: "Pickup Address",
            icon: Icons.store,
            color: AppColors.primary,
            address: buildAddress(origin),
            lat: origin["lat"],
            lng: origin["lng"],
          ),

          const SizedBox(height: 12),

          /// Delivery Address
          _addressCard(
            title: "Delivery Address",
            icon: Icons.home,
            color: AppColors.success,
            address: buildAddress(destination),
            lat: destination["lat"],
            lng: destination["lng"],
          ),

          const SizedBox(height: 16),

          /// Shipment Information
          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Shipment Information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 10),

                _infoRow("Total Packages", "${shipment["total_packages"]}"),
                _infoRow("Total Weight", "${payable["total_weight"]} kg"),
                _infoRow("Total Quantity", "${payable["total_quantity"]}"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// Packages Screen Button
          AppButton(
            title: "View Packages",
            background: AppColors.info,
            onPressed: () {
              Get.to(() => ShipmentPackagesScreen(shipment: shipment));
            },
          ),

          const SizedBox(height: 20),

          /// Start Delivery
          AppButton(
            title: "Start Delivery",
            background: canStart ? AppColors.success : AppColors.textDisabled,
            onPressed: canStart
                ? () {
                    controller.startShipment(shipment["driver_shipment_id"]);
                  }
                : null,
          ),

          const SizedBox(height: 12),

          /// Complete Delivery
          AppButton(
            title: "Complete Delivery",
            background: canComplete ? AppColors.danger : AppColors.textDisabled,
            onPressed: canComplete
                ? () async {
                    final path = await capturePhoto();

                    if (path != null) {
                      controller.completeShipment(
                        shipment["driver_shipment_id"],
                        path,
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

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
