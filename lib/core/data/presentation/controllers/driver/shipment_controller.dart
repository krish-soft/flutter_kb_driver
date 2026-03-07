import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/repositories/driver/shipment_repository.dart';
import 'package:kb_driver/utils/message_manager.dart';

class ShipmentController extends GetxController {
  
  final ShipmentRepository _repo = ShipmentRepository();

  var isLoading = false.obs;
  var shipments = [].obs;

  Future<ApiResponseModel> checkForNewShipmentRequests() async {
    isLoading.value = true;
    ApiResponseModel res = await _repo.checkForNewRequests();

    isLoading.value = false;

    // no meesage becasue backend service
    // if (res.isSuccess == true) {
    //   MessageManager.showSuccess(res.message.toString());
    // } else {
    //   MessageManager.showError(res.message.toString());
    // }

    return res;
  }

  Future<ApiResponseModel> getRequestedShipments() async {
    isLoading.value = true;
    ApiResponseModel res = await _repo.getRequestedShipments();
    isLoading.value = false;
    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message.toString());
    } else {
      MessageManager.showError(res.message.toString());
    }

    return res;
  }

  Future<void> loadRequestedShipments() async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.getRequestedShipments();

    isLoading.value = false;

    if (res.isSuccess == true) {
      shipments.value = res.data ?? [];
    } else {
      MessageManager.showError(res.message.toString());
    }
  }

  Future<void> acceptShipment(int driverShipmentId) async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.acceptShipment(driverShipmentId);

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message.toString());
      loadRequestedShipments();
    } else {
      MessageManager.showError(res.message.toString());
    }
  }

  Future<void> rejectShipment(int driverShipmentId) async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.rejectShipment(driverShipmentId);

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message.toString());
      loadRequestedShipments();
    } else {
      MessageManager.showError(res.message.toString());
    }
  }

  //
}
