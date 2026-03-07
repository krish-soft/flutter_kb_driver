import 'dart:io';

import 'package:kb_driver/constants/api_routes.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/repositories/base_repository.dart';
import 'package:kb_driver/core/network/api_client.dart';

class ShipmentRepository extends BaseRepository {
  final APIClient _api = APIClient();

  // check requested
  Future<ApiResponseModel> checkForNewRequests() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.checkForNewRequests,
                method: ApiMethod.get,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> getRequestedShipments() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.getRequestedShipments,
                method: ApiMethod.get,
                requireAuth: true,
                queryParams: {
                  "status": "requested",
                }, // because we want only requested shipments
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> getNeedToDeliverShipments() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.getNeedToDeliver,
                method: ApiMethod.get,
                requireAuth: true,
                queryParams: {"status_not_in": "requested"},
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> acceptShipment(int driverShipmentId) {
    return execute(
      () async =>
          (await _api.request(
                url: "${ApiRoutes.acceptShipment}/$driverShipmentId",
                method: ApiMethod.post,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> rejectShipment(int driverShipmentId) {
    return execute(
      () async =>
          (await _api.request(
                url: "${ApiRoutes.rejectShipment}/$driverShipmentId",
                method: ApiMethod.post,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> startShipment(int driverShipmentId) {
    return execute(
      () async =>
          (await _api.request(
                url: "${ApiRoutes.startShipment}/$driverShipmentId",
                method: ApiMethod.post,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> completeShipment(
    int driverShipmentId,
    String proofImagePath,
  ) {
    return execute(
      () async =>
          (await _api.request(
                url: "${ApiRoutes.completeShipment}/$driverShipmentId",
                method: ApiMethod.post,

                /// NORMAL FIELDS
                body: {},

                /// FILES
                files: {"proof_image": File(proofImagePath)},

                /// IMPORTANT
                bodyType: BodyType.multipart,

                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  // package status update methods will be here in future

  Future<ApiResponseModel> updatePkgBuyerStatus(payload) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.updatePkgBuyerStatus,
                method: ApiMethod.post,
                body: payload,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> updatePkgSellerStatus(payload) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.updatePkgSellerStatus,
                method: ApiMethod.post,
                body: payload,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> updatePkgTransferStatus(payload) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.updatePkgTransferStatus,
                method: ApiMethod.post,
                body: payload,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  //
}
