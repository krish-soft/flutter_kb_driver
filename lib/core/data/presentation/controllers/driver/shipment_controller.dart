import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/presentation/controllers/user/dashboard_controller.dart';
import 'package:kb_driver/core/data/repositories/driver/shipment_repository.dart';
import 'package:kb_driver/core/services/location_service.dart';
import 'package:kb_driver/utils/message_manager.dart';

class ShipmentController extends GetxController {
  final ShipmentRepository _repo = ShipmentRepository();

  final DashboardController _dashboardController = Get.put<DashboardController>(
    DashboardController(),
  );

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

  // refresh dashboard data
  void refreshDashboard() {
    _dashboardController.getDashboardData();
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
      MessageManager.showError(res.message);
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
      MessageManager.showError(res.message);
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
      // MessageManager.showSuccess(res.message);

      /// refresh requests
      loadRequestedShipments();

      /// refresh active deliveries
      loadNeedToDeliverShipments();

      /// refresh dashboard
      refreshDashboard();
    } else {
      MessageManager.showError(res.message);
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
      // MessageManager.showSuccess(res.message);

      /// refresh list
      loadRequestedShipments();

      /// refresh dashboard
      refreshDashboard();
    } else {
      MessageManager.showError(res.message);
    }
  }

  // start
  Future<void> startShipment(int driverShipmentId) async {
    isLoading.value = true;

    ApiResponseModel res = await _repo.startShipment(driverShipmentId);

    isLoading.value = false;

    if (res.isSuccess == true) {
      // MessageManager.showSuccess(res.message);

      /// refresh active deliveries
      loadNeedToDeliverShipments();
    } else {
      MessageManager.showError(res.message);
    }
  }

  // complete
  Future<ApiResponseModel> completeShipment(
    int driverShipmentId,
    String proofImagePath,
    String? otp,
    String? requestId,
  ) async {
    isLoading.value = true;

    double? lat = null;
    double? lng = null;

    try {
      // Get Location
      final position = await DriverLocationService.getCurrentLocation();

      if (position != null) {
         lat = position.latitude;
         lng = position.longitude;
      }
    } catch (e) {
      // print("Location error: $e");
    }

    ApiResponseModel res = await _repo.completeShipment(
      driverShipmentId,
      proofImagePath,
      otp,
      requestId,
      lat,
      lng,
    );

    isLoading.value = false;

    if (res.isSuccess == true) {
      // MessageManager.showSuccess(res.message);

      /// refresh active deliveries
      loadNeedToDeliverShipments();

      /// refresh dashboard
      refreshDashboard();
    } else {
      MessageManager.showError(res.message);
    }

    return res;
  }

  // Package status update (pickup/delivery)
  Future<ApiResponseModel> updatePkgStatus(
    int driverShipmentId,
    int shipmentPackageId,
    String status,
  ) async {
    isLoading.value = true;

    final Map<String, dynamic> payload = {
      'driver_shipment_id': driverShipmentId,
      'shipment_package_id': shipmentPackageId,
      'status': status,
    };

    ApiResponseModel res = await _repo.updatePkgStatus(payload);

    isLoading.value = false;

    if (res.isSuccess == true) {
      // MessageManager.showSuccess(res.message);

      /// refresh active deliveries
      loadNeedToDeliverShipments();
    } else {
      MessageManager.showError(res.message);
    }

    return res;
  }

  Future<ApiResponseModel> updatePkgStatusBulk(
    int driverShipmentId,
    List<int> shipmentPackageIds,
    String status,
  ) async {
    if (shipmentPackageIds.isEmpty) {
      return ApiResponseModel(
        isSuccess: false,
        message: 'No package selected.',
      );
    }

    isLoading.value = true;

    int successCount = 0;
    int failureCount = 0;
    String? firstFailureMessage;

    for (final shipmentPackageId in shipmentPackageIds) {
      final Map<String, dynamic> payload = {
        'driver_shipment_id': driverShipmentId,
        'shipment_package_id': shipmentPackageId,
        'status': status,
      };

      ApiResponseModel res = await _repo.updatePkgStatus(payload);

      if (res.isSuccess == true) {
        successCount++;
      } else {
        failureCount++;
        firstFailureMessage ??= res.message?.toString();
      }
    }

    isLoading.value = false;

    if (successCount > 0) {
      loadNeedToDeliverShipments();
    }

    if (failureCount == 0) {
      return ApiResponseModel(
        isSuccess: true,
        message: 'Updated status for $successCount package(s).',
        data: {
          'successCount': successCount,
          'failureCount': failureCount,
        },
      );
    }

    return ApiResponseModel(
      isSuccess: successCount > 0,
      message:
          firstFailureMessage ?? 'Some package statuses could not be updated.',
      data: {
        'successCount': successCount,
        'failureCount': failureCount,
      },
    );
  }

  // Future<ApiResponseModel> updatePkgBuyerStatus(
  //   int driverShipmentId,
  //   int shipmentPackageId,
  //   String status,
  // ) async {
  //   isLoading.value = true;

  //   final Map<String, dynamic> payload = {
  //     'driver_shipment_id': driverShipmentId,
  //     'shipment_package_id': shipmentPackageId,
  //     'status': status,
  //   };

  //   ApiResponseModel res = await _repo.updatePkgBuyerStatus(payload);

  //   isLoading.value = false;

  //   if (res.isSuccess == true) {
  //     // MessageManager.showSuccess(res.message);

  //     /// refresh active deliveries
  //     loadNeedToDeliverShipments();
  //   } else {
  //     MessageManager.showError(res.message);
  //   }

  //   return res;
  // }

  // Future<ApiResponseModel> updatePkgSellerStatus(
  //   int driverShipmentId,
  //   int shipmentPackageId,
  //   String status,
  // ) async {
  //   isLoading.value = true;

  //   final Map<String, dynamic> payload = {
  //     'driver_shipment_id': driverShipmentId,
  //     'shipment_package_id': shipmentPackageId,
  //     'status': status,
  //   };

  //   ApiResponseModel res = await _repo.updatePkgSellerStatus(payload);

  //   isLoading.value = false;

  //   if (res.isSuccess == true) {
  //     // MessageManager.showSuccess(res.message);

  //     /// refresh active deliveries
  //     loadNeedToDeliverShipments();
  //   } else {
  //     MessageManager.showError(res.message);
  //   }

  //   return res;
  // }

  // Future<ApiResponseModel> updatePkgTransferStatus(
  //   int driverShipmentId,
  //   int shipmentPackageId,
  //   String status,
  // ) async {
  //   isLoading.value = true;

  //   final Map<String, dynamic> payload = {
  //     'driver_shipment_id': driverShipmentId,
  //     'shipment_package_id': shipmentPackageId,
  //     'status': status,
  //   };

  //   ApiResponseModel res = await _repo.updatePkgTransferStatus(payload);

  //   isLoading.value = false;

  //   if (res.isSuccess == true) {
  //     // MessageManager.showSuccess(res.message);

  //     /// refresh active deliveries
  //     loadNeedToDeliverShipments();
  //   } else {
  //     MessageManager.showError(res.message);
  //   }

  //   return res;
  // }

  //  request delivery confirmation OTP for buyer
  Future<ApiResponseModel> requestDeliveryConfirmationOtp(
    int driverShipmentId,
  ) async {
    isLoading.value = true;

    final Map<String, dynamic> payload = {
      'driver_shipment_id': driverShipmentId,
    };

    ApiResponseModel res = await _repo.requestDeliveryConfirmationOtp(payload);

    isLoading.value = false;

    if (res.isSuccess == true) {
      MessageManager.showSuccess(res.message);
    } else {
      MessageManager.showError(res.message);
    }

    return res;
  }

  //
}
