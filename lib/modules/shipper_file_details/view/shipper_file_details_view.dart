import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_images.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/shipper_file_details_controller.dart';

class ShipperFileDetailsView extends GetView<ShipperFileDetailsController> {
  const ShipperFileDetailsView({super.key});

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Header Actions Toolbar
                      _buildHeaderToolbar(),
                      const SizedBox(height: 16),

                      // Document Paper Sheet
                      _buildDocumentPaperSheet(),
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
          label: const Text(
            'Shipper File',
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
        const Spacer(),

        // Download PDF Button
        OutlinedButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.pdfView),
          icon: const Icon(
            Icons.picture_as_pdf_outlined,
            size: 16,
            color: AppColors.textPrimary,
          ),
          label: const Text(
            'Download PDF',
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(width: 10),

        // Status-based Action Buttons
        Obx(() {
          if (controller.status.value == 'Approved') {
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Approved',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => controller.startLoadPlanning(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
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
                    'Start Load Planning',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return ElevatedButton.icon(
              onPressed: () => controller.openOrderVerificationDialog(),
              icon: const Icon(Icons.balance, size: 16, color: Colors.white),
              label: const Text(
                'Order Verification',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildDocumentPaperSheet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectInfoBanner(),
          const SizedBox(height: 28),
          _buildSalesOrderHeaderBox(),
          const SizedBox(height: 24),
          _buildMetaSummaryGrid(),
          const SizedBox(height: 24),
          _buildItemsTable(),
        ],
      ),
    );
  }

  Widget _buildProjectInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project: ABC Warehouse Project',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Project ID: PRJ-1025',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Shipper: SteelCorp',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.divider),
              const SizedBox(width: 20),
              Expanded(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shipper File: steel_v1.xlsx',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Upload Date: Apr 22, 2026',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Status: ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            controller.status.value == 'Approved'
                                ? '🟢 Approved'
                                : '🟡 Under Review',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: controller.status.value == 'Approved'
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOrderHeaderBox() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.quickenSteelLogo,
                    height: 42,
                    errorBuilder: (c, o, s) => const Icon(
                      Icons.business,
                      size: 40,
                      color: Color(0xFFF97316),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'QUICKEN STEEL, LLC',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '188 Georgia Pacific Dr\nClaxton, GA 30417\nPhone: (912) 549-4050',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 110, color: Colors.black12),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFFE2E8F0),
                  child: const Text(
                    'SALES ORDER',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSalesOrderBoxRow('ORDER NO.', 'S-19459'),
                _buildSalesOrderBoxRow('ORDER DATE', '1/14/2026'),
                _buildSalesOrderBoxRow('REQUESTED DATE', '3/31/2026'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOrderBoxRow(String label, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: const Color(0xFFF1F5F9),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaSummaryGrid() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFCBD5E1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'Customer PO#',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Sales Person',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Warehouse',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Terms',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Ship Via',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'USB Shipper',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Hunter Jeffcoat',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'CLX',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Cash in Advance',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    '3rd Party',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          color: const Color(0xFFF1F5F9),
          child: Row(
            children: const [
              Expanded(
                flex: 1,
                child: Text(
                  'QTY ↑↓',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Item ↑↓',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Description',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Length ↑↓',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Weight',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Unit Price ↑↓',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Amount ↑↓',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.black12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.salesOrderItems.length,
          separatorBuilder: (c, i) =>
              const Divider(height: 1, color: Colors.black12),
          itemBuilder: (context, index) {
            final item = controller.salesOrderItems[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${item.qty}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.itemCode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.length,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.weight}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.unitPrice,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.amount,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
