import 'package:flutter/material.dart';
import 'package:kb_driver/constants/app_colors.dart';

class CommonChip extends StatelessWidget {
  final String text;
  final bool isType;

  const CommonChip({super.key, required this.text, this.isType = false});

  Color _getColor() {
    final value = text.toLowerCase();

    /// Shipment TYPE colors
    if (isType) {
      if (value == "pickup") return AppColors.tripPickup;
      if (value == "dispatch") return AppColors.info;
      if (value == "transfer") return AppColors.secondary;
    }

    /// Shipment STATUS colors
    if (value == "requested") return AppColors.warning;
    if (value == "accepted") return AppColors.tripAssigned;
    if (value == "in_transit") return AppColors.tripInTransit;
    if (value == "delivered") return AppColors.tripDelivered;
    if (value == "failed") return AppColors.tripFailed;

    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
