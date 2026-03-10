import 'package:get_storage/get_storage.dart';
import 'app_secure_storage.dart';

class PreferenceManager {
  static final GetStorage _box = GetStorage();

  // CLEAR EVERYTHING (LOGOUT)
  static Future<void> clearAllPreferences() async {
    await _box.erase();
    await AppSecureStorage.clearAll();
  }

  // ---------------- NON-SECURE ----------------

  static Future<void> setIsAuth(bool value) async {
    await _box.write('_is_auth', value);
  }

  static bool getIsAuth() {
    return _box.read('_is_auth') ?? false;
  }

  static Future<void> setCountryList(List<dynamic> value) async {
    await _box.write('_country_list', value);
  }

  static List<dynamic> getCountryList() {
    return _box.read('_country_list') ?? [];
  }

  // ---------------- SECURE ----------------

  static Future<void> setAccessToken(String token) async {
    await AppSecureStorage.write('_accessToken', token);
  }

  static Future<String> getAccessToken() async {
    return await AppSecureStorage.read('_accessToken') ?? '';
  }

  static Future<void> setTokenExpiryTime(String expiry) async {
    await AppSecureStorage.write('_tokenExpiryTime', expiry);
  }

  static Future<String> getTokenExpiryTime() async {
    return await AppSecureStorage.read('_tokenExpiryTime') ?? '';
  }

  static Future<void> setDeviceId(String deviceId) async {
    await AppSecureStorage.write('_deviceId', deviceId);
  }

  static Future<String> getDeviceId() async {
    return await AppSecureStorage.read('_deviceId') ?? '';
  }

  /// Driver status
  static Future<void> setIsDriverOnline(bool value) async {
    await _box.write('_is_driver_online', value);
  }

  static bool getIsDriverOnline() {
    return _box.read('_is_driver_online') ?? false;
  }

  static void setLanguage(String code) {
    _box.write('app_language', code);
  }

  static String? getLanguage() {
    return _box.read('app_language');
  }

  //
}
