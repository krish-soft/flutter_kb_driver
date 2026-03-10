import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kb_driver/core/data/presentation/controllers/auth_controller.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/utils/preference_manager.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final VibrateManager _vibrateManager = VibrateManager();
  final AuthController _authController = Get.put(AuthController());

  String version = "";
  String packageName = "";

  final String aboutUrl = "https://khetbajar.in";

  @override
  void initState() {
    super.initState();
    loadAppInfo();
  }

  /// LOAD APP INFO
  Future<void> loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      version = info.version;
      packageName = info.packageName;
    });
  }

  /// RATE APP
  Future<void> rateApp() async {
    _vibrateManager.vibrateButton();

    String url = "";

    if (Platform.isAndroid) {
      url = "https://play.google.com/store/apps/details?id=$packageName";
    } else if (Platform.isIOS) {
      url = "https://apps.apple.com/app/idYOUR_APP_ID";
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// OPEN ABOUT WEBSITE
  Future<void> openAbout() async {
    _vibrateManager.vibrateButton();

    final uri = Uri.parse(aboutUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// LOGOUT
  void confirmLogout() {
    _vibrateManager.vibrateButton();

    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.textLogout.tr),
        content: Text(AppStrings.textMessageLogout.tr),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(AppStrings.textCancel.tr),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back();

              await _authController.signOutAll();

              await PreferenceManager.clearAllPreferences();

              Get.offAllNamed('/signin');
            },
            child: Text(AppStrings.textLogout.tr),
          ),
        ],
      ),
    );
  }

  /// CUSTOM SETTING TILE
  Widget settingItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _vibrateManager.vibrateButton();
        if (onTap != null) onTap();
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: AppStrings.screenMore.tr),

      backgroundColor: const Color(0xfff5f5f5),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          /// LOGOUT
          settingItem(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: AppStrings.textLogout.tr,
            onTap: confirmLogout,
          ),

          const SizedBox(height: 4),
          Text("Account"),
          const SizedBox(height: 4),

          /// PROFILE
          settingItem(
            icon: Icons.person,
            iconColor: Colors.blue,
            title: AppStrings.textProfile.tr,
            onTap: () => Get.toNamed('/profile'),
          ),

          /// BANK
          settingItem(
            icon: Icons.account_balance,
            iconColor: Colors.green,
            title: "Bank Details",
            onTap: () => Get.toNamed('/user-bank'),
          ),

          const SizedBox(height: 4),
          Text("About"),
          const SizedBox(height: 4),

          /// RATE APP
          settingItem(
            icon: Icons.star_rate,
            iconColor: Colors.orange,
            title: "Rate App",
            onTap: rateApp,
          ),

          /// ABOUT
          settingItem(
            icon: Icons.public,
            iconColor: Colors.purple,
            title: "About us",
            onTap: openAbout,
          ),

          const SizedBox(height: 12),

          /// VERSION
          settingItem(
            icon: Icons.info,
            iconColor: Colors.teal,
            title: "App Version $version",
          ),
        ],
      ),
    );
  }
}
