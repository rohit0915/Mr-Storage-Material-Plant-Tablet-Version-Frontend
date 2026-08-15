import 'dart:typed_data';

import 'package:get/get.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';

class PdfViewController extends GetxController {
  final RxDouble zoomScale = 1.0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final String documentTitle = 'BOM-001_ABC_Construction.pdf';

  Future<List<int>> _documentBytes() => FileExportService.tablePdf(
    title: 'BOM-001 — ABC Construction',
    subtitle:
        'Total Items: 125  |  Total Weight: 32,000 lbs  |  Total Panels Area: 3,300 sqm',
    headers: const ['Item', 'Description', 'Quantity', 'Unit', 'Weight'],
    rows: const [
      ['1', 'Primary steel framing', '45', 'PCS', '18,500 lbs'],
      ['2', 'Roof and wall panels', '62', 'PCS', '9,200 lbs'],
      ['3', 'Fasteners and accessories', '18', 'SET', '4,300 lbs'],
    ],
  );

  Future<void> download() async {
    try {
      final bytes = await _documentBytes();
      await FileExportService.savePdf(
        fileName: documentTitle.replaceAll(
          RegExp(r'\.pdf$', caseSensitive: false),
          '',
        ),
        bytes: Uint8List.fromList(bytes),
      );
      CommonSnackbar.showSuccess(
        title: 'PDF Downloaded',
        message: 'Document saved successfully.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Download failed',
        message: error.toString(),
      );
    }
  }

  Future<void> printDocument() async {
    try {
      final bytes = Uint8List.fromList(await _documentBytes());
      await FileExportService.printPdf(name: documentTitle, bytes: bytes);
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Print failed',
        message: error.toString(),
      );
    }
  }

  Future<void> shareDocument() async {
    try {
      final bytes = Uint8List.fromList(await _documentBytes());
      await FileExportService.sharePdf(
        fileName: documentTitle.replaceAll(
          RegExp(r'\.pdf$', caseSensitive: false),
          '',
        ),
        bytes: bytes,
        text: 'BOM document for ABC Construction',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Share failed',
        message: error.toString(),
      );
    }
  }

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
