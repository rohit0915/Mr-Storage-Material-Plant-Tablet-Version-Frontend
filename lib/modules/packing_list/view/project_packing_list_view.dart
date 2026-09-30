import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/packing_list_controller.dart';
import '../model/packing_list_model.dart';

class ProjectPackingListView extends GetView<PackingListController> {
  const ProjectPackingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final reqId = Get.parameters['id'] ?? '';
    final reqName = Get.parameters['name'] ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initProjectPackingList(reqId, reqName);
    });

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
                      _buildHeaderToolbar(context),
                      const SizedBox(height: 20),
                      _buildFilterControlsRow(context),
                      const SizedBox(height: 16),
                      _buildPackingListTableCard(context),
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

  Widget _buildHeaderToolbar(BuildContext context) {
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
                    'Packing List: ${controller.selectedProjectName.value.isEmpty ? '—' : controller.selectedProjectName.value}',
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
            ElevatedButton(
              onPressed: () => _showPackingDetailModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'View Full Detail',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
      ],
    );
  }

  Widget _buildPackingListTableCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Table Header (Matching Screenshot 1)
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                _buildThWidget(
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
                  width: 40,
                ),
                _buildTh('Packing ID', flex: 2),
                _buildTh('Load ID', flex: 2),
                _buildTh('Truck', flex: 2, hasSortIcon: true),
                _buildTh('Bundles', flex: 1, hasSortIcon: true),
                _buildTh('Weight', flex: 2, hasSortIcon: true),
                _buildTh('Status', flex: 2),
                _buildTh('Action', width: 72, isLast: true),
              ],
            ),
          ),

          // Table Data Rows
          Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.packingItemsList.length,
              itemBuilder: (ctx, index) {
                final item = controller.packingItemsList[index];
                return IntrinsicHeight(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTdWidget(
                          SizedBox(
                            width: 28,
                            child: Checkbox(
                              value: item.isSelected,
                              onChanged: (val) => controller
                                  .toggleSelectPackingItem(index, val),
                              activeColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          width: 40,
                        ),
                        _buildTdWidget(
                          Text(
                            item.packingId,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          flex: 2,
                        ),
                        _buildTdWidget(
                          Text(
                            item.loadId,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          flex: 2,
                        ),
                        _buildTdWidget(
                          Text(
                            item.truck,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          flex: 2,
                        ),
                        _buildTdWidget(
                          Text(
                            '${item.bundles}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          flex: 1,
                        ),
                        _buildTdWidget(
                          Text(
                            item.weight,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          flex: 2,
                        ),
                        _buildTdWidget(
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _buildStatusBadge(item.status),
                          ),
                          flex: 2,
                        ),
                        _buildTdWidget(
                          ElevatedButton(
                            onPressed: () =>
                                _showPackingDetailModal(context, item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
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
                          width: 72,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showPackingDetailModal(
    BuildContext context, [
    PackingListItemModel? selectedItem,
  ]) {
    final item =
        selectedItem ??
        (controller.packingItemsList.isNotEmpty
            ? controller.packingItemsList.first
            : null);
    final bundles = (item != null && item.bundleList.isNotEmpty)
        ? item.bundleList
        : [
            BundleListItemModel(
              id: 1,
              bundleId: 'B-012',
              profile: 'framing',
              partNumber: 'framing',
              items: '72',
              quantity: 72,
              length: '26.29ft',
              unitWeight: '4,940.70 LBS',
              status: 'Assigned_to_truck',
            ),
            BundleListItemModel(
              id: 2,
              bundleId: 'B-004',
              profile: 'framing',
              partNumber: 'framing',
              items: '9',
              quantity: 9,
              length: '28.06ft',
              unitWeight: '4,848.30 LBS',
              status: 'Assigned_to_truck',
            ),
            BundleListItemModel(
              id: 3,
              bundleId: 'B-009',
              profile: 'framing',
              partNumber: 'framing',
              items: '2',
              quantity: 2,
              length: '51.67ft',
              unitWeight: '2,747.40 LBS',
              status: 'Assigned_to_truck',
            ),
            BundleListItemModel(
              id: 4,
              bundleId: 'B-010',
              profile: 'framing',
              partNumber: 'framing',
              items: '30',
              quantity: 30,
              length: '25.13ft',
              unitWeight: '2,403.20 LBS',
              status: 'Assigned_to_truck',
            ),
            BundleListItemModel(
              id: 5,
              bundleId: 'B-013',
              profile: 'framing',
              partNumber: 'framing',
              items: '26',
              quantity: 26,
              length: '26.29ft',
              unitWeight: '1,772.90 LBS',
              status: 'Assigned_to_truck',
            ),
            BundleListItemModel(
              id: 6,
              bundleId: 'B-011',
              profile: 'framing',
              partNumber: 'framing',
              items: '24',
              quantity: 24,
              length: '27.29ft',
              unitWeight: '1,709.60 LBS',
              status: 'Assigned_to_truck',
            ),
            BundleListItemModel(
              id: 7,
              bundleId: 'B-016',
              profile: 'panels',
              partNumber: 'panels',
              items: '74',
              quantity: 74,
              length: '27.00ft',
              unitWeight: '5,280.70 LBS',
              status: 'Assigned_to_truck',
            ),
          ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 920,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Row (Matching Screenshot 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                    label: const Text(
                      'Back',
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
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: controller.downloadPackingPdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Download PDF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: controller.exportPackingLists,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Export Excel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Load Information & Packing Summary (Matching Screenshot 2)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Load Information',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _modalMetaRow(
                          'Packing List ID',
                          item?.packingId ?? '—',
                        ),
                        _modalMetaRow('Load ID', item?.loadId ?? '—'),
                        _modalMetaRow(
                          'Project',
                          controller.selectedProjectName.value.isEmpty
                              ? '—'
                              : controller.selectedProjectName.value,
                        ),
                        _modalMetaRow('Truck', item?.truck ?? '—'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Packing Summary',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _modalMetaRow(
                          'Total Bundles',
                          '${item?.bundles ?? '—'}',
                        ),
                        _modalMetaRow(
                          'Total Items',
                          '${item?.totalItems ?? '—'}',
                        ),
                        _modalMetaRow(
                          'Total weight',
                          item?.weight != null
                              ? (item!.weight.toLowerCase().contains('lbs')
                                    ? item.weight.replaceAll('LBS', 'lbs')
                                    : '${item.weight} lbs')
                              : '—',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Bundle List Table Header
              const Text(
                'Bundle List',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Bundle List Table (Matching Screenshot 2 Dark Navy Theme)
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          color: const Color(0xFF1E293B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 36,
                                child: Text(
                                  '#',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Bundle ID',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Part Number',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Quantity',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Length',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Weight',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Status',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...bundles.map(
                          (b) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFF1F5F9)),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '${b.id}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    b.bundleId,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    b.partNumber,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${b.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    b.length,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    b.unitWeight,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    b.status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTh(
    String label, {
    int flex = 2,
    double? width,
    bool isLast = false,
    bool hasSortIcon = false,
  }) {
    return _buildThWidget(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (hasSortIcon) ...[
            const SizedBox(width: 2),
            const Icon(
              Icons.swap_vert,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
      flex: flex,
      width: width,
      isLast: isLast,
    );
  }

  Widget _buildThWidget(
    Widget child, {
    int flex = 2,
    double? width,
    bool isLast = false,
  }) {
    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (width != null) return SizedBox(width: width, child: container);
    return Expanded(flex: flex, child: container);
  }

  Widget _buildTdWidget(
    Widget child, {
    int flex = 2,
    double? width,
    bool isLast = false,
  }) {
    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (width != null) return SizedBox(width: width, child: container);
    return Expanded(flex: flex, child: container);
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0284C7),
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return CommonPaginationFooter(
      currentPage: 1,
      totalPages: 1,
      rowsPerPage: 10,
    );
  }
}
