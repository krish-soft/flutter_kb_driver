import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/repositories/driver/driver_repository.dart';
import 'package:kb_driver/utils/message_manager.dart';

class DriverController extends GetxController {
  final DriverRepository _repo = DriverRepository();

  var isLoading = false.obs;

  /// ================= SIGN IN =================
  Future<ApiResponseModel> getDriverOnlineStatus() async {
    isLoading.value = true;
    ApiResponseModel res = await _repo.getDriverOnlineStatus();

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res!.message.toString());
    } else {
      MessageManager.showError(res!.message.toString());
    }

    return res;
  }

  Future<ApiResponseModel> updateDriverOnlineStatus(bool isOnline) async {
    isLoading.value = true;
    ApiResponseModel res = await _repo.updateDriverOnlineStatus(isOnline);

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res!.message.toString());
    } else {
      MessageManager.showError(res!.message.toString());
    }

    return res;
  }

  //
}
