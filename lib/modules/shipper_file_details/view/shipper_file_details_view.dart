import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/shipper_file_details_controller.dart';

class ShipperFileDetailsView extends GetView<ShipperFileDetailsController> {
  const ShipperFileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initOrUpdate();
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 52,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: Get.back,
                              child: const Text('Back'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: controller.loadSalesOrderDetails,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Actions Toolbar matching Web
                      _buildHeaderToolbar(),
                      const SizedBox(height: 16),

                      // Project Information Card matching Web
                      _buildProjectCard(),
                      const SizedBox(height: 20),

                      // PDF Viewer directly embedded matching Web
                      _buildEmbeddedPdfViewer(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 950;
        final titleWidget = Row(
          mainAxisSize: MainAxisSize.min,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Shipper File Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );

        final actionButtonsWidget = Obx(() {
          final statusLower = controller.status.value.toLowerCase();
          final isApproved =
              statusLower == 'approved' || statusLower == 'confirmed';
          final isCompared = statusLower == 'comparison_completed' ||
              isApproved ||
              statusLower == 'resubmit_requested';
          return Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => controller.downloadFile(),
                icon: const Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                label: const Text(
                  'Download file',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.inputBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),

              // Order Verification: ONLY shown if NOT approved yet
              if (!isApproved) ...[
                ElevatedButton.icon(
                  onPressed: () => controller.openOrderVerificationDialog(),
                  icon: const Icon(
                    Icons.balance,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Order Verification',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ],

              // View Comparison Detail Button (Shown once compared or approved)
              if (isCompared || isApproved) ...[
                ElevatedButton.icon(
                  onPressed: () => controller.openComparisonResult(),
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'View Comparison Detail',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ],

              // Start Load Planning: ONLY shown when approved
              if (isApproved) ...[
                ElevatedButton(
                  onPressed: () => controller.startLoadPlanning(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    'Start Load Planning',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          );
        });

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              const SizedBox(height: 12),
              actionButtonsWidget,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            titleWidget,
            Flexible(child: actionButtonsWidget),
          ],
        );
      },
    );
  }

  Widget _buildProjectCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              'Project: ${controller.projectName.value}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              if (isMobile) {
                return Column(
                  children: [
                    _buildInfoRow('Project ID:', controller.projectCode),
                    const SizedBox(height: 10),
                    _buildInfoRow('Shipper:', controller.vendorName),
                    const SizedBox(height: 10),
                    _buildInfoRow('Shipper File:', controller.fileName, isTruncated: true),
                    const SizedBox(height: 10),
                    _buildInfoRow('Upload Date:', controller.uploadedDate),
                    const SizedBox(height: 10),
                    _buildStatusRow(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Details Column
                  Expanded(
                    child: Column(
                      children: [
                        _buildInfoRow('Project ID:', controller.projectCode),
                        const SizedBox(height: 12),
                        _buildInfoRow('Shipper:', controller.vendorName),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  // Right Details Column
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildInfoRow('Shipper File:', controller.fileName, isTruncated: true),
                        const SizedBox(height: 12),
                        _buildInfoRow('Upload Date:', controller.uploadedDate),
                        const SizedBox(height: 12),
                        _buildStatusRow(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, RxString valueObs, {bool isTruncated = false}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Obx(
            () => Tooltip(
              message: valueObs.value,
              child: Text(
                valueObs.value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: isTruncated ? TextOverflow.ellipsis : TextOverflow.clip,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            'Status:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Obx(() {
          final st = controller.status.value;
          final stLower = st.toLowerCase();
          final isGreen = stLower.contains('approved') ||
              stLower.contains('completed') ||
              stLower.contains('compared') ||
              stLower.contains('passed');
          final bg = isGreen ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3);
          final textCol = isGreen ? const Color(0xFF16A34A) : const Color(0xFFD97706);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  st,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
                if (isGreen) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.check_circle_outline, size: 14, color: textCol),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmbeddedPdfViewer() {
    return Obx(() {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 760,
          child: controller.isPdfLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : controller.pdfError.value.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 48,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          controller.pdfError.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.loadPdfPreview,
                        child: const Text('Retry PDF'),
                      ),
                    ],
                  ),
                )
              : controller.pdfBytes.value == null
              ? const Center(
                  child: Text(
                    'No PDF available',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : PdfPreview(
                  build: (_) async => controller.pdfBytes.value!,
                  pdfFileName: controller.fileName.value,
                  allowPrinting: true,
                  allowSharing: true,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  useActions: true,
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
        ),
      );
    });
  }
}
