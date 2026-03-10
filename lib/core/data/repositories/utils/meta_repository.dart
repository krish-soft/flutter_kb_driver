import 'package:kb_driver/constants/api_routes.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/repositories/base_repository.dart';
import 'package:kb_driver/core/network/api_client.dart';

class MetaRepository extends BaseRepository {
  final APIClient _api = APIClient();

  Future<ApiResponseModel> getAppMeta() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.appMeta,
                method: ApiMethod.get,
                requireAuth: false,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> getUserMeta() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.userMeta,
                method: ApiMethod.get,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }


  // other meta related APIs can be added here
}
