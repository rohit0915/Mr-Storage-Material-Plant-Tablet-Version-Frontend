import 'package:get/get.dart';
import '../controller/all_projects_controller.dart';

class AllProjectsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllProjectsController>(() => AllProjectsController());
  }
}
