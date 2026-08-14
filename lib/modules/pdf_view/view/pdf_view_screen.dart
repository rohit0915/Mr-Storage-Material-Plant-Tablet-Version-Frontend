import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../controller/pdf_view_controller.dart';

class PdfViewScreen extends GetView<PdfViewController> {
  const PdfViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: SafeArea(
        child: Column(
          children: [
            // Top Dark PDF Viewer Toolbar
            _buildPdfToolbar(context),

            // Scrollable PDF Document Canvas Container
            Expanded(
              child: Container(
                color: const Color(0xFF334155),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Center(
                    child: Obx(() => Transform.scale(
                          scale: controller.zoomScale.value,
                          alignment: Alignment.topCenter,
                          child: _buildA4PdfPage(),
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfToolbar(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
      ),
      child: Row(
        children: [
          // Back Button
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
            label: const Text(
              'Back',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(width: 16),

          // Red PDF Icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'PDF',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),

          // Document Title
          Text(
            controller.documentTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const Spacer(),

          // Page Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(() => Text(
                  'Page ${controller.currentPage.value} / ${controller.totalPages.value}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                )),
          ),

          const SizedBox(width: 16),

          // Zoom Controls
          Row(
            children: [
              IconButton(
                onPressed: controller.zoomOut,
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 20),
                tooltip: 'Zoom Out',
              ),
              Obx(() => Text(
                    '${(controller.zoomScale.value * 100).round()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  )),
              IconButton(
                onPressed: controller.zoomIn,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 20),
                tooltip: 'Zoom In',
              ),
              IconButton(
                onPressed: controller.resetZoom,
                icon: const Icon(Icons.restart_alt, color: Colors.white70, size: 18),
                tooltip: 'Reset Zoom',
              ),
            ],
          ),

          const Spacer(),

          // Download, Print, Share buttons
          IconButton(
            onPressed: () {
              CommonSnackbar.showSuccess(
                title: 'PDF Downloaded',
                message: 'Document saved to downloads folder.',
              );
            },
            icon: const Icon(Icons.download_outlined, color: Colors.white, size: 20),
            tooltip: 'Download PDF',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print_outlined, color: Colors.white, size: 20),
            tooltip: 'Print',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
            tooltip: 'Share',
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white, size: 22),
            tooltip: 'Close Viewer',
          ),
        ],
      ),
    );
  }

  Widget _buildA4PdfPage() {
    return Container(
      width: 780,
      padding: const EdgeInsets.all(40.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const Text(
              'Project: ABC Construction | BOM ID: BOM-001',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Summary Box
          Container(
            width: 300,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BOM Summary',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                _buildSummaryLine('Total Items', '125'),
                const SizedBox(height: 4),
                _buildSummaryLine('Total Weight', '32,000 lbs', isBold: true),
                const SizedBox(height: 4),
                _buildSummaryLine('Total Panels Area', '3,300 sqm', isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // STORAGE MATERIALS Header Table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Text(
                          'STORAGE ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: const Color(0xFF2563EB),
                          child: const Text(
                            'MATERIALS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1.5, height: 110, color: Colors.black),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'STUDS & TOP CHANNELS',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                            Text('Date: 01.09.26\nJob Id: BLDG-D', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 100, child: Text('Customer:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            Text('John Doe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Row(
                          children: const [
                            SizedBox(width: 100, child: Text('Project Name:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            Text('ABC Construction', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Items Table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: const Color(0xFFF8FAFC),
                  child: Row(
                    children: const [
                      Expanded(flex: 1, child: Text('QTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('Mark', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Part', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('Color', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('Angle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('Thick', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Length', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('Weight', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                ...List.generate(10, (index) {
                  final marks = ['S-1', 'S-2', 'S-3', 'S-4', 'S-5', 'S-6', 'S-7', 'S-8', 'S-9', 'S-10'];
                  final qtys = [5, 8, 6, 5, 8, 6, 3, 4, 2, 4];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: Text('${qtys[index]}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: Text(marks[index], style: const TextStyle(fontSize: 11))),
                            const Expanded(flex: 2, child: Text('STUD', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                            const Expanded(flex: 2, child: Text('C42516', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            const Expanded(flex: 1, child: Text('RO', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                            const Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                            const Expanded(flex: 1, child: Text('16 GA', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                            const Expanded(flex: 2, child: Text("8'-7 1/4\"", style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                            const Expanded(flex: 1, child: Text('16.00', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                          ],
                        ),
                      ),
                      if (index < 9) const Divider(height: 1, color: AppColors.divider),
                    ],
                  );
                }),
                const Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text('QTY Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Total Tons:  1.71', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 1, child: Text('RO', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Text('Total Weight (lbs)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 1, child: Text('3423', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Received By:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(val, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: AppColors.textPrimary)),
      ],
    );
  }
}
