import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/shipper_files_controller.dart';
import '../model/shipper_files_model.dart';

class ShipperFilesView extends GetView<ShipperFilesController> {
  const ShipperFilesView({super.key});

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
                      // Header Navigation Bar
                      _buildHeaderToolbar(),
                      const SizedBox(height: 16),

                      // 4 Summary Metric Cards
                      _buildSummaryMetricCards(),
                      const SizedBox(height: 16),

                      // Filter & Sort Toolbar
                      _buildFilterToolbar(),
                      const SizedBox(height: 16),

                      // Data Table Card
                      _buildDataTableCard(),
                      const SizedBox(height: 16),

                      // Pagination Footer Card
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
        const Text(
          'Project 1 - Shipper Files',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSummaryMetricCards() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Total Shipper Files', '58 Files', const Color(0xFF1E40AF), Icons.hardware)),
        const SizedBox(width: 14),
        Expanded(child: _buildMetricCard('Pending Upload', '12 Files', const Color(0xFF22C55E), Icons.shield_outlined)),
        const SizedBox(width: 14),
        Expanded(child: _buildMetricCard('Ready for Validation', '26 Files', const Color(0xFFEAB308), Icons.monetization_on_outlined)),
        const SizedBox(width: 14),
        Expanded(child: _buildMetricCard('Issues Detected', '8 Files', const Color(0xFFF97316), Icons.show_chart)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String count, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar() {
    return Row(
      children: [
        // Search Box
        Container(
          width: 240,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 16, color: AppColors.textHint),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textHint),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Filter Button
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.tune, size: 14, color: AppColors.textPrimary),
          label: const Text('Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),

        const Spacer(),

        // Sort Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              const Text('Sort by : ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedSort.value,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textPrimary),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  items: ['Latest', 'Oldest', 'Highest Rate']
                      .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) controller.selectedSort.value = val;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataTableCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Table Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 24, child: Checkbox(value: false, onChanged: null)),
                const SizedBox(width: 12),
                const Expanded(flex: 3, child: Text('Shipper ↑↓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                const Expanded(flex: 2, child: Text('File Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                const Expanded(flex: 2, child: Text('Upload Date ↑↓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                const Expanded(flex: 1, child: Text('Items ↑↓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                const Expanded(flex: 2, child: Text('Rate ↑↓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                const Expanded(flex: 2, child: Text('File Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Table Rows
          Obx(() {
            final list = controller.filteredFiles;
            return Column(
              children: list.map((item) => _buildTableRow(item)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableRow(ShipperFileItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.inputBorder)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24, child: Checkbox(value: false, onChanged: null)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFDBEAFE),
                  child: Icon(Icons.person, size: 14, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 8),
                Text(item.shipperName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(item.fileName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(item.uploadDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 1, child: Text('${item.items}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(item.rate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          Expanded(flex: 2, child: _buildStatusBadge(item.status)),
          SizedBox(
            width: 48,
            child: IconButton(
              onPressed: () => Get.toNamed(AppRoutes.shipperFileDetails),
              icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status;

    if (status == 'Approved') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
      label = 'Approved ✓';
    } else if (status == 'Compared') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
      label = '✓ Compared ⌄';
    } else {
      bg = const Color(0xFFFEF9C3);
      fg = const Color(0xFFCA8A04);
      label = 'Pending ⌄';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const Text('Row Per Page ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Text('10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Icon(Icons.keyboard_arrow_down, size: 14),
              ],
            ),
          ),
          const Text(' Entries', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Spacer(),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left, size: 18)),
              _buildPageBtn('1', false),
              _buildPageBtn('2', false),
              _buildPageBtn('3', false),
              _buildPageBtn('4', true),
              const Text(' ... '),
              _buildPageBtn('15', false),
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right, size: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageBtn(String page, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        page,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
