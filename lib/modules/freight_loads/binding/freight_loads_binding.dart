import 'package:get/get.dart';
import '../controller/freight_loads_controller.dart';
import '../../../app/network/api_client.dart';
import '../repository/delivery_repository.dart';

class FreightLoadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryRepository>(
      () => DeliveryRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<FreightLoadsController>(
      () => FreightLoadsController(repository: Get.find<DeliveryRepository>()),
    );
  }
}
