import 'package:kb_driver/utils/preference_manager.dart';
import 'package:get/get.dart';

class DriverStatusController extends GetxController {
  var isOnline = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatus();
  }

  void loadStatus() {
    isOnline.value = PreferenceManager.getIsDriverOnline();
  }

  void updateStatus(bool value) {
    PreferenceManager.setIsDriverOnline(value);
    isOnline.value = value;
  }
}
