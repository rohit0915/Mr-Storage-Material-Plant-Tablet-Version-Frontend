import 'package:get/get.dart';
import '../controller/delivery_calendar_controller.dart';
import '../../../app/network/api_client.dart';
import '../../freight_loads/repository/delivery_repository.dart';

class DeliveryCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryRepository>(
      () => DeliveryRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<DeliveryCalendarController>(
      () => DeliveryCalendarController(
        repository: Get.find<DeliveryRepository>(),
      ),
    );
  }
}
