import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/uploaded_bom_files_controller.dart';
import '../repository/uploaded_bom_files_repository.dart';

class UploadedBomFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadedBomFilesRepository>(
      () => UploadedBomFilesRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<UploadedBomFilesController>(
      () => UploadedBomFilesController(
        repository: Get.find<UploadedBomFilesRepository>(),
      ),
    );
  }
}
