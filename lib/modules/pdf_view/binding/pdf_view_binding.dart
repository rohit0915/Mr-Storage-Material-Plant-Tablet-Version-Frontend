import 'package:get/get.dart';
import '../controller/pdf_view_controller.dart';

class PdfViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfViewController>(() => PdfViewController());
  }
}
