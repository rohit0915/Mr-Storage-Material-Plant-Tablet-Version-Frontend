import 'package:get/get.dart';
import '../controller/customer_info_controller.dart';

class CustomerInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerInfoController>(() => CustomerInfoController());
  }
}
