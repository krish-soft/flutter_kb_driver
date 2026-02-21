import 'package:get/get.dart';
import 'en.dart';
import 'hi.dart';
import 'gu.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'hi_IN': hiIN,
    'gu_IN': guIN,
  };
}

// To Pass on API Clients
class AppWebTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': enUS,
    'hi': hiIN,
    'gu': guIN,
  };

  static String get apiLanguage {
    return Get.locale?.languageCode ?? 'en';
  }
}
