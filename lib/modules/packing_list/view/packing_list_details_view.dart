import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_images.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/packing_list_controller.dart';

class PackingListDetailsView extends GetView<PackingListController> {
  const PackingListDetailsView({super.key});

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
                      _buildDocumentContainer(),
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
          label: const Text('Packing List', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Generate and manage packing lists for truckloads and bundles.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDocumentContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBannerCard(),
          const SizedBox(height: 24),
          _buildOptimizationSummaryCard(),
          const SizedBox(height: 28),
          const Text('Packing List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildPackingListTable(),
          const SizedBox(height: 28),
          const Text('Bundle List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildBundleListTable(),
          const SizedBox(height: 16),
          _buildFooterSummaryBar(),
        ],
      ),
    );
  }

  Widget _buildBannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Project: Riverside Complex | Truckloads: 2',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 12),
          Text('Project: Riverside Complex', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text('Upload ID: UPL-001', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          SizedBox(height: 4),
          Text('Bundles Created: 5', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          SizedBox(height: 4),
          Text('Total Weight: 18500 IBS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildOptimizationSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Optimization Summary Card',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                _buildSummaryMetaRow('Truck Loads', '2'),
                const SizedBox(height: 8),
                _buildSummaryMetaRow('Total Bundles', '4'),
                const SizedBox(height: 8),
                _buildSummaryMetaRow('Total Weight', '18500 IBS', isBold: true),
                const SizedBox(height: 8),
                _buildSummaryMetaRow('Packing List Generated', '2'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Image.asset(
              AppImages.qrCode,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(Icons.qr_code, size: 60),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'project=RiversideComplex',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text('Shipper : shipper=SHP-1044', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('Load : load_id=LOAD-001', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('Bundle : bundle_id=BND-001', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('Parts : parts=STL-B12', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('Weight : weight=3600', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('Length : Length=20', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetaRow(String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPackingListTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF1C1917),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                SizedBox(width: 30, child: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text('Load ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text('Truck', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text('Bundles', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text('Weight', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 3, child: Text('Destination', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                SizedBox(width: 44),
              ],
            ),
          ),
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.packingListTableItems.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = controller.packingListTableItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text('${item.id}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Text(item.loadId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                      Expanded(flex: 2, child: Text(item.truck, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Text('${item.bundles}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Text(item.weight, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 3, child: Text(item.destination, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Text(item.status, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      IconButton(
                        onPressed: () {},
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF64748B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.download, size: 14, color: Colors.white),
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

  Widget _buildBundleListTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF1C1917),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                SizedBox(width: 30, child: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text('Bundle ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text('Profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 3, child: Text('Items', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text('Length', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text('Unit Weight', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
              ],
            ),
          ),
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.bundleListItems.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = controller.bundleListItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text('${item.id}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Text(item.bundleId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                      Expanded(flex: 2, child: Text(item.profile, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 3, child: Text(item.items, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Text(item.length, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      Expanded(flex: 2, child: Text(item.unitWeight, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
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

  Widget _buildFooterSummaryBar() {
    return Container(
      color: const Color(0xFF1C1917),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text('Summary', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 24),
          const Text('Total Bundles: 3', style: TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(width: 24),
          const Text('Total Weight: 36,000 lbs', style: TextStyle(fontSize: 11, color: Colors.white70)),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2E8F0),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Download PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCBD5E1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Export Excel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
