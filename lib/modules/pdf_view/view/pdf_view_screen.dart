import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../../app/widgets/common_error_widget.dart';
import '../controller/pdf_view_controller.dart';

class PdfViewScreen extends GetView<PdfViewController> {
  const PdfViewScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              controller.documentTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Obx(() => Row(children: [
          IconButton(tooltip: 'Download', onPressed: controller.documentBytes.value == null ? null : controller.download, icon: const Icon(Icons.download)),
          IconButton(tooltip: 'Print', onPressed: controller.documentBytes.value == null ? null : controller.printDocument, icon: const Icon(Icons.print)),
          IconButton(tooltip: 'Share', onPressed: controller.documentBytes.value == null ? null : controller.shareDocument, icon: const Icon(Icons.share)),
        ])),
      ],
    ),
    body: Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (controller.errorMessage.isNotEmpty) return CommonErrorWidget(message: controller.errorMessage.value, onRetry: controller.loadDocument);
      final bytes = controller.documentBytes.value;
      if (bytes == null) return const Center(child: Text('No document available'));
      return PdfPreview(build: (_) async => bytes, allowPrinting: false, allowSharing: false,
        canChangeOrientation: false, canChangePageFormat: false, canDebug: false);
    }),
  );
}
