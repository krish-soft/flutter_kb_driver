import 'dart:io';

import 'package:kb_driver/constants/api_routes.dart';
import 'package:kb_driver/core/data/repositories/base_repository.dart';
import 'package:kb_driver/core/network/api_client.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';

class DashboardRepository extends BaseRepository {
  final APIClient _api = APIClient();

  Future<ApiResponseModel> getDashboardData() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.getDashboardData,
                method: ApiMethod.get,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }
}
