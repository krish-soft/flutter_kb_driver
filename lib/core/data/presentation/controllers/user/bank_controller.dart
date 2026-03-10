import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/models/user/bank_model.dart';
import 'package:kb_driver/core/data/repositories/user/bank_repository.dart';
import 'package:kb_driver/utils/message_manager.dart';

class BankController extends GetxController {
  BankRepository _repo = BankRepository();

  var isLoading = false.obs;

  Future<ApiResponseModel> getBankDetails() async {
    isLoading.value = true;

    final res = await _repo.getBankDetails();

    isLoading.value = false;

    return res;
  }

  Future<ApiResponseModel> updateBankDetails(BankModel bankModel) async {
    isLoading.value = true;

    final res = await _repo.updateBankDetails(bankModel);

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
}
