import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageManager {
  static void showSuccess(String message) {
    _showMessage(
      title: "Success",
      message: message,
      color: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void showError(String message) {
    _showMessage(
      title: "Error",
      message: message,
      color: Colors.red,
      icon: Icons.error,
    );
  }

  static void showWarning(String message) {
    _showMessage(
      title: "Warning",
      message: message,
      color: Colors.orange,
      icon: Icons.warning,
    );
  }

  static void showInfo(String message) {
    _showMessage(
      title: "Info",
      message: message,
      color: Colors.blue,
      icon: Icons.info,
    );
  }

  static void _showMessage({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.only(top: kToolbarHeight + 20, left: 16, right: 16),
      borderRadius: 10,
      icon: Icon(icon, color: Colors.white),
      duration: Duration(seconds: 3),
    );
  }
}
