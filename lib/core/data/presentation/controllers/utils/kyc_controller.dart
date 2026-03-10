import 'package:get/get.dart';
import 'package:kb_driver/core/data/repositories/utils/kyc_repository.dart';

class KycController extends GetxController {
  final KycRepository _repo = KycRepository();

  var isLoading = false.obs;

  Future<String?> getUserKycSignedURL() async {
    isLoading.value = true;

    final res = await _repo.getUserKycSignedURL();

    isLoading.value = false;

    if (res.isSuccess == true && res.data != null) {
      return res.data!['user_kyc_signed_url'];
    } else {
      return null;
    }
  }

  Future<String?> getVehicleKycSignedURL() async {
    isLoading.value = true;

    final res = await _repo.getVehicleKycSignedURL();

    isLoading.value = false;

    if (res.isSuccess == true && res.data != null) {
      return res.data!['vehicle_kyc_signed_url'];
    } else {
      return null;
    }
  }
}
