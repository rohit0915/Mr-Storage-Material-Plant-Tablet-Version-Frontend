import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/qr_labels_controller.dart';

class QrLabelsView extends GetView<QrLabelsController> {
  const QrLabelsView({super.key});

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'QR Labels',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Generate, manage, and print QR labels for bundles and pallets to enable tracking and\nverification across plant and field operations.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () {
            Get.snackbar('Export', 'Exporting QR Labels data',
                snackPosition: SnackPosition.BOTTOM);
          },
          icon: const Icon(Icons.ios_share, size: 14, color: AppColors.textPrimary),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: const InputDecoration(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Checkbox(
                    value: controller.projectsList.isNotEmpty &&
                        controller.projectsList.every((item) => item.isSelected),
                    onChanged: (val) => controller.toggleSelectAllProjects(val),
                    activeColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Project ID',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Project Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(
                        'QR Generated Date',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(
                        'Total QR Labels',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Actions',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.projectsList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = controller.projectsList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Checkbox(
                          value: item.isSelected,
                          onChanged: (val) => controller.toggleSelectProject(index, val),
                          activeColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.id,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.projectName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.qrGeneratedDate,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${item.totalQrLabels}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => controller.openProjectQrLabels(item),
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.inputBorder),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.textPrimary),
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
