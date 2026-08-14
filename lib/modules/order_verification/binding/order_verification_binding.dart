import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';
import '../controller/order_verification_controller.dart';

class OrderVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipperRequestWorkflowRepository>(
      () => ShipperRequestWorkflowRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<OrderVerificationController>(
      () => OrderVerificationController(
        repository: Get.find<ShipperRequestWorkflowRepository>(),
      ),
    );
  }
}
