import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/packing_list_controller.dart';
import '../repository/packing_list_repository.dart';

class PackingListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackingListRepository>(
      () => PackingListRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<PackingListController>(
      () =>
          PackingListController(repository: Get.find<PackingListRepository>()),
    );
  }
}
