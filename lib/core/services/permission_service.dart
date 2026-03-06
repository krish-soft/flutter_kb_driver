import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestRequiredPermissions() async {
    /// Check current status first
    PermissionStatus location = await Permission.location.status;
    PermissionStatus camera = await Permission.camera.status;
    PermissionStatus notification = await Permission.notification.status;

    debugPrint("Location status: $location");
    debugPrint("Camera status: $camera");
    debugPrint("Notification status: $notification");

    /// Request only if not granted
    if (!location.isGranted) {
      location = await Permission.location.request();
    }

    if (!camera.isGranted) {
      camera = await Permission.camera.request();
    }

    if (!notification.isGranted) {
      notification = await Permission.notification.request();
    }

    debugPrint("Location after request: $location");
    debugPrint("Camera after request: $camera");
    debugPrint("Notification after request: $notification");

    /// Handle permanently denied
    if (location.isPermanentlyDenied ||
        camera.isPermanentlyDenied ||
        notification.isPermanentlyDenied) {
      debugPrint("Permission permanently denied → open settings");

      await openAppSettings();
      return false;
    }

    return location.isGranted && camera.isGranted && notification.isGranted;
  }
}
