import 'package:get/get.dart';
import '../controller/project_drawings_controller.dart';

class ProjectDrawingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectDrawingsController>(() => ProjectDrawingsController());
  }
}
