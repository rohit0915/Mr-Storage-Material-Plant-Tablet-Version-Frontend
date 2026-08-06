import 'package:get/get.dart';
import '../controller/bom_files_details_controller.dart';

class BomFilesDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BomFilesDetailsController>(() => BomFilesDetailsController());
  }
}
