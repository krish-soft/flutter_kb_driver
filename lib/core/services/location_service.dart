import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print("Location error: $e");
      return null;
    }
  }
}
