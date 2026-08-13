import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/project_details_controller.dart';
import '../repository/project_details_repository.dart';

class ProjectDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectDetailsRepository>(
      () => ProjectDetailsRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<ProjectDetailsController>(
      () => ProjectDetailsController(repository: Get.find<ProjectDetailsRepository>()),
    );
  }
}
