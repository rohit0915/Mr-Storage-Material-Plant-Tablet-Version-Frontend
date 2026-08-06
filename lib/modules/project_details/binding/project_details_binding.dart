import 'package:get/get.dart';
import '../controller/project_details_controller.dart';

class ProjectDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectDetailsController>(() => ProjectDetailsController());
  }
}
