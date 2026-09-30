import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/bom_files_details_controller.dart';
import '../widgets/bom_details_shimmer.dart';

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

            // Header Navigation & Actions Bar (Always visible)
            _buildHeaderToolbar(),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const BomDetailsShimmer();
                }
                if (controller.errorMessage.value.isNotEmpty || controller.bomItems.isEmpty) {
                  return _buildConsolidatedNotGeneratedCard();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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

          Obx(() {
            final hasBomData = controller.bomItems.isNotEmpty &&
                controller.errorMessage.value.isEmpty;
            final isConfirmed = (controller.isConfirmed.value ||
                    Get.parameters['mode'] == 'consolidated') &&
                hasBomData;
            final unpriced =
                controller.missingSummary.value?.missingItemQty ?? 0;

            final isConsolidatedMode = Get.parameters['mode'] == 'consolidated';
            if (isConfirmed) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Download Excel Button (Shown when BOM is present & confirmed)
                  ElevatedButton.icon(
                    onPressed: () => controller.downloadExcel(),
                    icon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(
                        Icons.grid_on,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    label: const Text(
                      'Download Excel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  if (isConsolidatedMode) ...[
                    const SizedBox(width: 10),

                    // Share with Shippers Button (Shown ONLY when mode is consolidated)
                    ElevatedButton(
                      onPressed: () => controller.shareWithShippers(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Share with Shippers',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }

            if (!hasBomData || controller.buildingId.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return ElevatedButton.icon(
              onPressed: unpriced > 0 || controller.isConfirming.value
                  ? null
                  : controller.confirmBom,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: Text(
                controller.isConfirming.value
                    ? 'Confirming...'
                    : 'Confirm BOM',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMainContentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Title Header Box
            Obx(
              () => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Project: ${controller.projectName.value}${controller.buildingName.value.isEmpty ? '' : ' | ${controller.buildingName.value}'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Statistics Row
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Total Parts: ${controller.summary.value?.totalItems ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Weight (lbs): ${controller.summary.value?.totalWeight ?? '0 lbs'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Priced Items: ${controller.pricedItems.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Price: ${controller.totalCost.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BOM Data Table
            _buildBomDataTable(),

            Obx(() {
              if (controller.totalPages <= 1 &&
                  controller.totalEntries.value <=
                      controller.rowsPerPage.value) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonPaginationFooter(
                  currentPage: controller.currentPage.value,
                  totalPages: controller.totalPages,
                  rowsPerPage: controller.rowsPerPage.value,
                  totalEntries: controller.totalEntries.value,
                  rowsPerPageOptions: const [20, 50, 100],
                  onPageChanged: controller.changePage,
                  onRowsPerPageChanged: controller.changeRowsPerPage,
                ),
              );
            }),

            const SizedBox(height: 24),

            const Text(
              'Received By:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          val,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBomTabs() {
    const labels = [
      'All Items',
      'Unpriced Items',
      'BOM Priced',
      'Frame Items',
      'Matched Items',
    ];
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Wrap(
          spacing: 28,
          children: List.generate(labels.length, (index) {
            final selected = controller.selectedTabIndex.value == index;
            return InkWell(
              onTap: () => controller.selectTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? const Color(0xFF1E56B9)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFF1E56B9)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBomDataTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double minTableWidth = 1000.0;
        final double tableWidth = constraints.maxWidth < minTableWidth
            ? minTableWidth
            : constraints.maxWidth;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      children: [
                        _buildTh('Sr.', flex: 1),
                        _buildTh('Part ID', flex: 2),
                        _buildTh('Category', flex: 3),
                        _buildTh('Sub Category', flex: 2),
                        _buildTh('Total Length (Meters)', flex: 3),
                        _buildTh('Weight (kg)', flex: 2),
                        _buildTh('Surface Area (sqm)', flex: 2),
                        _buildTh('Total Price', flex: 2),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  // Rows
                  Obx(() {
                    if (controller.bomItems.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 54),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.inbox_outlined,
                              size: 42,
                              color: AppColors.textHint,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No BOM items found',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'There are no line items in this BOM file.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: List.generate(controller.bomItems.length, (index) {
                        final item = controller.bomItems[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  _buildTd('${index + 1}', flex: 1, isBold: true),
                                  _buildTd(item.part, flex: 2),
                                  _buildTd(item.category, flex: 3, color: AppColors.textSecondary),
                                  _buildTd(item.description, flex: 2, color: AppColors.textSecondary),
                                  _buildTd(item.length, flex: 3, color: AppColors.textSecondary),
                                  _buildTd(item.weight, flex: 2, color: AppColors.textSecondary),
                                  _buildTd('-', flex: 2, color: AppColors.textSecondary),
                                  if (item.isMissing)
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: const Text(
                                          'Missing',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFEF4444),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    _buildTd(item.amount, flex: 2, color: AppColors.textPrimary),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                          ],
                        );
                      }),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTh(String title, {int flex = 1, bool sortable = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (sortable) ...[
              const SizedBox(width: 3),
              const Icon(Icons.swap_vert, size: 12, color: AppColors.textHint),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConsolidatedNotGeneratedCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Consolidated BOM Not Generated Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'The consolidated Bill of Materials (BOM) has not been generated for this project. Please make sure that BOM files have been uploaded and processed.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTd(
    String text, {
    int flex = 1,
    bool isBold = false,
    Color color = AppColors.textPrimary,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
      ),
    );
  }
}
