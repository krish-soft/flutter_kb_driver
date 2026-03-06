import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/constants/app_images.dart';
import 'package:kb_driver/core/lang/app_strings.dart';

import 'package:kb_driver/core/data/presentation/controllers/forgot_password_controller.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';

import 'package:kb_driver/view/components/app_input_field.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/view/components/language_switcher.dart';

import 'package:kb_driver/utils/message_manager.dart';

class ForgotPasswordScreen extends StatelessWidget {
  
  ForgotPasswordScreen({super.key});

  final _mobile = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();

  final ForgotPasswordController c = Get.put(ForgotPasswordController());
  VibrateManager _vibrateManager = VibrateManager();

  // ================= SEND OTP =================
  void sendOtp() {
     _vibrateManager.vibrateButton();
    if (_mobile.text.length != 10) {
      MessageManager.showError(AppStrings.errTextInvalidMobileNumber.tr);
      return;
    }
    c.sendOtp(_mobile.text.trim());
  }

  // ================= RESEND OTP =================
  void resendOtp() {
    _vibrateManager.vibrateButton();

    if (c.resendSeconds.value == 0) {
      c.sendOtp(_mobile.text.trim());
    }
  }

  // ================= VERIFY =================
  Future<void> verify() async {
     _vibrateManager.vibrateButton();

    if (_otp.text.length != 6) {
      MessageManager.showError(AppStrings.errTextInvalidOtp.tr);
      return;
    }

    if (_password.text.length < 6) {
      MessageManager.showError(AppStrings.errTextPasswordTooShort.tr);
      return;
    }

    final res = await c.verify(
      otp: _otp.text.trim(),
      password: _password.text.trim(),
    );

    if (res.isSuccess == true) {
      Get.offNamed('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.textForgotPassword.tr,
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
              padding: const EdgeInsets.all(24),
              child: Obx(
                () => Column(
                  children: [
                    /// LOGO
                    Image.asset(AppImages.appLogo, width: 200),
                    const SizedBox(height: 24),

                    /// TITLE
                    Text(
                      AppStrings.textForgotPassword.tr,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      c.showOtpField.value
                          ? AppStrings.textEnterOtpSentToMobile.tr
                          : AppStrings.textEnterPhoneToResetPassword.tr,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    /// STEP 1 PHONE
                    if (!c.showOtpField.value) ...[
                      AppInputField(
                        controller: _mobile,
                        hint: AppStrings.textPhoneNumber.tr,
                        prefixIcon: Icons.phone,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        focusColor: AppColors.primary,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        title: AppStrings.textSendOtp.tr,
                        loading: c.isLoading.value,
                        background: AppColors.primary,
                        onPressed: sendOtp,
                      ),
                    ],

                    /// STEP 2 OTP + PASSWORD
                    if (c.showOtpField.value) ...[
                      AppInputField(
                        controller: _otp,
                        hint: AppStrings.textEnterOtp.tr,
                        prefixIcon: Icons.security,
                        maxLength: 6,

                        keyboardType: TextInputType.number,
                        focusColor: AppColors.primary,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 16),

                      AppInputField(
                        controller: _password,
                        hint: AppStrings.textNewPassword.tr,
                        prefixIcon: Icons.lock,
                        obscure: true,
                        focusColor: AppColors.primary,
                      ),
                      const SizedBox(height: 24),

                      AppButton(
                        title: AppStrings.textResetPassword.tr,
                        loading: c.isLoading.value,
                        background: AppColors.primary,
                        onPressed: verify,
                      ),

                      Obx(
                        () => TextButton(
                          onPressed: c.resendSeconds.value == 0
                              ? resendOtp
                              : null,
                          child: Text(
                            c.resendSeconds.value == 0
                                ? AppStrings.textResendOtp.tr
                                : AppStrings.textResendInSeconds.trParams({
                                    'seconds': c.resendSeconds.value.toString(),
                                  }),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
