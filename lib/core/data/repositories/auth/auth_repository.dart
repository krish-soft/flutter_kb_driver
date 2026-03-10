import 'package:kb_driver/constants/api_routes.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/models/auth/forgot_password_send_otp_model.dart';
import 'package:kb_driver/core/data/models/auth/forgot_password_verify_model.dart';
import 'package:kb_driver/core/data/models/auth/signin_model.dart';
import 'package:kb_driver/core/data/models/auth/signup_model.dart';
import 'package:kb_driver/core/data/models/auth/signup_verify_model.dart';
import 'package:kb_driver/core/data/repositories/base_repository.dart';
import 'package:kb_driver/core/network/api_client.dart';

class AuthRepository extends BaseRepository {
  final APIClient _api = APIClient();

  /// ================= SIGN IN =================
  Future<ApiResponseModel> signIn(SignInModel model) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.signIn,
                method: ApiMethod.post,
                body: model.toJson(),
              ))
              as Map<String, dynamic>,
    );
  }

  /// ================= STEP-1 SEND OTP =================
  Future<ApiResponseModel> sendSignUpOtp(SignUpSendOtpModel model) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.signUpSendOtp,
                method: ApiMethod.post,
                body: model.toJson(),
              ))
              as Map<String, dynamic>,
    );
  }

  /// ================= STEP-2 VERIFY =================
  Future<ApiResponseModel> verifySignUp(SignUpVerifyModel model) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.signUpVerify,
                method: ApiMethod.post,
                body: model.toJson(),
              ))
              as Map<String, dynamic>,
    );
  }

  /// ================= FORGOT PASSWORD SEND OTP =================
  Future<ApiResponseModel> forgotPasswordSendOtp(
    ForgotPasswordSendOtpModel model,
  ) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.forgotPasswordSendOtp,
                method: ApiMethod.post,
                body: model.toJson(),
              ))
              as Map<String, dynamic>,
    );
  }

  /// ================= FORGOT PASSWORD VERIFY =================
  Future<ApiResponseModel> forgotPasswordVerify(
    ForgotPasswordVerifyModel model,
  ) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.forgotPasswordVerify,
                method: ApiMethod.post,
                body: model.toJson(),
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> signOutAll() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.signOutAll,
                method: ApiMethod.post,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  //
}
