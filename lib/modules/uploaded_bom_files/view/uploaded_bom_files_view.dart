import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_error_widget.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/uploaded_bom_files_controller.dart';

class UploadedBomFilesView extends GetView<UploadedBomFilesController> {
  const UploadedBomFilesView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  return CommonErrorWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.loadBomFiles,
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeaderRow(),
                      const SizedBox(height: 20),
                      _buildSummaryCardsRow(),
                      const SizedBox(height: 20),
                      _buildFilterControlsRow(),
                      const SizedBox(height: 20),
                      _buildDataTableCard(),
                      const SizedBox(height: 16),
                      _buildPaginationFooter(),
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

  Widget _buildTopHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Uploaded BOM Files',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file, size: 16, color: Colors.white),
          label: const Text(
            'Upload BOM File',
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCardsRow() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'Total BOM Files',
              value: '${controller.totalProjects.value} Files',
              backgroundColor: const Color(0xFF1D51A4),
              icon: Icons.build_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              title: 'Pending Upload',
              value: '${controller.pendingUpload.value}',
              backgroundColor: const Color(0xFF22C55E),
              icon: Icons.verified_user_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              title: 'Ready for Shipper',
              value: '${controller.readyForShipper.value}',
              backgroundColor: const Color(0xFFEAB308),
              icon: Icons.monetization_on_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              title: 'Issues Detected',
              value: '${controller.issuesDetected.value}',
              backgroundColor: const Color(0xFFF97316),
              icon: Icons.insert_chart_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: backgroundColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControlsRow() {
    return Row(
      children: [
        // Search bar
        Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: const [
              Icon(Icons.search, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Filter All Projects Dropdown
        PopupMenuButton<String>(
          onSelected: (val) {
            controller.selectedFilterProject.value = val;
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'Filter All Projects', child: Text('Filter All Projects')),
            PopupMenuItem(value: 'Another Project', child: Text('Another Project')),
            PopupMenuItem(value: 'Wood Workshop', child: Text('Wood Workshop')),
            PopupMenuItem(value: 'Lucas project', child: Text('Lucas project')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    controller.selectedFilterProject.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Sort Dropdown
        PopupMenuButton<String>(
          onSelected: (val) {
            controller.selectedSort.value = val;
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'Latest', child: Text('Latest')),
            PopupMenuItem(value: 'Oldest', child: Text('Oldest')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Obx(
                  () => Text(
                    'Sort by : ${controller.selectedSort.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Obx(() {
                    final allSelected = controller.bomFilesList.isNotEmpty &&
                        controller.bomFilesList.every((e) => e.isSelected);
                    return Checkbox(
                      value: allSelected,
                      onChanged: controller.toggleSelectAll,
                      activeColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                _buildTh('Project', flex: 3, sortable: true),
                _buildTh('Upload Date', flex: 2, sortable: true),
                _buildTh('Items', flex: 2, sortable: true),
                _buildTh('File Status', flex: 3),
                const SizedBox(width: 40), // Action button space
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Data Rows
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.bomFilesList.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = controller.bomFilesList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Checkbox(
                          value: item.isSelected,
                          onChanged: (val) =>
                              controller.toggleSelectItem(index, val),
                          activeColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.project,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.uploadDate,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item.items}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusBadge(item.status),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.toNamed(
                          AppRoutes.bomFilesDetails,
                          parameters: {'id': item.id},
                        ),
                        icon: const Icon(
                          Icons.visibility,
                          size: 18,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(34, 34),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTh(String label, {int flex = 1, bool sortable = false}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (sortable) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.swap_vert,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.toLowerCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.check_circle_outline,
            size: 13,
            color: Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return CommonPaginationFooter(
      currentPage: controller.currentPage.value,
      totalPages:
          (controller.totalItems.value / controller.selectedRowsPerPage.value)
              .ceil()
              .clamp(1, 999),
      rowsPerPage: controller.selectedRowsPerPage.value,
      onPageChanged: (page) {
        controller.currentPage.value = page;
        controller.loadBomFiles();
      },
      onRowsPerPageChanged: (rows) {
        controller.selectedRowsPerPage.value = rows;
        controller.currentPage.value = 1;
        controller.loadBomFiles();
      },
    );
  }
}
