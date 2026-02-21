class SignUpSendOtpModel {
  final String phoneNumber;

  SignUpSendOtpModel({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {"phone_number": phoneNumber};
  }
}
