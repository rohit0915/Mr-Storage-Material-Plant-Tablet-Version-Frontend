import 'package:get/get.dart';
import '../controller/additional_material_request_controller.dart';

class AdditionalMaterialRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdditionalMaterialRequestController>(() => AdditionalMaterialRequestController());
  }
}
