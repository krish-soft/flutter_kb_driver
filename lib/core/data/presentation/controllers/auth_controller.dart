import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/models/auth/signin_model.dart';
import 'package:kb_driver/core/data/repositories/auth/auth_repository.dart';
import 'package:kb_driver/utils/message_manager.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  var isLoading = false.obs;

  /// ================= SIGN IN =================
  Future<ApiResponseModel> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    isLoading.value = true;

    final res = await _repo.signIn(
      SignInModel(phoneNumber: phoneNumber, password: password),
    );

    isLoading.value = false;

    if (res.message != null && res.message.toString().isNotEmpty) {
      if (res.isSuccess == true) {
        MessageManager.showSuccess(res.message.toString());
      } else {
        MessageManager.showError(res.message.toString());
      }
    }

    return res;
  }

  //
}
