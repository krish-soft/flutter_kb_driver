import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kb_driver/constants/app_colors.dart';

class AppInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType keyboardType;
  final bool obscure;
  final bool enabled;
  final bool centerText;
  final int? maxLength;
  final Color? focusColor;
  final List<TextInputFormatter>? formatters;

  const AppInputField({
    super.key,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.enabled = true,
    this.centerText = false,
    this.maxLength,
    this.focusColor,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    final color = focusColor ?? AppColors.primary;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      enabled: enabled,
      textAlign: centerText ? TextAlign.center : TextAlign.start,
      maxLength: maxLength,
      inputFormatters: formatters,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: color) : null,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
