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
    try {
      final ApiResponseModel res = await _repo.getDashboardData();

      if (res.isSuccess == true && res.data != null) {
        final data = res.data;

        final summary = data['summary'] ?? {};
        final earnings = data['earnings'] ?? {};

        totalDeliveries.value = _toInt(summary['total_deliveries']);
        requestedDeliveries.value = _toInt(summary['requested_deliveries']);
        activeDeliveries.value = _toInt(summary['active_deliveries']);

        totalRatings.value = _toInt(summary['total_ratings']);

        averageRating.value = _toDouble(summary['average_rating']);

        availableBalance.value = _toDouble(earnings['available_balance']);
        pendingBalance.value = _toDouble(earnings['pending_balance']);
      } else {
        MessageManager.showError(res.message ?? "Dashboard error");
      }
    } catch (e) {
      MessageManager.showError("Dashboard parsing error");
    }

    isLoading.value = false;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
