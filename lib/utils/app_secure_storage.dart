import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  AppSecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // WRITE
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // READ
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // DELETE KEY
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // CLEAR ALL
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // EXISTS
  static Future<bool> contains(String key) async {
    return (await _storage.read(key: key)) != null;
  }
}
