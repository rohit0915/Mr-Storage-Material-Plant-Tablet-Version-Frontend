import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/item_cost_controller.dart';

class ItemCostListView extends GetView<ItemCostController> {
  const ItemCostListView({super.key});

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

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(controller.errorMessage.value),
                        TextButton(
                          onPressed: controller.loadItemCosts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Navigation & Top Action Buttons
                      _buildHeaderToolbar(context),

                      const SizedBox(height: 20),

                      // KPI Cards Row
                      _buildKpiSummaryCards(),

                      const SizedBox(height: 24),

                      // Filter & Search Controls Bar
                      _buildFilterControlsBar(),

                      const SizedBox(height: 16),

                      // Part Cost Table Container
                      _buildPartCostTable(context),
                      Obx(
                        () => CommonPaginationFooter(
                          currentPage: controller.currentPage.value,
                          totalPages: controller.totalPages,
                          totalEntries: controller.totalItems.value,
                          rowsPerPage: controller.rowsPerPage.value,
                          onPageChanged: controller.changePage,
                          onRowsPerPageChanged: controller.changeRows,
                        ),
                      ),

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
      children: [
        const AppBackButton(),
        const SizedBox(width: 16),
        const Text(
          'Item Cost List',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        // Export button
        OutlinedButton.icon(
          onPressed: () => controller.exportFile(context),
          icon: const Icon(
            Icons.upload_outlined,
            size: 16,
            color: Color(0xFF475569),
          ),
          label: const Text(
            'Export SMD list',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(width: 12),

        // Check BOM Costing button
        ElevatedButton.icon(
          onPressed: () => controller.openUploadBomDialog(context),
          icon: const Icon(
            Icons.add_circle_outline,
            size: 16,
            color: Colors.white,
          ),
          label: const Text(
            'Check BOM Costing',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF64748B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(width: 12),

        // Add New Item/Part Cost button
        ElevatedButton.icon(
          onPressed: () => controller.openAddPartCostDialog(context),
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: const Text(
            'Add New Item/Part Cost',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
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

  Widget _buildKpiSummaryCards() {
    final s = controller.summary.value;
    return Row(
      children: [
        // Total Item Cost - Blue Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Item Cost',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${s.totalItemCost.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Total Items - Green Card
        Expanded(
          child: Container(
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
                      'Total Items',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${s.totalItems}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.trending_up, size: 38, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // New Added - Orange Card
        Expanded(
          child: Container(
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
                      'New Added',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${s.newAdded}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
        ),
      ],
    );
  }

  Widget _buildFilterControlsBar() {
    return Row(
      children: [
        // Search bar
        Container(
          width: 220,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextFormField(
            initialValue: controller.searchQuery.value,
            onChanged: (val) => controller.filterSearchResults(val),
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              prefixIcon: Icon(
                Icons.search,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Categories dropdown
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.category.value,
              onChanged: (value) => controller.category.value = value ?? '',
              items:
                  <String>{
                        '',
                        ...controller.categories,
                        controller.category.value,
                      }
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.isEmpty ? 'All Categories' : value),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),

        const Spacer(),

        // Sort by dropdown
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
              const Text(
                'Sort by : ',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              DropdownButtonHideUnderline(
                child: Obx(
                  () => DropdownButton<String>(
                    value: controller.sortBy.value,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Color(0xFF475569),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    onChanged: (val) {
                      if (val != null) controller.sortBy.value = val;
                    },
                    items: ['Latest', 'Name A-Z', 'MBS Cost High-Low']
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

  Widget _buildPartCostTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: const Text(
              'Part Cost List',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1280,
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Checkbox(
                            value: controller.selectAll.value,
                            onChanged: controller.toggleSelectAll,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                        _buildTh('Part Colour', flex: 2, sortable: true),
                        _buildTh('Cost Unit', flex: 1, sortable: true),
                        _buildTh('MBS Cost', flex: 1, sortable: true),
                        _buildTh(
                          'Current Market Cost',
                          flex: 2,
                          sortable: true,
                        ),
                        _buildTh('Labor Cost', flex: 1, sortable: true),
                        _buildTh('Additional Cost', flex: 1, sortable: true),
                        _buildTh('Material Cost', flex: 1, sortable: true),
                        _buildTh('Description', flex: 3, sortable: true),
                        _buildTh('Is Frame Type', flex: 2, sortable: true),
                        _buildTh('Status', flex: 1, sortable: true),
                        const SizedBox(
                          width: 60,
                          child: Text(
                            'Actions',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Table Rows
                  Obx(
                    () => ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredItemCosts.length,
                      separatorBuilder: (ctx, idx) =>
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (ctx, index) {
                        final item = controller.filteredItemCosts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Checkbox(
                                  value: item.isSelected,
                                  onChanged: (val) =>
                                      controller.toggleSelectItem(item, val),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                              _buildTd(
                                item.partColor.isNotEmpty ? item.partColor : '',
                                flex: 2,
                              ),
                              _buildTd(item.costUnit, flex: 1),
                              _buildTd(
                                item.mbsCost != null ? '${item.mbsCost}' : '0',
                                flex: 1,
                              ),
                              _buildTd(
                                item.currentMarketCost != null
                                    ? '${item.currentMarketCost}'
                                    : '0',
                                flex: 2,
                              ),
                              _buildTd(
                                item.laborCost.toStringAsFixed(
                                  item.laborCost.truncateToDouble() ==
                                          item.laborCost
                                      ? 0
                                      : 2,
                                ),
                                flex: 1,
                              ),
                              _buildTd(
                                item.additionalCost.toStringAsFixed(
                                  item.additionalCost.truncateToDouble() ==
                                          item.additionalCost
                                      ? 0
                                      : 2,
                                ),
                                flex: 1,
                              ),
                              _buildTd(
                                item.materialCost.toStringAsFixed(
                                  item.materialCost.truncateToDouble() ==
                                          item.materialCost
                                      ? 0
                                      : 2,
                                ),
                                flex: 1,
                              ),
                              _buildTd(item.description, flex: 3, isBold: true),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.isFrameType,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: ElevatedButton(
                                  onPressed: () => controller
                                      .openEditPartCostDialog(context, item),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    elevation: 0,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Edit',
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
