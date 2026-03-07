import 'package:kb_driver/constants/app_constants.dart';

class ApiRoutes {
  static const String baseUrl = "${AppConstants.BASE_URL}/api/v1";

  static const String deliveryPrefix = "$baseUrl/delivery";
  static const String shipmentPrefix = "$deliveryPrefix/shipment";

  // Auth

  static const String signIn = "$baseUrl/signin";
  static const String signUpSendOtp = "$baseUrl/signup/otp/send";
  static const String signUpVerify = "$baseUrl/signup/register";

  static const String forgotPasswordSendOtp = "$baseUrl/forget/otp/send";
  static const String forgotPasswordVerify = "$baseUrl/forget/reset";

  // Driver
  static const String getDriverOnlineStatus =
      "$deliveryPrefix/driver/online-status";
  static const String updateDriverOnlineStatus =
      "$deliveryPrefix/driver/online-status/update";

  // Shipments
  static const String checkForNewRequests = "$shipmentPrefix/requested";
  static const String getRequestedShipments =
      "$shipmentPrefix/list/need-to-deliver";
  static const String getNeedToDeliver = "$shipmentPrefix/list/need-to-deliver";

  static const String acceptShipment = "$shipmentPrefix/accept";
  static const String rejectShipment = "$shipmentPrefix/reject";
  static const String startShipment = "$shipmentPrefix/start";
  static const String completeShipment = "$shipmentPrefix/complete";

  // update package staus
  static const String updatePkgBuyerStatus =
      "$shipmentPrefix/package/update-status/buyer";
  static const String updatePkgSellerStatus =
      "$shipmentPrefix/package/update-status/seller";
  static const String updatePkgTransferStatus =
      "$shipmentPrefix/package/update-status/transfer";

  //
}
