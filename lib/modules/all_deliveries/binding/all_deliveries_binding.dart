import 'package:get/get.dart';

import '../../../app/network/api_client.dart';
import '../../freight_loads/repository/delivery_repository.dart';
import '../controller/all_deliveries_controller.dart';

class AllDeliveriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryRepository>(
      () => DeliveryRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<AllDeliveriesController>(
      () => AllDeliveriesController(repository: Get.find<DeliveryRepository>()),
    );
  }
}
