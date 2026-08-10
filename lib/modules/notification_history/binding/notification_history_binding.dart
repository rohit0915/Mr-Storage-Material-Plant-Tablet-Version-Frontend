import 'package:get/get.dart';
import '../controller/notification_history_controller.dart';

class NotificationHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationHistoryController>(() => NotificationHistoryController());
  }
}
