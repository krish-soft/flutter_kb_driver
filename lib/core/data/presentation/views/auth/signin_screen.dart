import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/constants/app_images.dart';
import 'package:kb_driver/core/data/presentation/controllers/auth_controller.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/utils/preference_manager.dart';

import 'package:kb_driver/view/components/app_input_field.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/utils/message_manager.dart';
import 'package:kb_driver/view/components/language_switcher.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthController _authController = Get.put(AuthController());

  bool _obscurePassword = true;

  // =====================================================
  // SIGN IN ACTION
  // =====================================================
  Future<void> _signIn() async {
    if (_mobileController.text.length != 10) {
      MessageManager.showError(AppStrings.errTextInvalidMobileNumber.tr);
      return;
    }

    if (_passwordController.text.isEmpty) {
      MessageManager.showError(AppStrings.errTextPasswordRequired.tr);
      return;
    }

    final res = await _authController.signIn(
      phoneNumber: _mobileController.text.trim(),
      password: _passwordController.text.trim(),
    );

    /// 🔥 navigate on success
    if (res.isSuccess == false) {
      return;
    }

    PreferenceManager.setAccessToken(res.data?['access_token']);
    PreferenceManager.setTokenExpiryTime(
      res.data!['expires_in_minutes'].toString(),
    );
    PreferenceManager.setDeviceId(res.data?['device_id']);

    // Need to pull its

    // 👉 redirect to home using GetX
    Get.offAllNamed('/home');
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.textSignin.tr,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [LanguageSwitcher()],
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  /// ================= LOGO =================
                  Image.asset(AppImages.appLogo, width: 200),

                  const SizedBox(height: 28),

                  /// ================= TITLE =================
                  Text(
                    // 'Sign In',
                    AppStrings.textSignin.tr,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    // 'Login using your phone number and password',
                    AppStrings.textSigninSubtitle.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  /// ================= PHONE FIELD =================
                  AppInputField(
                    controller: _mobileController,
                    hint: AppStrings.textPhoneNumber.tr,
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    focusColor: AppColors.primary,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  const SizedBox(height: 20),

                  /// ================= PASSWORD FIELD =================
                  AppInputField(
                    controller: _passwordController,
                    hint: AppStrings.textPassword.tr,
                    prefixIcon: Icons.lock,
                    obscure: _obscurePassword,
                    focusColor: AppColors.primary,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// ================= SIGN IN BUTTON =================
                  Obx(
                    () => AppButton(
                      title: AppStrings.textSignin.tr,
                      loading: _authController.isLoading.value,
                      background: AppColors.primary,
                      onPressed: _signIn,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ================= ACTION LINKS =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.toNamed('/forgot-password');
                        },
                        child: Text(
                          AppStrings.textForgotPassword.tr,
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.offAllNamed('/signup');
                        },
                        child: Text(
                          AppStrings.textSignup.tr,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
