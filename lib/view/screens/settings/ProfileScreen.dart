import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/data/models/user/address_model.dart';
import 'package:kb_driver/core/data/presentation/controllers/user/user_controller.dart';
import 'package:kb_driver/core/lang/app_strings.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';

import 'package:kb_driver/view/components/app_input_field.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/view/components/language_switcher.dart';

import 'package:kb_driver/utils/message_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final VibrateManager _vibrateManager = VibrateManager();

  final UserController _controller = Get.put(UserController());

  final profileData = {}.obs;

  /// PROFILE
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();

  /// PASSWORD
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  /// ADDRESS
  final _addrName = TextEditingController();
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _village = TextEditingController();
  final _taluka = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController(text: "Gujarat");
  final _postal = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  double latitude = 0;
  double longitude = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// LOAD PROFILE
  void _init() async {
    final res = await _controller.getProfile();

    if (res.isSuccess == true && res.data != null) {
      profileData.value = res.data!;

      _name.text = res.data!['name'] ?? '';
      _mobile.text = res.data!['phone_number'] ?? '';
      _email.text = res.data!['email'] ?? '';

      final addr = res.data!['address'];

      if (addr != null) {
        _addrName.text = addr['addr_name'] ?? '';
        _address1.text = addr['address_line1'] ?? '';
        _address2.text = addr['address_line2'] ?? '';
        _village.text = addr['village'] ?? '';
        _taluka.text = addr['taluka'] ?? '';
        _city.text = addr['city'] ?? '';
        _postal.text = addr['postal_code'] ?? '';

        latitude = (addr['latitude'] ?? 0).toDouble();
        longitude = (addr['longitude'] ?? 0).toDouble();
      }
    }
  }

  /// CONFIRM DIALOG
  Future<void> _confirm({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    _vibrateManager.vibrateButton();
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              _vibrateManager.vibrateButton();
              Get.back();
            },
            child: Text(AppStrings.textCancel.tr),
          ),
          ElevatedButton(
            onPressed: () {
              _vibrateManager.vibrateButton();
              Get.back();
              onConfirm();
            },
            child: Text(AppStrings.textConfirm.tr),
          ),
        ],
      ),
    );
  }

  /// UPDATE PROFILE
  void updateProfile() {
    _vibrateManager.vibrateButton();
    if (_email.text.trim().isEmpty) {
      MessageManager.showError(AppStrings.textEmailRequired.tr);
      return;
    }

    _confirm(
      title: AppStrings.textUpdateProfile.tr,
      message: AppStrings.textUpdateProfileMessage.tr,
      onConfirm: () {
        _controller.updateProfile(name: _name.text, email: _email.text.trim());
      },
    );
  }

  /// UPDATE PASSWORD
  void updatePassword() {
    _vibrateManager.vibrateButton();
    if (_currentPassword.text.isEmpty) {
      MessageManager.showError(AppStrings.textCurrentPasswordRequired.tr);
      return;
    }

    if (_newPassword.text.length < 8) {
      MessageManager.showError(AppStrings.textPasswordTooShort.tr);
      return;
    }

    if (_confirmPassword.text != _newPassword.text) {
      MessageManager.showError(AppStrings.textPasswordConfirmationMismatch.tr);
      return;
    }

    _confirm(
      title: AppStrings.textChangePassword.tr,
      message: AppStrings.textChangePasswordMessage.tr,
      onConfirm: () {
        _controller.updatePassword(
          currentPassword: _currentPassword.text,
          newPassword: _newPassword.text,
          confirmPassword: _confirmPassword.text, // IMPORTANT
        );
      },
    );
  }

  /// UPDATE ADDRESS
  void updateAddress() {
    _vibrateManager.vibrateButton();

    if (_addrName.text.isEmpty ||
        _address1.text.isEmpty ||
        _city.text.isEmpty ||
        _postal.text.isEmpty) {
      MessageManager.showError(AppStrings.textEmailRequired.tr);
      return;
    }

    _confirm(
      title: AppStrings.textUpdateProfile.tr,
      message: AppStrings.textUpdateProfileMessage.tr,
      onConfirm: () {
        final address = AddressModel(
          addrName: _addrName.text,
          addressLine1: _address1.text,
          addressLine2: _address2.text,
          village: _village.text,
          taluka: _taluka.text,
          city: _city.text,
          state: _state.text,
          postalCode: _postal.text,
          latitude: latitude,
          longitude: longitude,
        );

        _controller.updateAddress(address: address);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.textProfile.tr,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [LanguageSwitcher()],
      ),

      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),

            child: Obx(() {
              if (_controller.isLoading.value && profileData.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    _profileCard(),
                    const SizedBox(height: 16),

                    _passwordCard(),
                    const SizedBox(height: 16),

                    _addressCard(),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.textProfileInformation.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            AppInputField(
              controller: _name,
              hint: AppStrings.textFullName.tr,
              prefixIcon: Icons.person,
              enabled: false,
            ),

            const SizedBox(height: 12),

            AppInputField(
              controller: _mobile,
              hint: AppStrings.textMobile.tr,
              prefixIcon: Icons.phone,
              enabled: false,
            ),

            const SizedBox(height: 12),

            AppInputField(
              controller: _email,
              hint: AppStrings.textEmail.tr,
              prefixIcon: Icons.email,
            ),

            const SizedBox(height: 16),

            AppButton(
              title: AppStrings.textUpdateProfile.tr,
              loading: _controller.isLoading.value,
              background: AppColors.primary,
              onPressed: updateProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.textChangePassword.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            AppInputField(
              controller: _currentPassword,
              hint: AppStrings.textCurrentPasswordRequired.tr,
              prefixIcon: Icons.lock,
              obscure: !_showCurrentPassword,
              suffix: IconButton(
                icon: Icon(
                  _showCurrentPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showCurrentPassword = !_showCurrentPassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            AppInputField(
              controller: _newPassword,
              hint: AppStrings.textNewPassword.tr,
              prefixIcon: Icons.lock_outline,
              obscure: !_showNewPassword,
              suffix: IconButton(
                icon: Icon(
                  _showNewPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showNewPassword = !_showNewPassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            AppInputField(
              controller: _confirmPassword,
              hint: AppStrings.textConfirmNewPassword.tr,
              prefixIcon: Icons.lock_reset,
              obscure: !_showConfirmPassword,
              suffix: IconButton(
                icon: Icon(
                  _showConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            AppButton(
              title: AppStrings.textUpdatePassword.tr,
              loading: _controller.isLoading.value,
              background: AppColors.primary,
              onPressed: updatePassword,
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.textAddress.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            AppInputField(
              controller: _addrName,
              hint: AppStrings.textAddressName.tr,
              prefixIcon: Icons.home,
            ),
            const SizedBox(height: 12),

            AppInputField(
              controller: _address1,
              hint: AppStrings.textAddressLine1.tr,
              prefixIcon: Icons.home,
            ),
            const SizedBox(height: 12),

            AppInputField(
              controller: _address2,
              hint: AppStrings.textAddressLine2.tr,
              prefixIcon: Icons.home_outlined,
            ),
            const SizedBox(height: 12),

            AppInputField(
              controller: _village,
              hint: AppStrings.textVillage.tr,
              prefixIcon: Icons.location_city,
            ),
            const SizedBox(height: 12),

            AppInputField(
              controller: _taluka,
              hint: AppStrings.textTaluka.tr,
              prefixIcon: Icons.map,
            ),
            const SizedBox(height: 12),

            AppInputField(
              controller: _city,
              hint: AppStrings.textCity.tr,
              prefixIcon: Icons.location_city,
            ),
            const SizedBox(height: 12),

            AppInputField(
              controller: _state,
              hint: AppStrings.textState.tr,
              prefixIcon: Icons.map_outlined,
              enabled: false,
            ),
            const SizedBox(height: 12),

            AppInputField(
              controller: _postal,
              hint: AppStrings.textPostalCode.tr,
              prefixIcon: Icons.pin_drop,
            ),

            const SizedBox(height: 16),

            AppButton(
              title: AppStrings.textUpdateAddress.tr,
              loading: _controller.isLoading.value,
              background: AppColors.primary,
              onPressed: updateAddress,
            ),
          ],
        ),
      ),
    );
  }
}
