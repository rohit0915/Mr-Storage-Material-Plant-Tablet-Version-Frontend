import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
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

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Toolbar with Back Button & Title
                      _buildHeaderToolbar(),
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
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
          label: const Text('Back', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  'Shipper Files - ${controller.selectedProjectName.value}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                )),
            const SizedBox(height: 2),
            const Text(
              'Manage vendor shipment files and prepare for validation',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        // Search Box
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
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textHint),
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

        // Filter Button
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_list, size: 14, color: AppColors.textSecondary),
          label: const Text('Filter', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const Spacer(),

        // Select Status Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.tune_outlined, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Select Status',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilesTableCard() {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Checkbox(
                    value: controller.shipperFiles.every((item) => item.isSelected),
                    onChanged: (val) {
                      for (var item in controller.shipperFiles) {
                        item.isSelected = val ?? false;
                      }
                      controller.shipperFiles.refresh();
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text('Shipper', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text('File Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                const Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text('Upload Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text('Rates', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text('File Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Table Data Rows
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.shipperFiles.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = controller.shipperFiles[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Checkbox(
                          value: item.isSelected,
                          onChanged: (val) => controller.toggleSelectFile(index, val),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Shipper Name + Avatar Column
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFDBEAFE),
                              child: Text(
                                item.shipperName[0],
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.shipperName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // File Name Column
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.fileName,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      // Upload Date Column
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.uploadDate,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      // Rates Column
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.rate,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      // File Status Column (Interactive Status Dropdown)
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusDropdown(index, item.status),
                        ),
                      ),
                      // Action Column
                      IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.shipperFileDetails),
                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(int index, String status) {
    Color bg;
    Color textColor;

    if (status == 'File Received') {
      bg = const Color(0xFFFEF9C3);
      textColor = const Color(0xFFD97706);
    } else if (status == 'Compared') {
      bg = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A);
    } else if (status == 'Revision Sent') {
      bg = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF2563EB);
    } else {
      bg = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A);
    }

    return PopupMenuButton<String>(
      onSelected: (newStatus) => controller.updateFileStatus(index, newStatus),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'File Received', child: Text('File Received', style: TextStyle(fontSize: 12))),
        PopupMenuItem(value: 'Compared', child: Text('Compared', style: TextStyle(fontSize: 12))),
        PopupMenuItem(value: 'Revision Sent', child: Text('Revision Sent', style: TextStyle(fontSize: 12))),
        PopupMenuItem(value: 'Order Sent', child: Text('Order Sent', style: TextStyle(fontSize: 12))),
      ],
      child: Container(
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
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 14, color: textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Row Per Page', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.inputBorder),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  children: const [
                    Text('10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 14),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text('Entries', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.chevron_left, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              _buildPageNumber('1', false),
              _buildPageNumber('2', false),
              _buildPageNumber('3', false),
              _buildPageNumber('4', true),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
              _buildPageNumber('15', false),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumber(String page, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Text(
        page,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
