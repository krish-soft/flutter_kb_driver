import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/user/address_model.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/repositories/user/user_repository.dart';
import 'package:kb_driver/utils/message_manager.dart';

class UserController extends GetxController {
  final UserRepository _repo = UserRepository();

  var isLoading = false.obs;

  Future<ApiResponseModel> getProfile() async {
    isLoading.value = true;

    final res = await _repo.getProfile();

    isLoading.value = false;

    return res;
  }

  Future<ApiResponseModel> updateProfile({
    required String name,
    required String email,
  }) async {
    isLoading.value = true;

    final res = await _repo.updateProfile(name: name, email: email);

    if (res.message != null && res.message.toString().isNotEmpty) {
      if (res.isSuccess == true) {
        MessageManager.showSuccess(res.message.toString());
      } else {
        MessageManager.showError(res.message.toString());
      }
    }

    isLoading.value = false;

    return res;
  }

  // update password
  Future<ApiResponseModel> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading.value = true;

    final res = await _repo.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (res.message != null && res.message.toString().isNotEmpty) {
      if (res.isSuccess == true) {
        MessageManager.showSuccess(res.message.toString());
      } else {
        MessageManager.showError(res.message.toString());
      }
    }

    isLoading.value = false;

    return res;
  }

  // update address
  Future<ApiResponseModel> updateAddress({
    required AddressModel address,
  }) async {
    isLoading.value = true;

    final res = await _repo.updateAddress(address: address);

    if (res.message != null && res.message.toString().isNotEmpty) {
      if (res.isSuccess == true) {
        MessageManager.showSuccess(res.message.toString());
      } else {
        MessageManager.showError(res.message.toString());
      }
    }

    isLoading.value = false;

    return res;
  }

  //
}
