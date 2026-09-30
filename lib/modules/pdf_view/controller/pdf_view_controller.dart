import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';

class PdfViewController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final documentBytes = Rxn<Uint8List>();
  String get documentTitle => Get.parameters['name'] ?? 'Document.pdf';
  String get documentUrl => Get.parameters['url'] ?? '';

  @override
  void onInit() { super.onInit(); loadDocument(); }

  Future<void> loadDocument() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    documentBytes.value = null;
    try {
      final uri = Uri.tryParse(documentUrl);
      if (uri == null || !{'https', 'http'}.contains(uri.scheme) || uri.host.isEmpty) {
        throw StateError('No document URL is available for this file.');
      }
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      )).get<List<int>>(documentUrl, options: Options(responseType: ResponseType.bytes));
      final bytes = response.data;
      if (bytes == null || bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
        throw StateError('The server did not return a PDF document.');
      }
      documentBytes.value = Uint8List.fromList(bytes);
    } catch (error) { errorMessage.value = error.toString(); }
    finally { isLoading.value = false; }
  }

  Future<void> _perform(Future<void> Function(Uint8List) action) async {
    final bytes = documentBytes.value;
    if (bytes == null) return;
    try { await action(bytes); }
    catch (error) { CommonSnackbar.showError(title: 'Document action failed', message: error.toString()); }
  }

  Future<void> download() => _perform((bytes) async {
    await FileExportService.savePdf(fileName: documentTitle.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), ''), bytes: bytes);
    CommonSnackbar.showSuccess(title: 'PDF Downloaded', message: 'Document saved successfully.');
  });
  Future<void> printDocument() => _perform((bytes) => FileExportService.printPdf(name: documentTitle, bytes: bytes));
  Future<void> shareDocument() => _perform((bytes) => FileExportService.sharePdf(fileName: documentTitle.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), ''), bytes: bytes));
}
