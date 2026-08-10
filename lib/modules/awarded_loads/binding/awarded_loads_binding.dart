import 'package:get/get.dart';
import '../controller/awarded_loads_controller.dart';

class AwardedLoadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AwardedLoadsController>(() => AwardedLoadsController());
  }
}
