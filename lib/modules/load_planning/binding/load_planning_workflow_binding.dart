import 'package:get/get.dart';

import '../../../app/network/api_client.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';
import '../controller/load_planning_workflow_controller.dart';
import '../repository/bundle_plan_repository.dart';
import '../repository/load_planning_repository.dart';

class LoadPlanningWorkflowBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ShipperRequestWorkflowRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut(() => BundlePlanRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(() => LoadPlanningRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(
      () => LoadPlanningWorkflowController(
        workflowRepository: Get.find<ShipperRequestWorkflowRepository>(),
        bundlePlanRepository: Get.find<BundlePlanRepository>(),
        loadPlanningRepository: Get.find<LoadPlanningRepository>(),
      ),
    );
  }
}
