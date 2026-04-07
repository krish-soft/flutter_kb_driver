import 'package:flutter/material.dart';

class AppColors {
  // =========================================================
  // BRAND COLORS (Farming Theme)
  // =========================================================

  /// Primary = Main tractor green
  static const Color primary = Color(0xFF2E7D32); // Farm Green
  static const Color primaryDark = Color(0xFF1B5E20); // Darker Farm Green

  /// Secondary = Fresh leaf green
  static const Color secondary = Color(0xFF66BB6A); // Light Green

  /// Accent = Vegetable / Produce Orange
  static const Color accent = Color(0xFFF57C00); // Carrot Orange

  /// Earth Tone (optional use in UI / cards)
  static const Color earth = Color(0xFF6D4C41); // Soil Brown

  // =========================================================
  // STANDARD SYSTEM COLORS (Web-style naming)
  // =========================================================

  static const Color success = Color(0xFF16A34A); // Delivered / Completed
  static const Color warning = Color(0xFFF59E0B); // Pending / Attention
  static const Color danger = Color(0xFFDC2626); // Failed / Cancelled
  static const Color info = Color(0xFF2563EB); // Route / Map Info

  // =========================================================
  // BACKGROUND & SURFACE
  // =========================================================

  static const Color background = Color(0xFFF6FBF6); // Soft farm tint
  static const Color scaffold = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF1F8F4); // Card background

  // =========================================================
  // TEXT COLORS
  // =========================================================

  static const Color textPrimary = Color(0xFF1B4332);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // =========================================================
  // ICONS & NAVIGATION
  // =========================================================

  static const Color iconActive = primary;
  static const Color iconInactive = Color(0xFF9AA5B1);
  static const Color bottomBarBg = Color(0xFFFFFFFF);

  // =========================================================
  // BORDERS & OUTLINES
  // =========================================================

  static const Color border = Color(0xFFE5E7EB);
  static const Color outline = Color(0xFFA5D6A7); // light green outline
  static const Color divider = Color(0xFFE8F5E9);

  // =========================================================
  // DELIVERY STATUS COLORS (Useful for Driver App)
  // =========================================================

  static const Color tripAssigned = Color(0xFF42A5F5);
  static const Color tripPickup = Color(0xFFF59E0B);
  static const Color tripInTransit = Color(0xFF7E57C2);
  static const Color tripDelivered = Color(0xFF16A34A);
  static const Color tripFailed = Color(0xFFDC2626);
  static const Color tripCompleted = Color(0xFF16A34A);

  // =========================================================
  // OVERLAYS & SHADOWS
  // =========================================================

  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x66000000);


  static const Color orange = Color(0xFFFFA500);
  static const Color white = Color(0xFFFFFFFF);
}
