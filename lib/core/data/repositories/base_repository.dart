import 'package:kb_driver/core/data/models/api_response_model.dart';

class BaseRepository {
  Future<ApiResponseModel> execute(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    try {
      final Map<String, dynamic> response = await request();

      /// 🔥 IMPORTANT: pass NULL as second argument
      return ApiResponseModel.fromJson(response, null);
    } catch (e) {
      return ApiResponseModel(
        isSuccess: false,
        message: e.toString(),
        data: null,
      );
    }
  }
}
