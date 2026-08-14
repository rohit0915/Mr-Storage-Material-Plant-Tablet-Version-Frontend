import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../freight_carriers/repository/freight_carriers_repository.dart';
import '../controller/delivery_details_controller.dart';
import '../repository/delivery_details_repository.dart';

class DeliveryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryDetailsRepository>(
      () => DeliveryDetailsRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<FreightCarriersRepository>(
      () => FreightCarriersRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<DeliveryDetailsController>(
      () => DeliveryDetailsController(
        repository: Get.find<DeliveryDetailsRepository>(),
        carriersRepository: Get.find<FreightCarriersRepository>(),
      ),
    );
  }
}
