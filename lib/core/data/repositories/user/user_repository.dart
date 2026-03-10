import 'dart:io';

import 'package:kb_driver/constants/api_routes.dart';
import 'package:kb_driver/core/data/models/user/address_model.dart';
import 'package:kb_driver/core/data/repositories/base_repository.dart';
import 'package:kb_driver/core/network/api_client.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';

class UserRepository extends BaseRepository {
  final APIClient _api = APIClient();

  Future<ApiResponseModel> getProfile() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.getProfile,
                method: ApiMethod.get,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> updateProfile({
    required String name,
    required String email,
  }) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.updateProfile,
                method: ApiMethod.post,
                requireAuth: true,
                body: {"name": name, "email": email},
              ))
              as Map<String, dynamic>,
    );
  }

  // update password
  Future<ApiResponseModel> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.updatePassword,
                method: ApiMethod.put,
                requireAuth: true,
                body: {
                  "current_password": currentPassword,
                  "new_password": newPassword,
                  "new_password_confirmation": confirmPassword,
                },
              ))
              as Map<String, dynamic>,
    );
  }

  // update address
  Future<ApiResponseModel> updateAddress({required AddressModel address}) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.updateAddress,
                method: ApiMethod.post,
                requireAuth: true,
                body: address.toJson(),
              ))
              as Map<String, dynamic>,
    );
  }

  //
}
