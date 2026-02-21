import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LocaleController extends GetxController {
  var locale = const Locale('en', 'US').obs;

  void changeLocale(String code) {
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
  }
}
