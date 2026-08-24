import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/qr_labels_controller.dart';
import '../model/qr_labels_model.dart';

class ProjectQrLabelsView extends GetView<QrLabelsController> {
  const ProjectQrLabelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final reqId = Get.parameters['id'] ?? '';
    final reqName = Get.parameters['name'] ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initProjectQrLabels(reqId, reqName);
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
                      // Back Button
                      ElevatedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Colors.white,
                        ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
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
                      _buildBundleTableCard(context),
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
            Obx(
              () => Text(
                '${controller.selectedProjectName.value} - QR Labels',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
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
            Get.snackbar(
              'Export',
              'Exporting project QR labels',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
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
              const Icon(
                Icons.search,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: const InputDecoration(
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

        // Select Project Filter Dropdown
        Obx(
          () => PopupMenuButton<String>(
            onSelected: (val) => controller.selectProjectFilter(val),
            itemBuilder: (context) => controller.availableProjects
                .map(
                  (proj) => PopupMenuItem<String>(
                    value: proj,
                    child: Text(proj, style: const TextStyle(fontSize: 12)),
                  ),
                )
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
                  const Icon(
                    Icons.filter_alt_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.selectedProjectFilter.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),

        // Sort By Dropdown
        Obx(
          () => PopupMenuButton<String>(
            onSelected: (val) => controller.selectSort(val),
            itemBuilder: (context) => ['Latest', 'Oldest', 'Bundle ID']
                .map(
                  (s) => PopupMenuItem<String>(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 12)),
                  ),
                )
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
                  const Icon(
                    Icons.filter_list,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sort by : ${controller.selectedSort.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBundleTableCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Obx(() {
        if (controller.showingBundlesView.value) {
          return _buildBundlesQrTable();
        }
        return _buildPackingListsQrTable(context);
      }),
    );
  }

  Widget _buildPackingListsQrTable(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: const [
              SizedBox(width: 32),
              SizedBox(width: 12),
              Expanded(flex: 2, child: Text('Packing ID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
              Expanded(flex: 2, child: Text('Load ID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
              Expanded(flex: 2, child: Text('Truck', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
              Expanded(flex: 2, child: Text('Bundles', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
              Expanded(flex: 2, child: Text('Weight', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
              Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
              SizedBox(width: 220),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Obx(() {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.packingListItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final item = controller.packingListItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Checkbox(
                        value: item.isSelected,
                        onChanged: (val) {
                          item.isSelected = val ?? false;
                          controller.packingListItems.refresh();
                        },
                        activeColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: Text(item.packingId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                    Expanded(flex: 2, child: Text(item.loadId, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                    Expanded(flex: 2, child: Text(item.truck, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                    Expanded(flex: 2, child: Text('${item.bundlesCount}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                    Expanded(flex: 2, child: Text(item.weight, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                        child: Text(item.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showFullQrModalDialog(context, item),
                            icon: const Icon(Icons.qr_code_2_rounded, size: 14, color: Colors.white),
                            label: const Text('View QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              controller.selectedPackingId.value = item.packingId;
                              controller.showingBundlesView.value = true;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06B6D4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text('View Bundles', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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
    );
  }

  Widget _buildBundlesQrTable() {
    return Column(
      children: [
        // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Checkbox(
                    value:
                        controller.bundleLabelsList.isNotEmpty &&
                        controller.bundleLabelsList.every(
                          (item) => item.isSelected,
                        ),
                    onChanged: (val) => controller.toggleSelectAllBundles(val),
                    activeColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Bundle ID',
                    style: TextStyle(
                      fontSize: 13,
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
                      fontSize: 13,
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
                        'Parts',
                        style: TextStyle(
                          fontSize: 13,
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
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 13,
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
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        'Length',
                        style: TextStyle(
                          fontSize: 13,
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
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = controller.bundleLabelsList[index];
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
                              controller.toggleSelectBundle(index, val),
                          activeColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.bundleId,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.loadId,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.parts,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.weight,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.length,
                          style: const TextStyle(
                            fontSize: 13,
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

                      // Action Buttons (View & Print)
                      SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  controller.showQrCodeDialog(item),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Get.snackbar(
                                  'Print',
                                  'Printing ${item.bundleId}',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B5AD),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Print',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
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
              color: isPrinted
                  ? const Color(0xFF166534)
                  : const Color(0xFF0369A1),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isPrinted ? Icons.check_circle_outline : Icons.adjust,
            size: 12,
            color: isPrinted
                ? const Color(0xFF166534)
                : const Color(0xFF0369A1),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return CommonPaginationFooter(
      currentPage: 1,
      totalPages: 15,
      rowsPerPage: 10,
    );
  }

  void _showFullQrModalDialog(BuildContext context, PackingListQrItemModel item) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 820,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.inputBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Back', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Download PDF', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Export Excel', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.inputBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=project%3DGarage%26load_id%3D${item.packingId}',
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.qr_code_2_rounded, size: 90, color: Color(0xFF1E293B)),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('project=${controller.selectedProjectName.value.isEmpty ? "Garage" : controller.selectedProjectName.value}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Text('Shipper :  shipper=${item.shipper}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Load :  load_id=${item.packingId}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Bundles :  bundle_ids=${(item.bundles.isNotEmpty ? item.bundles : controller.bundleLabelsList).map((b) => b.bundleId).join(", ")}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Parts :  parts=${(item.bundles.isNotEmpty ? item.bundles : controller.bundleLabelsList).map((b) => b.parts).toSet().join(", ")}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Weight :  weight=${item.weight}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('URL :  ${item.qrUrl.isNotEmpty ? item.qrUrl : 'https://mr-storage-vendor.vercel.app/packing-list-plan/${item.packingId}'}', style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Load Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 10),
                          _infoPair('Packing List ID', item.packingId),
                          _infoPair('Load ID', item.loadId),
                          _infoPair('Project', controller.selectedProjectName.value.isEmpty ? "Garage" : controller.selectedProjectName.value),
                          _infoPair('Truck', item.truck),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Packing Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 10),
                          _infoPair('Total Bundles', '${item.bundlesCount}'),
                          _infoPair('Total Items', '${item.totalItemsCount > 0 ? item.totalItemsCount : item.bundlesCount * 2}'),
                          _infoPair('Total weight', item.weight),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Bundle List', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 30, child: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 2, child: Text('Bundle ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 2, child: Text('Part Number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 2, child: Text('Length', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 2, child: Text('Weight', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: item.bundles.isNotEmpty ? item.bundles.length : controller.bundleLabelsList.length,
                  separatorBuilder: (ctx, idx) => const Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (ctx, idx) {
                    final bundleList = item.bundles.isNotEmpty ? item.bundles : controller.bundleLabelsList;
                    final bundle = bundleList[idx];
                    final itemPart = bundle.items.isNotEmpty ? bundle.items.first.partNumber : bundle.parts;
                    final itemQty = bundle.items.isNotEmpty ? bundle.items.first.quantity : (bundle.totalQty > 0 ? bundle.totalQty : 1);
                    final itemLen = bundle.items.isNotEmpty ? bundle.items.first.length : bundle.length;
                    final itemWt = bundle.items.isNotEmpty ? bundle.items.first.weight : bundle.weight;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(width: 30, child: Text('${idx + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          Expanded(flex: 2, child: Text(bundle.bundleId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          Expanded(flex: 2, child: Text(itemPart, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text('$itemQty', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(itemLen, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(itemWt, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(bundle.status, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoPair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
