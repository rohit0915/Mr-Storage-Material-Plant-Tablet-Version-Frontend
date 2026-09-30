import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_error_widget.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/load_planning_controller.dart';

class LoadPlanningView extends GetView<LoadPlanningController> {
  const LoadPlanningView({super.key});

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
                    onRetry: controller.loadProjectsData,
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
                      _buildHeaderToolbar(),
                      const SizedBox(height: 20),
                      _buildFilterRow(),
                      const SizedBox(height: 16),
                      _buildProjectsTableCard(),
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

  Widget _buildHeaderToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBackButton(),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Load Planning',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Plan shipments by uploading shipper data, optimizing bundles, and building truckloads.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: controller.exportProjects,
          icon: const Icon(
            Icons.ios_share,
            size: 14,
            color: AppColors.textPrimary,
          ),
          label: const Text(
            'Export',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: controller.searchQuery.value,
                  onChanged: (value) => controller.searchQuery.value = value,
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
        OutlinedButton.icon(
          onPressed: controller.loadProjectsData,
          icon: const Icon(
            Icons.refresh,
            size: 14,
            color: AppColors.textSecondary,
          ),
          label: const Text(
            'Refresh',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsTableCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Table Header (With Vertical & Horizontal Grid Lines)
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                _buildThWidget(
                  SizedBox(
                    width: 32,
                    child: Checkbox(
                      value:
                          controller.projectsList.isNotEmpty &&
                          controller.projectsList.every(
                            (item) => item.isSelected,
                          ),
                      onChanged: (val) =>
                          controller.toggleSelectAllProjects(val),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  width: 44,
                ),
                _buildTh('Project ID', flex: 2),
                _buildTh('Project Name', flex: 3),
                _buildTh('File Received', flex: 3),
                _buildTh('Total loads', flex: 2),
                _buildTh('Total bundles', flex: 2),
                _buildTh('Action', width: 64, isLast: true),
              ],
            ),
          ),

          // Table Data Rows (With Vertical & Horizontal Grid Lines)
          Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.projectsList.length,
              itemBuilder: (context, index) {
                final item = controller.projectsList[index];
                return IntrinsicHeight(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTdWidget(
                          SizedBox(
                            width: 32,
                            child: Checkbox(
                              value: item.isSelected,
                              onChanged: (val) =>
                                  controller.toggleSelectProject(index, val),
                              activeColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          width: 44,
                        ),
                        _buildTdWidget(
                          Text(
                            item.displayProjectId,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          flex: 2,
                        ),
                        _buildTdWidget(
                          Text(
                            item.projectName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          flex: 3,
                        ),
                        _buildTdWidget(
                          Text(
                            item.fileReceived,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          flex: 3,
                        ),
                        _buildTdWidget(
                          Text(
                            '${item.totalLoadPlanning}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          flex: 3,
                        ),
                        _buildTdWidget(Text('${item.totalBundles}'), flex: 2),
                        _buildTdWidget(
                          IconButton(
                            onPressed: () =>
                                controller.openProjectLoadPlanning(item),
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.inputBorder,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.visibility_outlined,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          width: 64,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTh(
    String label, {
    int flex = 2,
    double? width,
    bool isLast = false,
  }) {
    return _buildThWidget(
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      flex: flex,
      width: width,
      isLast: isLast,
    );
  }

  Widget _buildThWidget(
    Widget child, {
    int flex = 2,
    double? width,
    bool isLast = false,
  }) {
    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (width != null) return SizedBox(width: width, child: container);
    return Expanded(flex: flex, child: container);
  }

  Widget _buildTdWidget(
    Widget child, {
    int flex = 2,
    double? width,
    bool isLast = false,
  }) {
    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (width != null) return SizedBox(width: width, child: container);
    return Expanded(flex: flex, child: container);
  }

  Widget _buildPaginationFooter() {
    return Obx(
      () => CommonPaginationFooter(
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages,
        totalEntries: controller.totalProjects.value,
        rowsPerPage: controller.rowsPerPage.value,
        onPageChanged: controller.changePage,
        onRowsPerPageChanged: controller.changeRowsPerPage,
      ),
    );
  }
}
