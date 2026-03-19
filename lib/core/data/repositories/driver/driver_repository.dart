import 'package:kb_driver/constants/api_routes.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/repositories/base_repository.dart';
import 'package:kb_driver/core/network/api_client.dart';

class DriverRepository extends BaseRepository {
  final APIClient _api = APIClient();

  ///  Status
  Future<ApiResponseModel> getDriverOnlineStatus() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.getDriverOnlineStatus,
                method: ApiMethod.get,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> updateDriverOnlineStatus(bool isOnline) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.updateDriverOnlineStatus,
                method: ApiMethod.post,
                body: {"is_available_for_delivery": isOnline},
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

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

  Future<ApiResponseModel> updateLastLocation(payload) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.updateLastLocation,
                method: ApiMethod.post,
                body: payload,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  //
}
