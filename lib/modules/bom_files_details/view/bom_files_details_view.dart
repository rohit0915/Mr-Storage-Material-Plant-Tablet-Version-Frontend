import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/bom_files_details_controller.dart';

class BomFilesDetailsView extends GetView<BomFilesDetailsController> {
  const BomFilesDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top App Bar
            const DashboardAppBar(),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Navigation & Actions Bar
                      _buildHeaderToolbar(),

                      const SizedBox(height: 16),

                      // Main Content Card
                      _buildMainContentCard(),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
            label: const Text(
              'Back',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'BOM Files Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Action buttons
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.description_outlined, size: 14, color: AppColors.textPrimary),
            label: const Text(
              'Download Excel',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.inputBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.pdfView),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 14, color: AppColors.textPrimary),
            label: const Text(
              'Download PDF',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.inputBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.generateShipperOrder),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text(
              'Share with Shippers',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Title Header Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Project: ${controller.projectName} | BOM ID: ${controller.bomId}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOM Summary Box
            Container(
              width: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BOM Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Total Items', '${controller.summary.value?.totalItems ?? 125}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Total Weight', controller.summary.value?.totalWeight ?? '32,000 lbs', isBold: true),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Total Panels Area', controller.summary.value?.totalPanelsArea ?? '3,300 sqm', isBold: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // STORAGE MATERIALS Printable Header Box
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Row(
                children: [
                  // Left Logo Box
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
                              letterSpacing: 1.0,
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
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1.5, height: 110, color: Colors.black),

                  // Right Metadata Table Grid
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        // Title row
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'STUDS & TOP CHANNELS',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeaderGridCell('Date', controller.date),
                                  _buildHeaderGridCell('Job Id', controller.jobId),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Customer row
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 100, child: Text('Customer:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                              Text(controller.customerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        // Project Name row
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: Row(
                            children: [
                              const SizedBox(width: 100, child: Text('Project Name:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                              Text(controller.projectName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // BOM Data Table
            _buildBomDataTable(),

            const SizedBox(height: 24),

            const Text(
              'Received By:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderGridCell(String label, String val) {
    return Row(
      children: [
        SizedBox(width: 45, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        Text(val, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBomDataTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                _buildTh('QTY', flex: 1, sortable: true),
                _buildTh('Mark', flex: 1, sortable: true),
                _buildTh('Description', flex: 2),
                _buildTh('Part', flex: 2),
                _buildTh('Color', flex: 1),
                _buildTh('Angle', flex: 1, sortable: true),
                _buildTh('Thick', flex: 1),
                _buildTh('Length', flex: 2, sortable: true),
                _buildTh('Weight', flex: 1, sortable: true),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Rows
          ...List.generate(controller.bomItems.length, (index) {
            final item = controller.bomItems[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      _buildTd('${item.qty}', flex: 1, isBold: true),
                      _buildTd(item.mark, flex: 1),
                      _buildTd(item.description, flex: 2, color: AppColors.textSecondary),
                      _buildTd(item.part, flex: 2, isBold: true),
                      _buildTd(item.color, flex: 1, color: AppColors.textSecondary),
                      _buildTd(item.angle, flex: 1, color: AppColors.textSecondary),
                      _buildTd(item.thick, flex: 1, color: AppColors.textSecondary),
                      _buildTd(item.length, flex: 2, color: AppColors.textSecondary),
                      _buildTd(item.weight, flex: 1, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                if (index < controller.bomItems.length - 1)
                  const Divider(height: 1, color: AppColors.divider),
              ],
            );
          }),
          const Divider(height: 1, color: AppColors.divider),
          // Footer Totals Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(flex: 2, child: Text('QTY Total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                const Expanded(flex: 2, child: Text('Total Tons:   1.71', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                const Expanded(flex: 1, child: Text('RO', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                const Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                const Expanded(flex: 2, child: Text('Total Weight (lbs)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                const Expanded(flex: 1, child: Text('3423', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTh(String title, {int flex = 1, bool sortable = false}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (sortable) ...[
            const SizedBox(width: 3),
            const Icon(Icons.swap_vert, size: 12, color: AppColors.textHint),
          ],
        ],
      ),
    );
  }

  Widget _buildTd(String text, {int flex = 1, bool isBold = false, Color color = AppColors.textPrimary}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}
