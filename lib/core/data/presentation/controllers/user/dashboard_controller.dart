import 'package:get/get.dart';
import 'package:kb_driver/core/data/models/api_response_model.dart';
import 'package:kb_driver/core/data/repositories/user/dashboard_repository.dart';
import 'package:kb_driver/utils/message_manager.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repo = DashboardRepository();

  var isLoading = true.obs;

  var totalDeliveries = 0.obs;
  var requestedDeliveries = 0.obs;
  var activeDeliveries = 0.obs;


  var totalRatings = 0.obs;
  var averageRating = 0.0.obs;

  var availableBalance = 0.0.obs;
  var pendingBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    getDashboardData();
  }

  Future<void> getDashboardData() async {
    final ApiResponseModel res = await _repo.getDashboardData();

    if (res.isSuccess == true) {
      final data = res.data;

      totalDeliveries.value = data['summary']['total_deliveries'] ?? 0;
      requestedDeliveries.value = data['summary']['requested_deliveries'] ?? 0;
      activeDeliveries.value = data['summary']['active_deliveries'] ?? 0;

      totalRatings.value = data['summary']['total_ratings'] ?? 0;

      averageRating.value = (data['summary']['average_rating'] ?? 0).toDouble();

      if (data['earnings'] != null) {
        availableBalance.value = (data['earnings']['available_balance'] ?? 0)
            .toDouble();

        pendingBalance.value = (data['earnings']['pending_balance'] ?? 0)
            .toDouble();
      }
    } else {
      MessageManager.showError(res.message ?? "Dashboard error");
    }

    isLoading.value = false;
  }
}
