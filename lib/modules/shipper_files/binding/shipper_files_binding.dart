import 'package:get/get.dart';
import '../controller/shipper_files_controller.dart';

class ShipperFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipperFilesController>(() => ShipperFilesController());
  }
}
