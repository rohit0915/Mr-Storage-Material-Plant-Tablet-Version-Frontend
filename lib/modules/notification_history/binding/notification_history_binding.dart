import 'package:get/get.dart';
import '../controller/notification_history_controller.dart';
import '../../../app/network/api_client.dart';
import '../repository/notification_repository.dart';

class NotificationHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<NotificationHistoryController>(
      () => NotificationHistoryController(
        repository: Get.find<NotificationRepository>(),
      ),
    );
  }
}
