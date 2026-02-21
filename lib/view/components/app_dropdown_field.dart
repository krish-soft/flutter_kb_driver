import 'package:flutter/material.dart';
import 'package:kb_driver/constants/app_colors.dart';

class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final IconData? icon;
  final Color? focusColor;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.icon,
    this.focusColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = focusColor ?? AppColors.primary;

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: icon != null ? Icon(icon, color: color) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
