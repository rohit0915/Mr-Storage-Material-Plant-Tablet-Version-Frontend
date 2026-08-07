import 'package:get/get.dart';
import '../controller/load_planning_controller.dart';

class LoadPlanningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoadPlanningController>(() => LoadPlanningController());
  }
}
