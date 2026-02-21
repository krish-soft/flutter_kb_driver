// lib/core/data/models/auth/signup_verify_model.dart

class SignUpVerifyModel {
  final String phoneNumber;
  final String requestId;
  final String otp;
  final String name;
  final String password;
  final String passwordConfirmation;
  final String role;

  SignUpVerifyModel({
    required this.phoneNumber,
    required this.requestId,
    required this.otp,
    required this.name,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      "phone_number": phoneNumber,
      "request_id": requestId,
      "otp": otp,
      "name": name,
      "password": password,
      "password_confirmation": passwordConfirmation,
      "role": role,
    };
  }
}
