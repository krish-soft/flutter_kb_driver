import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  /// ================= LOGOUT CONFIRM =================

  void confirmLogout() {
     _vibrateManager.vibrateButton();
     
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.textLogout.tr),

        content: Text(AppStrings.textMessageLogout.tr),

        actions: [
          TextButton(
            onPressed: () {
              _vibrateManager.vibrateButton();
              Get.back();
            },
            child: Text(AppStrings.textCancel.tr),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              _vibrateManager.vibrateButton();
              Get.back();

              await _authController.signOutAll();

              PreferenceManager.clearAllPreferences();

              /// redirect to signin
              Get.offAllNamed('/signin');
            },
            child: Text(AppStrings.textLogout.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: AppStrings.screenMore.tr),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          /// PROFILE CARD
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                radius: 22,
                child: Icon(Icons.person),
              ),
              title: Text(
                AppStrings.textProfile.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // subtitle: const Text("View or update profile"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.toNamed('/profile');
              },
            ),
          ),

          const SizedBox(height: 16),

          /// LOGOUT CARD
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.red,
                child: Icon(Icons.logout, color: Colors.white),
              ),
              title: Text(
                AppStrings.textLogout.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              // subtitle: const Text("Sign out from application"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: confirmLogout,
            ),
          ),
        ],
      ),
    );
  }
}
