import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/load_planning_controller.dart';
import '../repository/load_planning_repository.dart';

class LoadPlanningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoadPlanningRepository>(
      () => LoadPlanningRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<LoadPlanningController>(
      () => LoadPlanningController(
        repository: Get.find<LoadPlanningRepository>(),
      ),
    );
  }
}
