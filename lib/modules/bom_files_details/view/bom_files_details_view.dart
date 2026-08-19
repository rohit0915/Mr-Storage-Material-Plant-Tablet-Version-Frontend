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

            if (isConfirmed) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Download Excel Button (Shown only when BOM is present & confirmed)
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
                  const SizedBox(width: 10),

                  // Share with Shippers Button (Shown only when BOM is present & confirmed)
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

            // Summary Cards Row (BOM Summary + Pricing Summary)
            Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BOM Summary Box
                  Expanded(
                    child: Container(
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
                          _buildSummaryRow(
                            'Total Items',
                            '${controller.summary.value?.totalItems ?? 0}',
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Total Weight',
                            controller.summary.value?.totalWeight ?? '0 lbs',
                            isBold: true,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Priced Items',
                            '${controller.pricedItems.value}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Pricing Summary Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pricing Summary',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow(
                            'Total Cost',
                            controller.totalCost.value,
                            isBold: true,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Unpriced Items QTY',
                            '${controller.missingSummary.value?.missingItemQty ?? 0}',
                            isBold: true,
                          ),
                          if ((controller
                                      .missingSummary
                                      .value
                                      ?.missingItemQty ??
                                  0) >
                              0) ...[
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.missingItemCostList),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                'Add Item in Cost List',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Printable BOM header
            Obx(
              () => Container(
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
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 74,
                          fit: BoxFit.contain,
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'STUDS & TOP CHANNELS',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeaderGridCell(
                                      'Date',
                                      controller.date.value,
                                    ),
                                    _buildHeaderGridCell(
                                      'Job Id',
                                      controller.jobId.value,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Customer row
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 100,
                                  child: Text(
                                    'Customer:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  controller.customerName.value,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Project Name row
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 100,
                                  child: Text(
                                    'Project Name:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  controller.projectName.value,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildBomTabs(),

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
                _buildTh('Part', flex: 1),
                _buildTh('Color', flex: 1),
                _buildTh('Thick', flex: 1),
                _buildTh('Length', flex: 1, sortable: true),
                _buildTh('Weight', flex: 1, sortable: true),
                _buildTh('Amount', flex: 1, sortable: true),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Rows
          Obx(() {
            if (controller.groupedBomItems.isEmpty) {
              final filter = BomFilesDetailsController
                  .filters[controller.selectedTabIndex.value]
                  .replaceAll('_', ' ');
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 54),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 42,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No BOM items found',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.selectedTabIndex.value == 0
                          ? 'There are no line items in this BOM file.'
                          : 'There are no line items matching the "$filter" filter.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: controller.groupedBomItems.entries.expand((entry) {
                final items = entry.value;
                return <Widget>[
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      '${entry.key.replaceAll('_', ' ').toUpperCase()} (${items.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E56B9),
                      ),
                    ),
                  ),
                  ...List.generate(items.length, (index) {
                    final item = items[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              _buildTd('${item.qty}', flex: 1, isBold: true),
                              _buildTd(item.mark, flex: 1),
                              _buildTd(
                                item.description,
                                flex: 2,
                                color: AppColors.textSecondary,
                              ),
                              _buildTd(item.part, flex: 1, isBold: true),
                              _buildTd(
                                item.color,
                                flex: 1,
                                color: AppColors.textSecondary,
                              ),
                              _buildTd(item.thick, flex: 1),
                              _buildTd(
                                item.length,
                                flex: 1,
                                color: AppColors.textSecondary,
                              ),
                              _buildTd(
                                item.weight,
                                flex: 1,
                                color: AppColors.textSecondary,
                              ),
                              if (item.isMissing)
                                Expanded(
                                  flex: 1,
                                  child: const Text(
                                    'Missing',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                )
                              else
                                _buildTd(
                                  item.amount,
                                  flex: 1,
                                  color: AppColors.textPrimary,
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                      ],
                    );
                  }),
                ];
              }).toList(),
            );
          }),
          const Divider(height: 1, color: AppColors.divider),
          // Footer Totals Row
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'QTY Total\n${controller.qtyTotal.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total Tons:   ${controller.totalTons.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'RO',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total Weight (lbs)\n${controller.totalWeightLbs.value.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      controller.totalCost.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
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
