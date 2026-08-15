import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/packing_list_controller.dart';

class ProjectPackingListView extends GetView<PackingListController> {
  const ProjectPackingListView({super.key});

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderToolbar(),
                      const SizedBox(height: 20),
                      _buildFilterControlsRow(context),
                      const SizedBox(height: 16),
                      _buildPackingListTableCard(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    '${controller.selectedProjectName.value} - Packing List',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'View and manage packing lists generated from load planning for plant loading and\nshipment verification.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: controller.exportPackingLists,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterControlsRow(BuildContext context) {
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
        PopupMenuButton<String>(
          onSelected: (val) => controller.selectProjectFilter(val),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(0, 42),
          itemBuilder: (context) {
            return [
              PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: const [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Select Project',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ...controller.availableProjects.map(
                (proj) => PopupMenuItem<String>(
                  value: proj,
                  child: Text(
                    proj,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ];
          },
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
                  Icons.filter_alt_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Obx(
                  () => Text(
                    controller.selectedProjectFilter.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
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
              Icon(Icons.sort, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Sort by : Latest',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackingListTableCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Checkbox(
                    value:
                        controller.packingItemsList.isNotEmpty &&
                        controller.packingItemsList.every(
                          (item) => item.isSelected,
                        ),
                    onChanged: (val) =>
                        controller.toggleSelectAllPackingItems(val),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Packing ID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Load ID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Truck',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.swap_vert,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        'Bundles',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.swap_vert,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.swap_vert,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Destination',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.swap_vert,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.swap_vert,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 60),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.packingItemsList.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = controller.packingItemsList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Checkbox(
                          value: item.isSelected,
                          onChanged: (val) =>
                              controller.toggleSelectPackingItem(index, val),
                          activeColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.packingId,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.loadId,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.truck,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.bundles}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.weight,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.destination,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusBadge(item.status),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: ElevatedButton(
                          onPressed: () =>
                              controller.openPackingListDetails(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _buildStatusBadge(String status) {
    if (status == 'Dispatched') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Dispatched',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.check_circle_outline,
              size: 12,
              color: Color(0xFF16A34A),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Ready',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.check_circle, size: 12, color: Color(0xFF2563EB)),
          ],
        ),
      );
    }
  }

  Widget _buildPaginationFooter() {
    return CommonPaginationFooter(
      currentPage: 1,
      totalPages: 15,
      rowsPerPage: 10,
    );
  }
}
