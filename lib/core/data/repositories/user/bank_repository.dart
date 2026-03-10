import 'package:kb_driver/constants/api_routes.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/models/user/bank_model.dart';
import 'package:kb_driver/core/data/repositories/base_repository.dart';
import 'package:kb_driver/core/network/api_client.dart';

class BankRepository extends BaseRepository {
  final APIClient _api = APIClient();

  Future<ApiResponseModel> getBankDetails() {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.getBankDetails,
                method: ApiMethod.get,
                requireAuth: true,
              ))
              as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel> updateBankDetails(BankModel bankModel) {
    return execute(
      () async =>
          (await _api.request(
                url: ApiRoutes.updateBankDetails,
                method: ApiMethod.post,
                requireAuth: true,
                body: bankModel.toJson(),
              ))
              as Map<String, dynamic>,
    );
  }
}
