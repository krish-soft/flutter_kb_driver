import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/repositories/driver/shipment_repository.dart';
import 'package:kb_driver/utils/message_manager.dart';

class ShipmentController extends GetxController {
  final ShipmentRepository _repo = ShipmentRepository();

  /// loading state
  var isLoading = false.obs;

  /// requested shipments
  var shipments = [].obs;

  /// active deliveries
  var activeShipments = [].obs;

  // =========================================================
  // CHECK NEW REQUESTS
  // =========================================================

  Future<ApiResponseModel> checkForNewShipmentRequests() async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.checkForNewRequests();

    isLoading.value = false;

    return res;
  }

  // =========================================================
  // LOAD REQUESTED SHIPMENTS
  // =========================================================

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

  // =========================================================
  // LOAD ACTIVE DELIVERIES
  // =========================================================

  Future<void> loadNeedToDeliverShipments() async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.getNeedToDeliverShipments();

    isLoading.value = false;

    if (res.isSuccess == true) {
      activeShipments.value = res.data ?? [];
    } else {
      MessageManager.showError(res.message.toString());
    }
  }

  // =========================================================
  // ACCEPT SHIPMENT
  // =========================================================

  Future<void> acceptShipment(int driverShipmentId) async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.acceptShipment(driverShipmentId);

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message.toString());

      /// refresh requests
      loadRequestedShipments();

      /// refresh active deliveries
      loadNeedToDeliverShipments();
    } else {
      MessageManager.showError(res.message.toString());
    }
  }

  // =========================================================
  // REJECT SHIPMENT
  // =========================================================

  Future<void> rejectShipment(int driverShipmentId) async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.rejectShipment(driverShipmentId);

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message.toString());

      /// refresh list
      loadRequestedShipments();
    } else {
      MessageManager.showError(res.message.toString());
    }
  }

  // start
  Future<void> startShipment(int driverShipmentId) async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.startShipment(driverShipmentId);

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message.toString());

      /// refresh active deliveries
      loadNeedToDeliverShipments();
    } else {
      MessageManager.showError(res.message.toString());
    }
  }

  // complete
  Future<void> completeShipment(
    int driverShipmentId,
    String proofImagePath,
  ) async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.completeShipment(
      driverShipmentId,
      proofImagePath,
    );

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message.toString());

      /// refresh active deliveries
      loadNeedToDeliverShipments();
    } else {
      MessageManager.showError(res.message.toString());
    }
  }
}
