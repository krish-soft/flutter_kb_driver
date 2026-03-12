import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestRequiredPermissions() async {
    PermissionStatus location = await Permission.location.request();
    PermissionStatus camera = await Permission.camera.request();
    PermissionStatus notification = await Permission.notification.request();

    /// Storage / Image permission
    PermissionStatus storage;

    if (defaultTargetPlatform == TargetPlatform.android) {
      storage = await Permission.photos.request(); // Android 13+
      if (!storage.isGranted) {
        storage = await Permission.storage.request(); // Android <=12
      }
    } else {
      storage = await Permission.photos.request(); // iOS
    }

    // debugPrint("Location: $location");
    // debugPrint("Camera: $camera");
    // debugPrint("Notification: $notification");
    // debugPrint("Storage: $storage");

    if (location.isPermanentlyDenied ||
        camera.isPermanentlyDenied ||
        notification.isPermanentlyDenied ||
        storage.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return location.isGranted &&
        camera.isGranted &&
        notification.isGranted &&
        storage.isGranted;
  }
}
// import 'package:flutter/foundation.dart';
// import 'package:permission_handler/permission_handler.dart';

// class PermissionService {
//   static Future<bool> requestRequiredPermissions() async {
//     /// Check current status first
//     PermissionStatus location = await Permission.location.status;
//     PermissionStatus camera = await Permission.camera.status;
//     PermissionStatus notification = await Permission.notification.status;

//     debugPrint("Location status: $location");
//     debugPrint("Camera status: $camera");
//     debugPrint("Notification status: $notification");

//     /// Request only if not granted
//     if (!location.isGranted) {
//       location = await Permission.location.request();
//     }

//     if (!camera.isGranted) {
//       camera = await Permission.camera.request();
//     }

//     if (!notification.isGranted) {
//       notification = await Permission.notification.request();
//     }

//     debugPrint("Location after request: $location");
//     debugPrint("Camera after request: $camera");
//     debugPrint("Notification after request: $notification");

//     /// Handle permanently denied
//     if (location.isPermanentlyDenied ||
//         camera.isPermanentlyDenied ||
//         notification.isPermanentlyDenied) {
//       debugPrint("Permission permanently denied → open settings");

//       await openAppSettings();
//       return false;
//     }

//     return location.isGranted && camera.isGranted && notification.isGranted;
//   }
// }
