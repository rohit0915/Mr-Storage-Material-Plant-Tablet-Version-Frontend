import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';
import '../controller/shipper_file_details_controller.dart';

class ShipperFileDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipperRequestWorkflowRepository>(
      () => ShipperRequestWorkflowRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<ShipperFileDetailsController>(
      () => ShipperFileDetailsController(
        repository: Get.find<ShipperRequestWorkflowRepository>(),
      ),
      fenix: true,
    );
  }
}
