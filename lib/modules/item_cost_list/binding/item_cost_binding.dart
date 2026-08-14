import 'package:get/get.dart';
import '../controller/item_cost_controller.dart';
import '../../../app/network/api_client.dart';
import '../repository/item_cost_repository.dart';

class ItemCostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemCostRepository>(
      () => ItemCostRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<ItemCostController>(
      () => ItemCostController(repository: Get.find<ItemCostRepository>()),
    );
  }
}
