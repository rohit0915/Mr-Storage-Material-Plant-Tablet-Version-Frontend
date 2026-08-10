import 'package:get/get.dart';
import '../controller/freight_loads_controller.dart';

class FreightLoadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FreightLoadsController>(() => FreightLoadsController());
  }
}
