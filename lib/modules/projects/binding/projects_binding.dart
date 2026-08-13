import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/projects_controller.dart';
import '../repository/projects_repository.dart';

class ProjectsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectsRepository>(
      () => ProjectsRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<ProjectsController>(
      () => ProjectsController(repository: Get.find<ProjectsRepository>()),
    );
  }
}
