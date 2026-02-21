import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/constants/app_routes.dart';
import 'package:kb_driver/core/controllers/locale_controller.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/core/lang/translations.dart';

void main() {
  Get.put(LocaleController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),

      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Khet Bajar -Driver',
      theme: ThemeData(
        // fontFamily: 'Buenard',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),
      // home: const SplashScreen(),
      initialRoute: '/splash',
      getPages: AppRoutes.routes,
    );
  }
}
