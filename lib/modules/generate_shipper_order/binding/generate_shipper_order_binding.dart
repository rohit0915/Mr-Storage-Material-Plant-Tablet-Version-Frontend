import 'package:get/get.dart';
import '../controller/generate_shipper_order_controller.dart';

class GenerateShipperOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenerateShipperOrderController>(() => GenerateShipperOrderController());
  }
}
