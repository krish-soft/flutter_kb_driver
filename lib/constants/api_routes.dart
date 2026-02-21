import 'package:kb_driver/constants/app_constants.dart';

class ApiRoutes {
  static const String baseUrl = "${AppConstants.BASE_URL}/api/v1";

  // Auth

  static const String signIn = "$baseUrl/signin";
  static const String signUpSendOtp = "$baseUrl/signup/otp/send";
  static const String signUpVerify = "$baseUrl/signup/register";

  static const String forgotPasswordSendOtp = "$baseUrl/forget/otp/send";
  static const String forgotPasswordVerify = "$baseUrl/forget/reset";

  //
}
