import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/qr_labels_controller.dart';

class ProjectQrLabelsView extends GetView<QrLabelsController> {
  const ProjectQrLabelsView({super.key});

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
                      // Back Button
                      ElevatedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
                        label: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header Toolbar
                      _buildHeaderToolbar(),
                      const SizedBox(height: 20),

                      // Filter Row
                      _buildFilterRow(),
                      const SizedBox(height: 16),

                      // Bundle QR Labels Table Card
                      _buildBundleTableCard(),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  '${controller.selectedProjectName.value} - QR Labels',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                )),
            const SizedBox(height: 4),
            const Text(
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
            Get.snackbar('Export', 'Exporting project QR labels',
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
        // Search Input
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

        // Select Project Filter Dropdown
        Obx(() => PopupMenuButton<String>(
              onSelected: (val) => controller.selectProjectFilter(val),
              itemBuilder: (context) => controller.availableProjects
                  .map((proj) => PopupMenuItem<String>(
                        value: proj,
                        child: Text(proj, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      controller.selectedProjectFilter.value,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )),
        const Spacer(),

        // Sort By Dropdown
        Obx(() => PopupMenuButton<String>(
              onSelected: (val) => controller.selectSort(val),
              itemBuilder: (context) => ['Latest', 'Oldest', 'Bundle ID']
                  .map((s) => PopupMenuItem<String>(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Sort by : ${controller.selectedSort.value}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildBundleTableCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Checkbox(
                    value: controller.bundleLabelsList.isNotEmpty &&
                        controller.bundleLabelsList.every((item) => item.isSelected),
                    onChanged: (val) => controller.toggleSelectAllBundles(val),
                    activeColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Bundle ID',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Load ID',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Parts',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Weight',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Length',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 140), // Actions Column width
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Data Rows
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.bundleLabelsList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = controller.bundleLabelsList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Checkbox(
                          value: item.isSelected,
                          onChanged: (val) => controller.toggleSelectBundle(index, val),
                          activeColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.bundleId,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.loadId,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.parts,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.weight,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.length,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusBadge(item.status),
                        ),
                      ),

                      // Action Buttons (View & Print)
                      SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => controller.showQrCodeDialog(item),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Get.snackbar('Print', 'Printing ${item.bundleId}',
                                    snackPosition: SnackPosition.BOTTOM);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B5AD),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text(
                                'Print',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                          ],
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
    final isPrinted = status == 'Printed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrinted ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPrinted ? const Color(0xFF166534) : const Color(0xFF0369A1),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isPrinted ? Icons.check_circle_outline : Icons.adjust,
            size: 12,
            color: isPrinted ? const Color(0xFF166534) : const Color(0xFF0369A1),
          ),
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
              const Text('Showing', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
              const Text('Results', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.chevron_left, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              _buildPageNumber('1', true),
              _buildPageNumber('2', false),
              _buildPageNumber('3', false),
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
        color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isSelected ? Border.all(color: const Color(0xFF6366F1)) : null,
      ),
      child: Text(
        page,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF4338CA) : AppColors.textSecondary,
        ),
      ),
    );
  }
}
