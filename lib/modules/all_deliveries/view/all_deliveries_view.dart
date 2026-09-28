import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/all_deliveries_controller.dart';
import '../model/all_delivery_model.dart';

class AllDeliveriesView extends StatefulWidget {
  const AllDeliveriesView({super.key});

  @override
  State<AllDeliveriesView> createState() => _AllDeliveriesViewState();
}

class _AllDeliveriesViewState extends State<AllDeliveriesView> {
  late final ScrollController _horizontalScrollController;
  final controller = Get.find<AllDeliveriesController>();

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7), // Soft neutral background matching design
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

                final statsMap = controller.stats;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      const Text(
                        'All Deliveries',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Comprehensive delivery management and tracking',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2-Row Metric Summary Cards Grid (8 Cards total)
                      _buildMetricCardsGrid(statsMap),
                      const SizedBox(height: 20),

                      // Search & Quick Action Bar
                      _buildSearchAndActionBar(context),
                      const SizedBox(height: 12),

                      // Expandable Advanced Filters Panel
                      if (controller.isAdvancedFilterOpen.value) ...[
                        _buildAdvancedFiltersPanel(context),
                        const SizedBox(height: 16),
                      ],

                      // Results Count & Column Visibility Toggles Row
                      _buildResultsAndColumnTogglesRow(),
                      const SizedBox(height: 16),

                      // Deliveries Data Table Card with Exact Design Colors
                      if (controller.errorMessage.value.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      else
                        _buildDeliveriesTableCard(context),
                      const SizedBox(height: 16),

                      // Pagination Footer Card
                      _buildPaginationFooter(),
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

  // 8 Metric Cards Layout with Exact Design Palette
  Widget _buildMetricCardsGrid(Map<String, int> statsMap) {
    final cardData = [
      {'label': 'Draft', 'count': statsMap['Draft'] ?? 1, 'color': const Color(0xFFD97706), 'bg': const Color(0xFFFEF3C7), 'icon': Icons.description_outlined},
      {'label': 'Total', 'count': statsMap['Total'] ?? 12, 'color': const Color(0xFF475569), 'bg': const Color(0xFFF1F5F9), 'icon': Icons.inventory_2_outlined},
      {'label': 'Scheduled', 'count': statsMap['Scheduled'] ?? 4, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFDBEAFE), 'icon': Icons.calendar_month_outlined},
      {'label': 'Confirmed', 'count': statsMap['Confirmed'] ?? 3, 'color': const Color(0xFF059669), 'bg': const Color(0xFFD1FAE5), 'icon': Icons.check_circle_outline},
      {'label': 'In Transit', 'count': statsMap['In Transit'] ?? 3, 'color': const Color(0xFF475569), 'bg': const Color(0xFFF1F5F9), 'icon': Icons.local_shipping_outlined},
      {'label': 'Delivered', 'count': statsMap['Delivered'] ?? 2, 'color': const Color(0xFF475569), 'bg': const Color(0xFFF1F5F9), 'icon': Icons.check_circle_outline},
      {'label': 'Delayed', 'count': statsMap['Delayed'] ?? 1, 'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEE2E2), 'icon': Icons.warning_amber_rounded},
      {'label': 'Cancelled', 'count': statsMap['Cancelled'] ?? 1, 'color': const Color(0xFFEF4444), 'bg': const Color(0xFFFEE2E2), 'icon': Icons.close},
    ];

    return Column(
      children: [
        Row(
          children: cardData.sublist(0, 4).map((data) => Expanded(
            child: _buildMetricCard(
              label: data['label'] as String,
              count: data['count'] as int,
              color: data['color'] as Color,
              bg: data['bg'] as Color,
              icon: data['icon'] as IconData,
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: cardData.sublist(4, 8).map((data) => Expanded(
            child: _buildMetricCard(
              label: data['label'] as String,
              count: data['count'] as int,
              color: data['color'] as Color,
              bg: data['bg'] as Color,
              icon: data['icon'] as IconData,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required int count,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }

  // Search Bar & Action Buttons
  Widget _buildSearchAndActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                  hintText: 'Search by ID, project, customer, item...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedStatus.value,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                items: controller.statuses
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (val) => controller.selectedStatus.value = val ?? 'All Status',
              ),
            ),
          ),
          const SizedBox(width: 12),

          OutlinedButton.icon(
            onPressed: controller.toggleAdvancedFilters,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 42),
              side: BorderSide(
                color: controller.isAdvancedFilterOpen.value ? AppColors.primary : const Color(0xFFCBD5E1),
              ),
              backgroundColor: controller.isAdvancedFilterOpen.value ? const Color(0xFFEFF6FF) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: Icon(
              Icons.tune_rounded,
              size: 18,
              color: controller.isAdvancedFilterOpen.value ? AppColors.primary : const Color(0xFF475569),
            ),
            label: Text(
              'Advanced Filters',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: controller.isAdvancedFilterOpen.value ? AppColors.primary : const Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 12),

          OutlinedButton.icon(
            onPressed: controller.exportCSV,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 42),
              side: const BorderSide(color: Color(0xFF10B981)),
              foregroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text(
              'Export CSV',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Expandable Advanced Filters Panel
  Widget _buildAdvancedFiltersPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildFilterInput('Date From', 'DD/MM/YYYY')),
              const SizedBox(width: 16),
              Expanded(child: _buildFilterInput('Date To', 'DD/MM/YYYY')),
              const SizedBox(width: 16),
              Expanded(child: _buildFilterDropdown('Project', controller.selectedProject, controller.options('All Project', (item) => item.project))),
              const SizedBox(width: 16),
              Expanded(child: _buildFilterDropdown('Customer', controller.selectedCustomer, controller.options('All Customer', (item) => item.customer))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFilterDropdown('Vendor', controller.selectedVendor, controller.options('All Vendor', (item) => item.vendor))),
              const SizedBox(width: 16),
              Expanded(child: _buildFilterDropdown('Delivery Company', controller.selectedCarrier, controller.options('All Carriers', (item) => item.carrier))),
              const SizedBox(width: 16),
              Expanded(child: _buildFilterDropdown('Material Category', controller.selectedCategory, controller.options('All Categories', (item) => item.category))),
              const SizedBox(width: 16),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFilterDropdown('Equipment Required', controller.selectedEquipment, controller.options('All Equipment', (item) => item.equipment))),
              const SizedBox(width: 16),
              Expanded(child: _buildFilterDropdown('Status', controller.selectedStatus, controller.statuses)),
              const SizedBox(width: 16),
              Expanded(child: _buildFilterDropdown('Internal Owner', controller.selectedOwner, controller.options('All Internal Owner', (item) => item.internalOwner))),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: controller.clearAllFilters,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.clear_all, size: 16, color: Color(0xFF475569)),
                    label: const Text(
                      'Clear All Filters',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, RxString selectedValue, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        Obx(() => Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(selectedValue.value) ? selectedValue.value : options.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) {
                if (val != null) selectedValue.value = val;
              },
            ),
          ),
        )),
      ],
    );
  }

  // Results Count & Column Visibility Toggle Pills
  Widget _buildResultsAndColumnTogglesRow() {
    final cols = controller.visibleColumns;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() {
          final count = controller.filteredDeliveries.length;
          final start = count == 0 ? 0 : ((controller.currentPage.value - 1) * controller.itemsPerPage.value) + 1;
          final end = (start + controller.itemsPerPage.value - 1).clamp(0, count);
          return Text(
            'Showing $start to $end of $count deliveries',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
          );
        }),

        Obx(() => Row(
          children: [
            _buildColumnToggleChip('Project', cols['Project'] ?? true),
            _buildColumnToggleChip('Customer', cols['Customer'] ?? true),
            _buildColumnToggleChip('Vendor', cols['Vendor'] ?? true),
            _buildColumnToggleChip('Carrier', cols['Carrier'] ?? true),
            _buildColumnToggleChip('POC', cols['POC'] ?? true),
            _buildColumnToggleChip('Date', cols['Date'] ?? true),
          ],
        )),
      ],
    );
  }

  Widget _buildColumnToggleChip(String label, bool isChecked) {
    return InkWell(
      onTap: () => controller.toggleColumn(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              size: 16,
              color: isChecked ? AppColors.accent : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Deliveries Table Card with Exact Design Colors & Periwinkle Header
  Widget _buildDeliveriesTableCard(BuildContext context) {
    final items = controller.paginatedDeliveries;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No deliveries match the selected filters.', style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 8.0,
          radius: const Radius.circular(4),
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFE0E7FF)), // Exact soft periwinkle blue header tint from design!
              dataRowMaxHeight: 85,
              dataRowMinHeight: 75,
              horizontalMargin: 20,
              columnSpacing: 28,
              columns: [
                const DataColumn(label: Text('ID ↑↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                const DataColumn(label: Text('Status ↑↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                if (controller.visibleColumns['Date'] ?? true)
                  const DataColumn(label: Text('Delivery Date-Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                const DataColumn(label: Text('Date & Time / Items ↑↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                if (controller.visibleColumns['Project'] ?? true)
                  const DataColumn(label: Text('Project ↑↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                if (controller.visibleColumns['Customer'] ?? true)
                  const DataColumn(label: Text('Customer ↑↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                if (controller.visibleColumns['Vendor'] ?? true)
                  const DataColumn(label: Text('Vendor ↑↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                if (controller.visibleColumns['Carrier'] ?? true)
                  const DataColumn(label: Text('Carrier ↑↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                if (controller.visibleColumns['POC'] ?? true)
                  const DataColumn(label: Text('POC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                const DataColumn(label: Text('Equipment Required ↑↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                const DataColumn(label: Text('Site Location ↑↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
              ],
              rows: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return DataRow(
                  color: WidgetStateProperty.all(index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC)),
                  cells: _buildDataRowCells(item),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataCell> _buildDataRowCells(AllDeliveryModel item) {
    final cols = controller.visibleColumns;

    return [
      // ID & Priority Pill
      DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.id,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB), // Exact blue text from image!
              ),
            ),
            const SizedBox(height: 4),
            _buildPriorityPill(item.priority),
          ],
        ),
      ),

      // Status Badge Pill
      DataCell(_buildStatusBadge(item.status)),

      // Delivery Date-Time (Column 3)
      if (cols['Date'] ?? true)
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.deliveryDate,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              Text(
                item.timeWindow,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),

      // Date & Time / Items Description Column
      DataCell(
        SizedBox(
          width: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.items,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),

      // Project
      if (cols['Project'] ?? true)
        DataCell(
          SizedBox(
            width: 140,
            child: Text(
              item.project,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),

      // Customer
      if (cols['Customer'] ?? true)
        DataCell(
          SizedBox(
            width: 130,
            child: Text(
              item.customer,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

      // Vendor
      if (cols['Vendor'] ?? true)
        DataCell(
          SizedBox(
            width: 120,
            child: Text(
              item.vendor,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

      // Carrier
      if (cols['Carrier'] ?? true)
        DataCell(
          SizedBox(
            width: 140,
            child: Text(
              item.carrier,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

      // POC Info (Name + Phone Icon + Mail Icon)
      if (cols['POC'] ?? true)
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.pocName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_outlined, size: 11, color: Color(0xFF2563EB)),
                  const SizedBox(width: 4),
                  Text(item.pocPhone, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mail_outline_rounded, size: 11, color: Color(0xFF2563EB)),
                  const SizedBox(width: 4),
                  Text(item.pocEmail, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ),

      // Equipment Required
      DataCell(
        Text(
          item.equipment,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
        ),
      ),

      // Site Location
      DataCell(
        SizedBox(
          width: 160,
          child: Text(
            item.site,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),

      // Actions Column (...)
      DataCell(
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF94A3B8)),
          onPressed: () {
            CommonSnackbar.showInfo(
              title: 'Actions',
              message: 'Options for ${item.id}',
            );
          },
        ),
      ),
    ];
  }

  // Priority Pill Badge (Normal, High, Critical)
  Widget _buildPriorityPill(String priority) {
    Color bg = const Color(0xFFDCFCE7);
    Color text = const Color(0xFF16A34A);

    if (priority.toLowerCase() == 'high') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
    } else if (priority.toLowerCase() == 'critical') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        priority,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  // Status Badge Pill (Delay, Delivered, Pending, Canceled, Confirmed, Draft, In Transit)
  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFDBEAFE);
    Color text = const Color(0xFF2563EB);
    IconData icon = Icons.schedule;

    final lower = status.toLowerCase();
    if (lower.contains('delay')) {
      bg = const Color(0xFFDBEAFE);
      text = const Color(0xFF2563EB);
      icon = Icons.calendar_month_outlined;
    } else if (lower.contains('deliver')) {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
      icon = Icons.check_circle_outline;
    } else if (lower.contains('confirm')) {
      bg = const Color(0xFFD1FAE5);
      text = const Color(0xFF059669);
      icon = Icons.check_circle_outline;
    } else if (lower.contains('pending')) {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFD97706);
      icon = Icons.access_time_rounded;
    } else if (lower.contains('draft')) {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
      icon = Icons.description_outlined;
    } else if (lower.contains('cancel')) {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
      icon = Icons.warning_amber_rounded;
    } else if (lower.contains('transit')) {
      bg = const Color(0xFFF1F5F9);
      text = const Color(0xFF475569);
      icon = Icons.local_shipping_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text),
          ),
        ],
      ),
    );
  }

  // Pagination Footer Card
  Widget _buildPaginationFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
            'Page ${controller.currentPage.value} of ${controller.totalPages}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          )),

          Obx(() {
            final page = controller.currentPage.value;
            final maxPage = controller.totalPages;

            return Row(
              children: [
                _buildPageNavBtn('First', page > 1, () => controller.currentPage.value = 1),
                const SizedBox(width: 6),
                _buildPageNavBtn('<', page > 1, () => controller.currentPage.value--),
                const SizedBox(width: 6),
                _buildPageNumBtn(1, page == 1),
                if (maxPage >= 2) ...[
                  const SizedBox(width: 6),
                  _buildPageNumBtn(2, page == 2),
                ],
                const SizedBox(width: 6),
                _buildPageNavBtn('>', page < maxPage, () => controller.currentPage.value++),
                const SizedBox(width: 6),
                _buildPageNavBtn('Last', page < maxPage, () => controller.currentPage.value = maxPage),
              ],
            );
          }),

          Obx(() => Text(
            '${controller.filteredDeliveries.length} total results',
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          )),
        ],
      ),
    );
  }

  Widget _buildPageNavBtn(String label, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: enabled ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumBtn(int num, bool isActive) {
    return InkWell(
      onTap: () => controller.currentPage.value = num,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$num',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
