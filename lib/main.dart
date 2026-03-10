import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/constants/app_routes.dart';
import 'package:kb_driver/core/controllers/locale_controller.dart';
import 'package:kb_driver/core/data/presentation/controllers/driver_status_controller.dart';
import 'package:kb_driver/core/lang/translations.dart';
import 'package:kb_driver/core/services/driver_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // For secure storage

  await GetStorage.init();

  Get.put(LocaleController());

  await DriverBackgroundService.initialize();
  Get.put(DriverStatusController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final LocaleController localeController = Get.find();

    return GetMaterialApp(
      translations: AppTranslations(),
      // locale: const Locale('en', 'US'),
      locale: localeController.locale.value,

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
