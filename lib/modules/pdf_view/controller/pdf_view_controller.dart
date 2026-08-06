import 'package:get/get.dart';

class PdfViewController extends GetxController {
  final RxDouble zoomScale = 1.0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final String documentTitle = 'BOM-001_ABC_Construction.pdf';

  void zoomIn() {
    if (zoomScale.value < 2.0) {
      zoomScale.value += 0.15;
    }
  }

  void zoomOut() {
    if (zoomScale.value > 0.6) {
      zoomScale.value -= 0.15;
    }
  }

  void resetZoom() {
    zoomScale.value = 1.0;
  }
}
