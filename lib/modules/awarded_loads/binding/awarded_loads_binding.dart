import 'package:get/get.dart';
import '../controller/awarded_loads_controller.dart';
import '../../../app/network/api_client.dart';
import '../../freight_loads/repository/delivery_repository.dart';

class AwardedLoadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryRepository>(
      () => DeliveryRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<AwardedLoadsController>(
      () => AwardedLoadsController(repository: Get.find<DeliveryRepository>()),
    );
  }
}
