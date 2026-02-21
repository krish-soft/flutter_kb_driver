import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/constants/app_images.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/core/data/presentation/controllers/signup_controller.dart';

import 'package:kb_driver/view/components/app_input_field.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/view/components/language_switcher.dart';
import 'package:kb_driver/utils/message_manager.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _mobile = TextEditingController();
  final _otp = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();

  final SignUpController c = Get.put(SignUpController());

  void sendOtp() {
    if (_mobile.text.length != 10) {
      MessageManager.showError(AppStrings.errTextInvalidMobileNumber.tr);
      return;
    }
    c.sendOtp(_mobile.text.trim());
  }

  void resendOtp() {
    if (c.resendSeconds.value == 0) {
      c.sendOtp(_mobile.text.trim());
    }
  }

  Future<void> verifyOtp() async {
    if (_otp.text.length != 6) {
      MessageManager.showError(AppStrings.errTextInvalidOtp.tr);
      return;
    }

    final res = await c.verify(
      otp: _otp.text.trim(),
      name: _name.text.trim(),
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
              padding: const EdgeInsets.all(24),
              child: Obx(
                () => Column(
                  children: [
                    Image.asset(AppImages.appLogo, width: 200),
                    const SizedBox(height: 24),

                    /// TITLE
                    Text(
                      AppStrings.textCreateAccount.tr,
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
                          : AppStrings.textSignUpUsingPhoneNumber.tr,
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

                    /// STEP 2 DETAILS
                    if (c.showOtpField.value) ...[
                      AppInputField(
                        controller: _otp,
                        hint: AppStrings.textEnterOtp.tr,
                        prefixIcon: Icons.security,
                        maxLength: 6,
                        // centerText: true,
                        keyboardType: TextInputType.number,
                        focusColor: AppColors.primary,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 16),

                      AppInputField(
                        controller: _name,
                        hint: AppStrings.textFullName.tr,
                        prefixIcon: Icons.person,
                        focusColor: AppColors.primary,
                      ),
                      const SizedBox(height: 16),

                      AppInputField(
                        controller: _password,
                        hint: AppStrings.textPassword.tr,
                        prefixIcon: Icons.lock,
                        obscure: true,
                        focusColor: AppColors.primary,
                      ),
                      const SizedBox(height: 24),

                      AppButton(
                        title: AppStrings.textVerifyOtp.tr,
                        loading: c.isLoading.value,
                        background: AppColors.primary,
                        onPressed: verifyOtp,
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

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.textAlreadyHaveAccount.tr),
                        TextButton(
                          onPressed: () => Get.offNamed('/signin'),
                          child: Text(AppStrings.textSignin.tr),
                        ),
                      ],
                    ),
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
