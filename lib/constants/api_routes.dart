import 'package:kb_driver/constants/app_constants.dart';

class ApiRoutes {
  static const String baseUrl = "${AppConstants.BASE_URL}/api/v1";

  static const String deliveryPrefix = "$baseUrl/delivery";
  static const String shipmentPrefix = "$deliveryPrefix/shipment";

  static const String appMeta = "$baseUrl/utils/app-meta";
  static const String userMeta = "$baseUrl/user/meta";

  // kyc

  static const String getUserKycSignedURL = "$baseUrl/kyc/signed-url";
  static const String getVehicleKycSignedURL =
      "$baseUrl/kyc/vehicle/signed-url";

  // Auth

  static const String signIn = "$baseUrl/signin";
  static const String signUpSendOtp = "$baseUrl/signup/otp/send";
  static const String signUpVerify = "$baseUrl/signup/register";

  static const String signOut = "$baseUrl/signout";
  static const String signOutAll = "$baseUrl/signout/all";

  static const String forgotPasswordSendOtp = "$baseUrl/forget/otp/send";
  static const String forgotPasswordVerify = "$baseUrl/forget/reset";

  static const String getDashboardData = "$baseUrl/dashboard";

  // Driver
  static const String getDriverOnlineStatus =
      "$deliveryPrefix/driver/online-status";
  static const String updateDriverOnlineStatus =
      "$deliveryPrefix/driver/online-status/update";
  static const String updateLastLocation =
      "$deliveryPrefix/driver/location/update";

  // Shipments
  static const String checkForNewRequests = "$shipmentPrefix/requested";
  static const String getRequestedShipments =
      "$shipmentPrefix/list/need-to-deliver";
  static const String getNeedToDeliver = "$shipmentPrefix/list/need-to-deliver";

  static const String acceptShipment = "$shipmentPrefix/accept";
  static const String rejectShipment = "$shipmentPrefix/reject";
  static const String startShipment = "$shipmentPrefix/start";
  static const String completeShipment = "$shipmentPrefix/completed";

  // update package staus
  static const String updatePkgBuyerStatus =
      "$shipmentPrefix/package/update-status/buyer";
  static const String updatePkgSellerStatus =
      "$shipmentPrefix/package/update-status/seller";
  static const String updatePkgTransferStatus =
      "$shipmentPrefix/package/update-status/transfer";

  // user profile
  static const String getProfile = "$baseUrl/user/profile";
  static const String updateProfile = "$baseUrl/user/profile/update";
  static const String updatePassword = "$baseUrl/user/profile/password";
  static const String updateAddress = "$baseUrl/user/profile/address";

  static const String getBankDetails = "$baseUrl/userBank";
  static const String updateBankDetails = "$baseUrl/userBank";

  static const String requestDeliveryOtp =
      "$shipmentPrefix/otp-request/delivery-confirmation";

  //
}
