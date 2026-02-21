import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:kb_driver/utils/preference_manager.dart';

class AppUtils {
  // Use method to check suer loggned in or not
  // Checks if the user is logged in by reading from PreferenceManager
  static Future<bool> isUserLoggedIn() async {
    try {
      return await PreferenceManager.getIsAuth() ?? false;
    } catch (_) {
      return false;
    }
  }

  // Checks if the token exists and is not expired
  static Future<bool> isTokenValid() async {
    try {
      final token = await PreferenceManager.getAccessToken();
      final tokenExpiry = await PreferenceManager.getTokenExpiryTime();

      if (token != null && tokenExpiry != null) {
        final expiryDate = DateTime.tryParse(tokenExpiry);
        if (expiryDate != null && expiryDate.isAfter(DateTime.now())) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // Add common utility methods here
  Future<String?> getLocalDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (kIsWeb) {
        WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        // Use userAgent as a pseudo device id for web
        return webInfo.userAgent;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Use androidId as device id
        return androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        // Use identifierForVendor as device id
        return iosInfo.identifierForVendor;
      } else {
        // Other platforms not supported
        return null;
      }
    } catch (e) {
      // Permission not granted or error occurred
      return null;
    }
  }

  /**
 *  Helper
 */

  String countryIsoToFlag(String iso) {
    if (iso.length != 2) return '🌍';
    final a = iso.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final b = iso.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return (a < 0 || b < 0) ? '🌍' : String.fromCharCodes([a, b]);
  }
}
