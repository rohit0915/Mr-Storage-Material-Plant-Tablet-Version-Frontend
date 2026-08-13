import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/delivery_details_controller.dart';
import '../repository/delivery_details_repository.dart';

class DeliveryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryDetailsRepository>(
      () => DeliveryDetailsRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<DeliveryDetailsController>(
      () => DeliveryDetailsController(
        repository: Get.find<DeliveryDetailsRepository>(),
      ),
    );
  }
}
