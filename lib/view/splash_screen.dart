import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/constants/app_images.dart';
import 'package:kb_driver/utils/app_utils.dart';
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

  SplashState _state = SplashState.loading;
  String? _maintenanceMessage;
  String? _accountDisabledMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(seconds: 2));
    Get.offAllNamed('/signin');

    // final bool isLoggedIn = await AppUtils.isUserLoggedIn();

    // try {
    //   final ApiResponseModel response = await UtilsRepo()
    //       .getMetaData(isLoggedIn)
    //       .timeout(_metaTimeout);

    //   final Map<String, dynamic> meta =
    //       (response.data as Map<String, dynamic>?) ?? {};

    //   await _storeRuntimeConfig(meta);

    //   if (!mounted) return;

    //   final app = meta['app'] ?? {};
    //   final user = meta['user'];

    //   if (app['maintenance']?['enabled'] == true) {
    //     setState(() {
    //       _maintenanceMessage = app['maintenance']?['message'];
    //       _state = SplashState.maintenance;
    //     });
    //     return;
    //   }

    //   if (app['version']?['force_update'] == true) {
    //     setState(() => _state = SplashState.forceUpdate);
    //     return;
    //   }

    //   if (user != null && user['is_active'] == false) {
    //     final String? reason = user['inactive_reason']?.toString().trim();

    //     setState(() {
    //       _accountDisabledMessage = (reason != null && reason.isNotEmpty)
    //           ? reason
    //           : 'Your account is currently disabled.\nPlease contact support.';
    //       _state = SplashState.accountDisabled;
    //     });
    //     return;
    //   }

    //   await _navigateByAuth();
    // } catch (_) {
    //   await _navigateByAuth();
    // }
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
