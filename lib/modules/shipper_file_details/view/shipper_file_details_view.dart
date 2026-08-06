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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 4),
        const Text(
          'Shipper File Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {
            Get.toNamed(AppRoutes.pdfView);
          },
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppColors.textPrimary),
          label: const Text('Download PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: const Text(
            'Start Load Planning',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPaperSheet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28.0),
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
          // Project Header Info Banner Box
          _buildProjectInfoBanner(),
          const SizedBox(height: 28),

          // Company Sales Order Document Header (Logo, Address, Sales Order Table)
          _buildSalesOrderCompanyHeader(),
          const SizedBox(height: 24),

          // Customer PO / Sales Person Meta Table
          _buildCustomerMetaTable(),
          const SizedBox(height: 20),

          // Itemized Table
          _buildItemizedTable(),
        ],
      ),
    );
  }

  Widget _buildProjectInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project: ABC Warehouse Project',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBannerMeta('Project ID: PRJ-1025'),
              _buildBannerDivider(),
              _buildBannerMeta('Shipper File: steel_v1.xlsx'),
              _buildBannerDivider(),
              _buildBannerMeta('Shipper: SteelCorp'),
              _buildBannerDivider(),
              _buildBannerMeta('Upload Date: Apr 22, 2026'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Text('Approved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerMeta(String text) {
    return Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500));
  }

  Widget _buildBannerDivider() {
    return Container(
      height: 14,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFFCBD5E1),
    );
  }

  Widget _buildSalesOrderCompanyHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Logo
        Image.asset(
          AppImages.quickenSteelLogo,
          width: 180,
          height: 64,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Quicken Steel, LLC', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
              ],
            );
          },
        ),
        const Spacer(),

        // Address Block
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('QUICKEN STEEL, LLC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(height: 2),
            Text('188 Georgia Pacific Dr', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            SizedBox(height: 2),
            Text('Claxton, GA 30417', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            SizedBox(height: 2),
            Text('Phone: (912) 549-4050', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),

        const Spacer(),

        // Sales Order Box
        Container(
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF94A3B8)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: const Color(0xFFE2E8F0),
                child: const Text(
                  'SALES ORDER',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              _buildSalesOrderBoxRow('ORDER NO.', 'S-19459'),
              _buildSalesOrderBoxRow('ORDER DATE', '1/14/2026'),
              _buildSalesOrderBoxRow('REQUESTED DATE', '3/31/2026'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalesOrderBoxRow(String label, String val) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF94A3B8)))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              color: const Color(0xFFF1F5F9),
              child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
          ),
          Container(width: 1, height: 18, color: const Color(0xFF94A3B8)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: Text(val, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMetaTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF94A3B8)),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            color: const Color(0xFFCBD5E1),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              children: const [
                Expanded(child: Text('Customer PO#', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Sales Person', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Warehouse', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Terms', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Ship Via', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Values Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.white,
            child: Row(
              children: const [
                Expanded(child: Text('USB Shipper', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Hunter Jeffcoat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(child: Text('CLX', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Cash in Advance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(child: Text('3rd Party', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemizedTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: const [
                SizedBox(width: 44, child: Text('QTY ↑↓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                SizedBox(width: 90, child: Text('Item ↑↓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Description', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                SizedBox(width: 80, child: Text('Length ↑↓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                SizedBox(width: 60, child: Text('Weight', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                SizedBox(width: 80, child: Text('Unit Price ↑↓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                SizedBox(width: 80, child: Text('Amount ↑↓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCBD5E1)),

          // Item Rows
          ...controller.salesOrderItems.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 44, child: Text('${item.qty}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  SizedBox(width: 90, child: Text(item.itemCode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  Expanded(
                    child: Text(
                      item.description,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ),
                  SizedBox(width: 80, child: Text(item.length, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  SizedBox(width: 60, child: Text('${item.weight}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                  SizedBox(width: 80, child: Text(item.unitPrice, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                  SizedBox(width: 80, child: Text(item.amount, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
