import 'package:get/get.dart';
import '../controller/missing_item_cost_controller.dart';

class MissingItemCostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MissingItemCostController>(() => MissingItemCostController());
  }
}
