import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/constants/app_images.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/presentation/controllers/utils/kyc_controller.dart';
import 'package:kb_driver/core/data/repositories/utils/meta_repository.dart';
import 'package:kb_driver/core/services/permission_service.dart';
import 'package:kb_driver/utils/app_utils.dart';
import 'package:kb_driver/utils/message_manager.dart';
import 'package:kb_driver/utils/preference_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

enum SplashState { loading, maintenance, forceUpdate, accountDisabled }

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _metaTimeout = Duration(seconds: 5);

  final MetaRepository _metaRepo = MetaRepository();
  final KycController _kycController = Get.put(KycController());

  SplashState _state = SplashState.loading;
  String? _maintenanceMessage;
  String? _accountDisabledMessage;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startApp();
    });
  }

  Future<void> _startApp() async {
    try {
      await PermissionService.requestRequiredPermissions();
    } catch (e) {
      debugPrint("Permission error: $e");
    }

    await _boot();
  }

  Future<void> _boot() async {
    final bool isLoggedIn = await AppUtils.isUserLoggedIn();

    if (!isLoggedIn) {
      await _navigateByAuth();
      return;
    }

    final ApiResponseModel resp = await _metaRepo.getUserMeta();

    if (resp.isSuccess != true) {
      await _navigateByAuth();
      return;
    }

    final data = resp.data;

    final bool isKycSubmitted = data['is_kyc_submitted'] ?? false;
    final bool isVehicleKycSubmitted =
        data['is_vehicle_kyc_submitted'] ?? false;
    final bool isKycApproved = data['is_kyc_approved'] ?? false;
    final bool isVehicleKycApproved = data['is_vehicle_kyc_approved'] ?? false;

    /// 1️⃣ KYC not submitted → open KYC screen
    if (!isKycSubmitted || !isVehicleKycSubmitted) {
      String kycURL = "";

      if (!isKycSubmitted) {
        kycURL = await _kycController.getUserKycSignedURL() ?? "";
      } else if (!isVehicleKycSubmitted) {
        kycURL = await _kycController.getVehicleKycSignedURL() ?? "";
      }

      if (kycURL.isNotEmpty) {
        Get.offAllNamed('/kyc', arguments: {'kycURL': kycURL});
        return;
      }

      MessageManager.showError("Failed to get KYC URL. Please try again.");
      return;
    }

    /// 2️⃣ KYC submitted but not approved → review screen
    if (!isKycApproved || !isVehicleKycApproved) {
      Get.offAllNamed('/kyc-review');
      return;
    }

    /// 3️⃣ All approved → normal navigation
    await _navigateByAuth();
  }

  Future<void> _navigateByAuth() async {
    final bool isLoggedIn = await AppUtils.isUserLoggedIn();
    final bool isTokenValid = await AppUtils.isTokenValid();

    if (!mounted) return;

    if (isLoggedIn && isTokenValid) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/signin');
    }
  }

  Future<void> _openStore() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    late final Uri uri;

    if (Platform.isAndroid) {
      uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=${info.packageName}',
      );
    } else if (Platform.isIOS) {
      uri = Uri.parse('https://apps.apple.com/app/id${info.packageName}');
    } else {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return _BaseSplashLayout(body: _buildStateContent());
  }

  Widget _buildStateContent() {
    switch (_state) {
      case SplashState.maintenance:
        return _StatusCard(
          icon: Icons.build_rounded,
          iconColor: Colors.orange,
          title: 'Under Maintenance',
          message:
              _maintenanceMessage ??
              'We are performing scheduled maintenance.\nPlease try again shortly.',
        );

      case SplashState.forceUpdate:
        return _ActionCard(
          icon: Icons.system_update_alt_rounded,
          iconColor: Colors.blue,
          title: 'Update Required',
          message:
              'A new version of the app is available.\nPlease update to continue.',
          buttonText: 'Update App',
          onPressed: _openStore,
        );

      case SplashState.accountDisabled:
        return _StatusCard(
          icon: Icons.block_rounded,
          iconColor: Colors.red,
          title: 'Account Disabled',
          message:
              _accountDisabledMessage ??
              'Your account has been disabled.\nPlease contact support.',
        );

      case SplashState.loading:
      default:
        return const SizedBox.shrink();
    }
  }
}

/// ============================================================
/// BASE SPLASH LAYOUT
/// ============================================================
class _BaseSplashLayout extends StatelessWidget {
  final Widget body;
  const _BaseSplashLayout({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.appLogo, width: 280),
              const SizedBox(height: 28),
              body,
            ],
          ),
        ),
      ),
      bottomNavigationBar: Material(
        elevation: 30,
        color: AppColors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.companyLogo, height: 60),
                const SizedBox(width: 32),
                Container(height: 36, width: 1, color: AppColors.divider),
                const SizedBox(width: 32),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Support Farmers,',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Empower Communities...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// STATUS CARD (MAINTENANCE / DISABLED)
/// ============================================================
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 64, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// ACTION CARD (UPDATE)
/// ============================================================
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 64, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
