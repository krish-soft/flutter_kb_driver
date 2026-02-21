import 'dart:async';
import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/models/auth/forgot_password_send_otp_model.dart';
import 'package:kb_driver/core/data/models/auth/forgot_password_verify_model.dart';
import 'package:kb_driver/core/data/repositories/auth/auth_repository.dart';
import 'package:kb_driver/utils/message_manager.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  var isLoading = false.obs;
  var showOtpField = false.obs;
  var resendSeconds = 0.obs;

  String phoneNumber = "";
  String requestId = "";

  Timer? _timer;

  void _startTimer() {
    resendSeconds.value = 30;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value == 0) {
        t.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  /// STEP-1 SEND OTP
  Future<void> sendOtp(String phone) async {
    phoneNumber = phone;
    isLoading.value = true;

    final res = await _repo.forgotPasswordSendOtp(
      ForgotPasswordSendOtpModel(phoneNumber: phone),
    );

    isLoading.value = false;

    if (res.isSuccess == true) {
      requestId = res.data["request_id"].toString();
      showOtpField.value = true;
      _startTimer();
      MessageManager.showSuccess(res.message.toString());
    } else {
      MessageManager.showError(res.message.toString());
    }
  }

  /// STEP-2 VERIFY
  Future<ApiResponseModel> verify({
    required String otp,
    required String password,
  }) async {
    isLoading.value = true;

    final res = await _repo.forgotPasswordVerify(
      ForgotPasswordVerifyModel(
        phoneNumber: phoneNumber,
        requestId: requestId,
        otp: otp,
        password: password,
        passwordConfirmation: password,
      ),
    );

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message.toString());
    } else {
      MessageManager.showError(res.message.toString());
    }

    return res;
  }
}
