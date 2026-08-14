import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/savings_controller.dart';

class SavingsView extends GetView<SavingsController> {
  const SavingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Navigation & Actions Bar
                      _buildHeaderToolbar(context),

                      const SizedBox(height: 20),

                      // KPI Cards Row
                      _buildKpiSummaryCards(),

                      const SizedBox(height: 24),

                      // Filter Bar (Search + Date Filter + Status Filter)
                      _buildFilterControlsBar(context),

                      const SizedBox(height: 16),

                      // Savings List Table Container
                      _buildSavingsTable(context),

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

  Widget _buildHeaderToolbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Savings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => controller.exportFile(context),
          icon: const Icon(Icons.upload_outlined, size: 16, color: Color(0xFF475569)),
          label: const Text(
            'Export',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiSummaryCards() {
    final s = controller.summary.value;
    return Row(
      children: [
        // Total Savings This Month - Green Card
        Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Savings This Month',
                    style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${s.totalSavingsThisMonth.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const Icon(
                Icons.trending_up,
                size: 38,
                color: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Total Loss This Month - Orange Card
        Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Loss This Month',
                    style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${s.totalLossThisMonth.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterControlsBar(BuildContext context) {
    return Row(
      children: [
        // Search bar
        Container(
          width: 240,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextField(
            onChanged: (val) => controller.filterSearchResults(val),
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              prefixIcon: Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),

        const Spacer(),

        // Date Filter Dropdown button
        InkWell(
          onTap: () => controller.openDatePickerDialog(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune, size: 14, color: Color(0xFF475569)),
                const SizedBox(width: 6),
                Obx(
                  () => Text(
                    controller.formattedSelectedDate,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF475569)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Status Filter Dropdown
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.tune, size: 14, color: Color(0xFF475569)),
              const SizedBox(width: 6),
              DropdownButtonHideUnderline(
                child: Obx(
                  () => DropdownButton<String>(
                    value: controller.selectedStatusFilter.value,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF475569)),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    onChanged: (val) {
                      if (val != null) controller.setStatusFilter(val);
                    },
                    items: ['Status : Good', 'Status : Over Budget', 'All']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Savings List',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                _buildTh('Project Name', flex: 3),
                _buildTh('SMDT Cost', flex: 2),
                _buildTh('Actual Cost', flex: 2, sortable: true),
                _buildTh('Savings', flex: 2),
                _buildTh('Profit / Loss', flex: 2),
                _buildTh('Savings %', flex: 2),
                _buildTh('Status', flex: 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Rows
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredSavingsList.length,
              separatorBuilder: (ctx, idx) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (ctx, index) {
                final item = controller.filteredSavingsList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _buildTd(item.projectName, flex: 3, isBold: true),
                      _buildTd('\$${_formatAmount(item.smdtCost)}', flex: 2),
                      _buildTd('\$${_formatAmount(item.actualCost)}', flex: 2),
                      _buildTd(
                        item.savings < 0
                            ? '-\$${_formatAmount(item.savings.abs())}'
                            : '\$${_formatAmount(item.savings)}',
                        flex: 2,
                      ),
                      // Profit / Loss text
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.isProfit ? 'Profit' : 'Loss',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: item.isProfit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                      _buildTd('${item.savingsPercentage}%', flex: 2),
                      // Status Badge
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.status == 'Good' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.status,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Footer Pagination
          CommonPaginationFooter(
            currentPage: controller.currentPage.value,
            totalPages: controller.totalPages.value,
            rowsPerPage: controller.rowsPerPage.value,
            onPageChanged: (page) => controller.currentPage.value = page,
            onRowsPerPageChanged: (rows) => controller.rowsPerPage.value = rows,
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amt) {
    return amt.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
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
              color: Color(0xFF334155),
            ),
          ),
          if (sortable) ...[
            const SizedBox(width: 4),
            const Icon(Icons.swap_vert, size: 12, color: Color(0xFF94A3B8)),
          ],
        ],
      ),
    );
  }

  Widget _buildTd(String text, {int flex = 1, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }
}
