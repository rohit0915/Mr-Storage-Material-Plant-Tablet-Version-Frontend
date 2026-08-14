import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/shippers_controller.dart';
import '../repository/shippers_repository.dart';

class ShippersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<ShippersRepository>(
      () => ShippersRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<ShippersController>(
      () => ShippersController(repository: Get.find<ShippersRepository>()),
    );
  }
}
