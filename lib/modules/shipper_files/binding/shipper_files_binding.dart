import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/shipper_files_controller.dart';
import '../repository/shipper_files_repository.dart';

class ShipperFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipperFilesRepository>(
      () => ShipperFilesRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<ShipperFilesController>(
      () => ShipperFilesController(
        repository: Get.find<ShipperFilesRepository>(),
      ),
    );
  }
}
