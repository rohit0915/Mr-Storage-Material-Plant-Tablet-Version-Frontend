import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/freight_carriers_controller.dart';
import '../repository/freight_carriers_repository.dart';

class FreightCarriersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<FreightCarriersRepository>(
      () => FreightCarriersRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<FreightCarriersController>(
      () => FreightCarriersController(
        repository: Get.find<FreightCarriersRepository>(),
      ),
    );
  }
}
