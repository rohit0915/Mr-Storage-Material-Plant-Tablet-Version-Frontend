import 'package:get/get.dart';
import '../controller/freight_carriers_controller.dart';

class FreightCarriersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FreightCarriersController>(() => FreightCarriersController());
  }
}
