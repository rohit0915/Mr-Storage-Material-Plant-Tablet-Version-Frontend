import 'package:get/get.dart';
import '../controller/shippers_controller.dart';

class ShippersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShippersController>(() => ShippersController());
  }
}
