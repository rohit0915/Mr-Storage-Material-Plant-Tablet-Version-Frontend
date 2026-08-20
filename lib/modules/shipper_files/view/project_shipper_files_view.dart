import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/shipper_files_controller.dart';

class ProjectShipperFilesView extends GetView<ShipperFilesController> {
  const ProjectShipperFilesView({super.key});

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
                              onPressed: () {
                                controller.selectedProjectId.value = '';
                                controller.loadData();
                                Get.back();
                              },
                              child: const Text('Back'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => controller.loadProjectRequests(
                                controller.selectedProjectId.value,
                              ),
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
                      // Header Toolbar with Back Button & Title
                      _buildHeaderToolbar(),
                      const SizedBox(height: 16),

                      // KPI Summary Cards
                      _buildSummaryCards(),
                      const SizedBox(height: 16),

                      // Search, Filter & Select Status Bar
                      _buildFilterBar(),
                      const SizedBox(height: 16),

                      // Main Table Card
                      _buildFilesTableCard(),
                      const SizedBox(height: 16),

                      // Pagination Footer
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
      children: [
        ElevatedButton.icon(
          onPressed: () {
            controller.selectedProjectId.value = '';
            controller.loadData();
            Get.back();
          },
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  controller.selectedProjectName.value.isNotEmpty
                      ? '${controller.selectedProjectName.value} - Shipper Files'
                      : 'Shipper Files',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Manage vendor shipment files and prepare for validation',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        return Obx(() {
          if (isMobile) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Shipper Files',
                        value: '${controller.projectTotalFiles.value} Files',
                        icon: Icons.build_outlined,
                        bgColor: const Color(0xFF1D52B4),
                        iconBgColor: const Color(0xFF3868C6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'File Received',
                        value: '${controller.projectFilesReceived.value} Files',
                        icon: Icons.verified_user_outlined,
                        bgColor: const Color(0xFF28A745),
                        iconBgColor: const Color(0xFF48B962),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Order Sent',
                        value: '${controller.projectOrdersSent.value} Files',
                        icon: Icons.attach_money,
                        bgColor: const Color(0xFFE3A008),
                        iconBgColor: const Color(0xFFEEB22B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Revision Sent',
                        value: '${controller.projectRevisionsSent.value} Files',
                        icon: Icons.show_chart,
                        bgColor: const Color(0xFFFF6B4A),
                        iconBgColor: const Color(0xFFFF856D),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Shipper Files',
                  value: '${controller.projectTotalFiles.value} Files',
                  icon: Icons.build_outlined,
                  bgColor: const Color(0xFF1D52B4),
                  iconBgColor: const Color(0xFF3868C6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'File Received',
                  value: '${controller.projectFilesReceived.value} Files',
                  icon: Icons.verified_user_outlined,
                  bgColor: const Color(0xFF28A745),
                  iconBgColor: const Color(0xFF48B962),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Order Sent',
                  value: '${controller.projectOrdersSent.value} Files',
                  icon: Icons.attach_money,
                  bgColor: const Color(0xFFE3A008),
                  iconBgColor: const Color(0xFFEEB22B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Revision Sent',
                  value: '${controller.projectRevisionsSent.value} Files',
                  icon: Icons.show_chart,
                  bgColor: const Color(0xFFFF6B4A),
                  iconBgColor: const Color(0xFFFF856D),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        // Search Box
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 240),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    decoration: const InputDecoration(
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
        ),
        const SizedBox(width: 12),

        // Filter Button
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(
            Icons.filter_list,
            size: 14,
            color: AppColors.textSecondary,
          ),
          label: const Text(
            'Filter',
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
        const Spacer(),

        // Select Status Dropdown
        PopupMenuButton<String>(
          onSelected: (val) {
            controller.selectedStatus.value = val;
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'Select Status', child: Text('Select Status')),
            PopupMenuItem(value: 'File Received', child: Text('File Received')),
            PopupMenuItem(value: 'Approved', child: Text('Approved')),
            PopupMenuItem(value: 'Rejected', child: Text('Rejected')),
            PopupMenuItem(value: 'Revision Sent', child: Text('Revision Sent')),
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
                const Icon(
                  Icons.tune_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Obx(
                  () => Text(
                    controller.selectedStatus.value,
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

  Widget _buildFilesTableCard() {
    return Obx(() {
      final files = controller.filteredShipperFiles;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          children: [
            // Table Header
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
                        value: files.isNotEmpty &&
                            files.every(
                              (item) => item.isSelected,
                            ),
                        onChanged: (val) {
                          for (var item in files) {
                            item.isSelected = val ?? false;
                          }
                          controller.shipperFiles.refresh();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    width: 44,
                  ),
                  _buildTh('Shipper', flex: 3),
                  _buildTh('File Name', flex: 4),
                  _buildTh('Upload Date', flex: 3),
                  _buildTh('Rate', flex: 2),
                  _buildTh('File Status', flex: 3),
                  _buildTh('Action', width: 56, isLast: true),
                ],
              ),
            ),

            // Table Data Rows
            if (files.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: const Text(
                  'No Shipper Files Found',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final item = files[index];
                  return IntrinsicHeight(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTdWidget(
                            SizedBox(
                              width: 32,
                              child: Checkbox(
                                value: item.isSelected,
                                onChanged: (val) {
                                  item.isSelected = val ?? false;
                                  controller.shipperFiles.refresh();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            width: 44,
                          ),
                          // Shipper Name + Avatar Column
                          _buildTdWidget(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: const Color(0xFFDBEAFE),
                                  child: Text(
                                    item.shipperName.isNotEmpty ? item.shipperName[0] : 'S',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.shipperName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            flex: 3,
                          ),
                          // File Name Column
                          _buildTdWidget(
                            Tooltip(
                              message: item.fileName,
                              child: Text(
                                item.fileName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            flex: 4,
                          ),
                          // Upload Date Column
                          _buildTdWidget(
                            Text(
                              item.uploadDate,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            flex: 3,
                          ),
                          // Rates Column
                          _buildTdWidget(
                            Text(
                              item.rate,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            flex: 2,
                          ),
                          // File Status Column
                          _buildTdWidget(
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _buildStatusBadge(item.status),
                            ),
                            flex: 3,
                          ),
                          // Action Column with Eye Icon Button
                          _buildTdWidget(
                            Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    controller.openShipperFileDetails(item);
                                  },
                                  tooltip: 'View Shipper File Details',
                                ),
                              ),
                            ),
                            width: 56,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTh(String label, {int flex = 2, double? width, bool isLast = false}) {
    return _buildThWidget(
      Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.swap_vert,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
      flex: flex,
      width: width,
      isLast: isLast,
    );
  }

  Widget _buildThWidget(Widget child, {int flex = 2, double? width, bool isLast = false}) {
    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          right: isLast ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (width != null) return SizedBox(width: width, child: container);
    return Expanded(flex: flex, child: container);
  }

  Widget _buildTdWidget(Widget child, {int flex = 2, double? width, bool isLast = false}) {
    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: isLast ? BorderSide.none : const BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (width != null) return SizedBox(width: width, child: container);
    return Expanded(flex: flex, child: container);
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color textColor;
    IconData? icon;

    final lower = status.toLowerCase();
    if (lower.contains('approved') || lower == 'compared') {
      bg = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A);
      icon = Icons.check_circle_outline;
    } else if (lower.contains('rejected') || lower.contains('failed')) {
      bg = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
    } else if (lower.contains('revision')) {
      bg = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF2563EB);
    } else if (lower.contains('order')) {
      bg = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
    } else {
      bg = const Color(0xFFFEF9C3);
      textColor = const Color(0xFFD97706);
    }

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
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 12, color: textColor),
          ],
        ],
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return CommonPaginationFooter(
      currentPage: controller.currentPage.value,
      totalPages: 15,
      rowsPerPage: controller.rowsPerPage.value,
      onPageChanged: (page) => controller.currentPage.value = page,
      onRowsPerPageChanged: (rows) => controller.rowsPerPage.value = rows,
    );
  }
}
