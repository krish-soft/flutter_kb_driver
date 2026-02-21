import 'package:flutter/services.dart';

class VibrateManager {
  static final VibrateManager _instance = VibrateManager._internal();

  factory VibrateManager() {
    return _instance;
  }

  VibrateManager._internal();

  /// Vibrate with a short feedback, suitable for button taps.
  Future<void> vibrateButton() async {
    await HapticFeedback.lightImpact();
  }

  /// Vibrate with a medium feedback.
  Future<void> vibrateMedium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Vibrate with a heavy feedback.
  Future<void> vibrateHeavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Vibrate with a selection feedback.
  Future<void> vibrateSelection() async {
    await HapticFeedback.selectionClick();
  }
}
