import 'package:get/get.dart';
import '../controller/delivery_calendar_controller.dart';

class DeliveryCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryCalendarController>(() => DeliveryCalendarController());
  }
}
