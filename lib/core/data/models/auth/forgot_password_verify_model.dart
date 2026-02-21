class ForgotPasswordVerifyModel {
  final String phoneNumber;
  final String requestId;
  final String otp;
  final String password;
  final String passwordConfirmation;

  ForgotPasswordVerifyModel({
    required this.phoneNumber,
    required this.requestId,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      "phone_number": phoneNumber,
      "request_id": requestId,
      "otp": otp,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };
  }
}
