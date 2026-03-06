import 'package:kb_driver/constants/app_constants.dart';

class ApiRoutes {
  static const String baseUrl = "${AppConstants.BASE_URL}/api/v1";

  static const String deliveryPrfix = "$baseUrl/delivery";

  // Auth

  static const String signIn = "$baseUrl/signin";
  static const String signUpSendOtp = "$baseUrl/signup/otp/send";
  static const String signUpVerify = "$baseUrl/signup/register";

  static const String forgotPasswordSendOtp = "$baseUrl/forget/otp/send";
  static const String forgotPasswordVerify = "$baseUrl/forget/reset";

  // Driver
    static const String getDriverOnlineStatus = "$deliveryPrfix/driver/online-status";
    static const String updateDriverOnlineStatus = "$deliveryPrfix/driver/online-status/update";


  //
}
