import 'package:get/get.dart';
import '../controller/order_verification_controller.dart';

class OrderVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderVerificationController>(() => OrderVerificationController());
  }
}
