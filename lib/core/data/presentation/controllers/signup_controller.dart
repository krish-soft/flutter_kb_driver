import 'dart:async';
import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/models/auth/signup_model.dart';
import 'package:kb_driver/core/data/models/auth/signup_verify_model.dart';
import 'package:kb_driver/core/data/repositories/auth/auth_repository.dart';
import 'package:kb_driver/utils/message_manager.dart';

class SignUpController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  var isLoading = false.obs;
  var showOtpField = false.obs;
  var resendSeconds = 0.obs;

  String phoneNumber = "";
  String requestId = "";
  final String _role = "delivery";

  Timer? _timer;

  void startResendTimer() {
    resendSeconds.value = 30;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value == 0) {
        timer.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  Future<void> sendOtp(String phone) async {
    phoneNumber = phone;
    isLoading.value = true;

    ApiResponseModel res = await _repo.sendSignUpOtp(
      SignUpSendOtpModel(phoneNumber: phone),
    );

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message.toString());
      requestId = res.data["request_id"].toString();
      showOtpField.value = true;
      startResendTimer();
    } else {
      MessageManager.showError(res.message.toString());
    }
  }

  Future<ApiResponseModel> verify({
    required String otp,
    required String name,
    required String password,
  }) async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.verifySignUp(
      SignUpVerifyModel(
        phoneNumber: phoneNumber,
        requestId: requestId,
        otp: otp,
        name: name,
        password: password,
        passwordConfirmation: password,
        role: _role,
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
