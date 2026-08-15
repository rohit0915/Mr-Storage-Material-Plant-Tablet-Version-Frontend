import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../bom_files_details/repository/bom_files_details_repository.dart';
import '../controller/generate_shipper_order_controller.dart';

class GenerateShipperOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenerateShipperOrderController>(
      () => GenerateShipperOrderController(
        apiClient: Get.find<ApiClient>(),
        bomRepository: BomFilesDetailsRepository(
          apiClient: Get.find<ApiClient>(),
        ),
      ),
    );
  }
}
