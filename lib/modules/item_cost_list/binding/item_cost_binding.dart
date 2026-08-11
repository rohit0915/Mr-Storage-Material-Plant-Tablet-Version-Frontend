import 'package:get/get.dart';
import '../controller/item_cost_controller.dart';

class ItemCostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemCostController>(() => ItemCostController());
  }
}
