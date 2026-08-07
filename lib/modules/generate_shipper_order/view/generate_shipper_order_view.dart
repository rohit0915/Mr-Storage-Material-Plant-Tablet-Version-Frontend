import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/generate_shipper_order_controller.dart';
import '../widgets/add_shipper_mail_dialog.dart';
import '../widgets/order_sent_success_dialog.dart';

class GenerateShipperOrderView extends GetView<GenerateShipperOrderController> {
  const GenerateShipperOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Navigation Header
            const DashboardAppBar(),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Bar (Back button, Title, Send Order button)
                      _buildHeaderToolbar(),

                      const SizedBox(height: 16),

                      // Select Shipper Section Card
                      _buildSelectShipperCard(),

                      const SizedBox(height: 20),

                      // Embedded BOM Document Preview Box
                      _buildEmbeddedBomPreviewCard(),

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Generate Shipper Order',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => Get.dialog(const OrderSentSuccessDialog()),
            icon: const Icon(Icons.send_outlined, size: 16, color: Colors.white),
            label: const Text(
              'Send Order',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectShipperCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Subtitle, Search bar & Add button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF2563EB), size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Select Shipper',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Send Material Request to Shipper',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Search Input Field
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, size: 16, color: AppColors.textHint),
                        SizedBox(width: 8),
                        Text(
                          'Search Shippers',
                          style: TextStyle(fontSize: 12, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Add new Shipper Mail Button
                ElevatedButton(
                  onPressed: () => Get.dialog(const AddShipperMailDialog()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF475569),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'Add new Shipper Mail',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Shipper Cards Grid Row
            Obx(() => Row(
                  children: List.generate(controller.shippers.length, (index) {
                    final item = controller.shippers[index];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => controller.toggleShipperSelect(index),
                        child: Container(
                          margin: EdgeInsets.only(right: index == controller.shippers.length - 1 ? 0 : 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: item.isSelected ? const Color(0xFF22C55E) : AppColors.inputBorder,
                              width: item.isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    item.isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                    size: 18,
                                    color: item.isSelected ? const Color(0xFF22C55E) : AppColors.textHint,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 12, color: Color(0xFFEAB308)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.rating}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Service Area: ${item.serviceArea}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                )),

            const SizedBox(height: 16),

            // New Shippers Chips Section
            Obx(() {
              if (controller.newShipperEmails.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Shippers',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(controller.newShipperEmails.length, (index) {
                      final email = controller.newShipperEmails[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              email,
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => controller.removeShipperEmail(index),
                              child: const Icon(Icons.cancel, size: 16, color: AppColors.textHint),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmbeddedBomPreviewCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Title Header Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Project : ABC Construction | BOM ID: BOM-001',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOM Summary Box
            Container(
              width: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BOM Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Total Items', '125'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Total Weight', '32,000 lbs', isBold: true),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Total Panels Area', '3,300 sqm', isBold: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Printable STORAGE MATERIALS Box
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5)),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('STORAGE ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: const Color(0xFF2563EB),
                            child: const Text('MATERIALS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1.5, height: 110, color: Colors.black),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1.5))),
                          child: Row(
                            children: const [
                              Expanded(child: Text('STUDS & TOP CHANNELS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                              Text('Date: 01.09.26\nJob Id: BLDG-D', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1.5))),
                          child: Row(
                            children: const [
                              SizedBox(width: 100, child: Text('Customer:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                              Text('John Doe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: Row(
                            children: const [
                              SizedBox(width: 100, child: Text('Project Name:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                              Text('ABC Construction', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mini Preview Table
            _buildBomTablePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildBomTablePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: const [
                Expanded(flex: 1, child: Text('QTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Mark', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Part', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Color', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Angle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Thick', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Length', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Weight', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          ...List.generate(5, (index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Text('${index + 4}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('S-${index + 1}', style: const TextStyle(fontSize: 12))),
                      const Expanded(flex: 2, child: Text('STUD', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      const Expanded(flex: 2, child: Text('C42516', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      const Expanded(flex: 1, child: Text('RO', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      const Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      const Expanded(flex: 1, child: Text('16 GA', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      const Expanded(flex: 2, child: Text("8'-7 1/4\"", style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      const Expanded(flex: 1, child: Text('16.00', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    ],
                  ),
                ),
                if (index < 4) const Divider(height: 1, color: AppColors.divider),
              ],
            );
          }),
        ],
      ),
    );
  }
}
