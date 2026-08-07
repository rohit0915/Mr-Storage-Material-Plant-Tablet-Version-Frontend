import 'package:get/get.dart';
import '../controller/uploaded_bom_files_controller.dart';

class UploadedBomFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadedBomFilesController>(() => UploadedBomFilesController());
  }
}
