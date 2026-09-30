import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/missing_item_cost_controller.dart';

class MissingItemCostListView extends GetView<MissingItemCostController> {
  const MissingItemCostListView({super.key});

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

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(controller.errorMessage.value),
                        TextButton(
                          onPressed: controller.loadMissingItems,
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
                      // Header Navigation & Actions Bar
                      _buildHeaderToolbar(context),

                      const SizedBox(height: 20),

                      // Missing Summary Box
                      _buildMissingSummaryCard(),

                      const SizedBox(height: 24),

                      // Search & Filter Controls
                      _buildFilterControlsBar(),

                      const SizedBox(height: 16),

                      // Table Container
                      _buildMissingItemTable(context),

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Missing Item Cost List',
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
            'Export',
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

        // Save & Continue button
        ElevatedButton(
          onPressed: () => controller.saveAndContinue(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Save & Continue',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissingSummaryCard() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Missing Item in Cost list',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Missing QTY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              Obx(
                () => Text(
                  '${controller.missingQty.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          child: TextField(
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

        // Filter button
        OutlinedButton.icon(
          onPressed: controller.loadMissingItems,
          icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF475569)),
          label: const Text(
            'Refresh',
            style: TextStyle(
              fontSize: 12,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    items: ['Latest', 'Name A-Z', 'Part Colour']
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

  Widget _buildMissingItemTable(BuildContext context) {
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
              'Missing Item in Cost List',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                _buildTh('Part Name', flex: 2),
                _buildTh('Part Colour', flex: 1, sortable: true),
                _buildTh('Cost Unit', flex: 1, sortable: true),
                _buildTh('Cost', flex: 1, sortable: true),
                _buildTh('Current Market Cost', flex: 2, sortable: true),
                _buildTh('Description', flex: 2, sortable: true),
                const SizedBox(
                  width: 60,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Rows
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredItems.length,
              separatorBuilder: (ctx, idx) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (ctx, index) {
                final item = controller.filteredItems[index];
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
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      _buildTd(item.partName, flex: 2, isBold: true),
                      _buildTd(item.partColor, flex: 1),
                      _buildTd(item.costUnit, flex: 1),

                      // Cost Column - Light Red/Pink Highlight for "Missing"
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Missing',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ),
                      ),

                      _buildTd(
                        item.currentMarketCost != null
                            ? '\$${item.currentMarketCost}'
                            : '-',
                        flex: 2,
                      ),
                      _buildTd(item.description, flex: 2),

                      // Add Action Button
                      SizedBox(
                        width: 60,
                        child: ElevatedButton(
                          onPressed: () => controller.openAddCostForItemDialog(
                            context,
                            item,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            elevation: 0,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Add',
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
