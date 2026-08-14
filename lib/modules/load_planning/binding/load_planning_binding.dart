import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../../app/repositories/workflow_repository.dart';
import '../controller/load_planning_controller.dart';
import '../repository/bundle_plan_repository.dart';
import '../repository/load_planning_repository.dart';

class LoadPlanningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkflowRepository>(
      () => WorkflowRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<BundlePlanRepository>(
      () => BundlePlanRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<LoadPlanningRepository>(
      () => LoadPlanningRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<LoadPlanningController>(
      () => LoadPlanningController(
        repository: Get.find<LoadPlanningRepository>(),
        workflowRepository: Get.find<WorkflowRepository>(),
        bundlePlanRepository: Get.find<BundlePlanRepository>(),
      ),
    );
  }
}
