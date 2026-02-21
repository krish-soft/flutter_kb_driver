import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageManager {
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 20, left: 16, right: 16),
      icon: Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 20, left: 16, right: 16),
      icon: Icon(Icons.error, color: Colors.white),
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      'Warning',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 20, left: 16, right: 16),
      icon: Icon(Icons.warning, color: Colors.white),
    );
  }

  static void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 20, left: 16, right: 16),
      icon: Icon(Icons.info, color: Colors.white),
    );
  }
}
