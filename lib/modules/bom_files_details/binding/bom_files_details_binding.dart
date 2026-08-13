import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/bom_files_details_controller.dart';
import '../repository/bom_files_details_repository.dart';

class BomFilesDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BomFilesDetailsRepository>(
      () => BomFilesDetailsRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<BomFilesDetailsController>(
      () => BomFilesDetailsController(
        repository: Get.find<BomFilesDetailsRepository>(),
      ),
    );
  }
}
