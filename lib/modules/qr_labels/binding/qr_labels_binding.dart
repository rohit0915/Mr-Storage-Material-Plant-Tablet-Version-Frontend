import 'package:get/get.dart';
import '../controller/qr_labels_controller.dart';

class QrLabelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrLabelsController>(() => QrLabelsController());
  }
}
