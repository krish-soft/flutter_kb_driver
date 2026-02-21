class ForgotPasswordSendOtpModel {
  final String phoneNumber;

  ForgotPasswordSendOtpModel({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {"phone_number": phoneNumber};
  }
}
