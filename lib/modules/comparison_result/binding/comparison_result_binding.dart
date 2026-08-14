import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';
import '../controller/comparison_result_controller.dart';

class ComparisonResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipperRequestWorkflowRepository>(
      () => ShipperRequestWorkflowRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<ComparisonResultController>(
      () => ComparisonResultController(
        repository: Get.find<ShipperRequestWorkflowRepository>(),
      ),
    );
  }
}
