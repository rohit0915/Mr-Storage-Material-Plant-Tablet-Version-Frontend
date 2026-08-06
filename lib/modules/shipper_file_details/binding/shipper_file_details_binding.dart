import 'package:get/get.dart';
import '../controller/shipper_file_details_controller.dart';

class ShipperFileDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipperFileDetailsController>(() => ShipperFileDetailsController());
  }
}
