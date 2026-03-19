import 'package:geolocator/geolocator.dart';
import 'dart:io';

class DriverLocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      /// ✅ CHECK PERMISSION FIRST (IMPORTANT)
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      /// ✅ USE NEW SETTINGS API
      LocationSettings locationSettings;

      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        );
      } else if (Platform.isIOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        );
      } else {
        locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return position;
    } catch (e) {
      print("Location error: $e");
      return null;
    }
  }
}

// import 'package:geolocator/geolocator.dart';

// class DriverLocationService {
//   static Future<Position?> getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       return position;
//     } catch (e) {
//       print("Location error: $e");
//       return null;
//     }
//   }
// }
