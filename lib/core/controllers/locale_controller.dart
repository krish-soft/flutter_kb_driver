import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kb_driver/utils/preference_manager.dart';

class LocaleController extends GetxController {
  var locale = const Locale('en', 'US').obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedLocale();
  }

  void loadSavedLocale() {
    String code = PreferenceManager.getLanguage() ?? 'en';

    changeLocale(code, save: false);
  }

  void changeLocale(String code, {bool save = true}) {
    Locale newLocale;

    switch (code) {
      case 'gu':
        newLocale = const Locale('gu', 'IN');
        break;
      case 'hi':
        newLocale = const Locale('hi', 'IN');
        break;
      default:
        newLocale = const Locale('en', 'US');
    }

    locale.value = newLocale;

    Get.updateLocale(newLocale);

    if (save) {
      PreferenceManager.setLanguage(code);
    }
  }
}
