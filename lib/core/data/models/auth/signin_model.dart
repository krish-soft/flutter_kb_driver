class SignInModel {
  
  final String phoneNumber;
  final String password;

  SignInModel({required this.phoneNumber, required this.password});

  /// Convert to API JSON body
  Map<String, dynamic> toJson() {
    return {"phone_number": phoneNumber, "password": password};
  }
}
