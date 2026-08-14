import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/project_drawings_controller.dart';
import '../repository/project_drawings_repository.dart';

class ProjectDrawingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectDrawingsRepository>(
      () => ProjectDrawingsRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<ProjectDrawingsController>(
      () => ProjectDrawingsController(
        repository: Get.find<ProjectDrawingsRepository>(),
      ),
    );
  }
}
