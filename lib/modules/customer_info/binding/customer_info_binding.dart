import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../../app/repositories/workflow_repository.dart';
import '../controller/customer_info_controller.dart';

class CustomerInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkflowRepository>(
      () => WorkflowRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<CustomerInfoController>(
      () => CustomerInfoController(repository: Get.find<WorkflowRepository>()),
    );
  }
}
