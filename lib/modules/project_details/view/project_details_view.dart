import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steel_building_plant_panel/app/utils/app_icons.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/project_details_controller.dart';
import '../widgets/add_notes_dialog.dart';
import '../widgets/update_step_status_dialog.dart';
import '../widgets/upload_bom_dialog.dart';
import '../widgets/upload_drawings_dialog.dart';

class ProjectDetailsView extends GetView<ProjectDetailsController> {
  const ProjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Fixed at top)
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
                      // Header bar with Back button, Title & Upload button
                Padding(
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
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Project Details- Project 1',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => Get.dialog(const UploadDrawingsDialog()),
                        icon: const Icon(Icons.upload_outlined, size: 18, color: Colors.white),
                        label: const Text(
                          'Upload Drawing File',
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
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Row of 5 Quick Action Pill Buttons
                _buildActionButtonsRow(),

                const SizedBox(height: 12),

                // Main Project Info Header Card
                _buildProjectInfoCard(),

                const SizedBox(height: 16),

                // Project Lifecycle Stepper Card
                _buildProjectLifecycleSection(),

                const SizedBox(height: 16),

                // Invoice List Table Card
                _buildInvoiceListTable(),

                const SizedBox(height: 16),

                // 3 Column Grid (Project Status, Recent Activity, Notes)
                _buildThreeColumnSection(),

                const SizedBox(height: 16),

                // Project Photos (Latest) Section
                _buildProjectPhotosSection(),

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

  Widget _buildActionButtonsRow() {
    final buttons = [
      'View BOM File',
      'View Drawings & Photos',
      'Material Delivery',
      'View Shipper Files',
      'Additional Material Request',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: buttons.map((title) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton(
                onPressed: () {
                  if (title == 'View BOM File') {
                    Get.dialog(const UploadBomDialog());
                  } else if (title == 'View Drawings & Photos') {
                    Get.toNamed(AppRoutes.projectDrawings);
                  } else if (title == 'Material Delivery') {
                    Get.toNamed(AppRoutes.deliveryDetails);
                  } else if (title == 'View Shipper Files') {
                    Get.toNamed(AppRoutes.shipperFiles);
                  } else if (title == 'Additional Material Request') {
                    Get.toNamed(AppRoutes.additionalMaterialRequest);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D51A4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status Badge Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_outlined, color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Project 1- ABC Warehouse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.badgeGreenBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 7, color: AppColors.badgeGreenText),
                      SizedBox(width: 4),
                      Text(
                        'In Progress',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.badgeGreenText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 44.0),
              child: Text(
                'Q-2026-1047',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 16),

            // Top Row Attributes (Building Type, No. of Buildings, Quote Value, Created On, Location)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryMetaItem(Icons.domain, 'Building Type', 'Workshop'),
                _buildSummaryMetaItem(Icons.grid_view, 'No. of Buildings', '3'),
                _buildSummaryMetaItem(Icons.monetization_on_outlined, 'Quote Value', '\$12,500'),
                _buildSummaryMetaItem(Icons.calendar_today_outlined, 'Created On', '2024-10-10'),
                _buildSummaryMetaItem(Icons.location_on_outlined, 'Location', '1816 Bayonne Ave, Manchester, NJ, 08765'),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 16),

            // Bottom Row (Contact Info, Assignment, Signed Contract)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Information
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Contact Information',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 6),
                        Text('John Doe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        SizedBox(height: 2),
                        Text('Phone: (163) 2459 315', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        SizedBox(height: 2),
                        Text('Email: darlee@example.com', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                        SizedBox(height: 2),
                        Text('Address: 1861 Bayonne Ave,...', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Assignment
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assignment',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.badgeGreenBg,
                              child: const Icon(Icons.person_outline, size: 18, color: AppColors.badgeGreenText),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Sales Person:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Text('Sarah Lee', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Signed Contract / Agreement
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Signed Contract/Agreement',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.badgeGreenBg,
                              child: const Icon(Icons.description_outlined, size: 18, color: AppColors.badgeGreenText),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Signed contact/Agreement', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                Text('Signed on: 12 April 2025', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
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
      ),
    );
  }

  Widget _buildSummaryMetaItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectLifecycleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Lifecycle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal Stepper Bar with 14 steps
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(controller.lifecycleSteps.length, (index) {
                  final step = controller.lifecycleSteps[index];
                  final isCurrent = index == controller.currentStepIndex.value;
                  final isCompleted = index < controller.currentStepIndex.value;

                  return GestureDetector(
                    onTap: () => controller.selectStep(index),
                    child: Container(
                      width: 75,
                      margin: const EdgeInsets.only(right: 4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 2.5,
                                  color: index == 0
                                      ? Colors.transparent
                                      : (index <= controller.currentStepIndex.value
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFCBD5E1)),
                                ),
                              ),
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: isCurrent
                                    ? const Color(0xFF2563EB)
                                    : (isCompleted ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0)),
                                child: Text(
                                  '${step.stepNumber}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: (isCurrent || isCompleted) ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 2.5,
                                  color: index == controller.lifecycleSteps.length - 1
                                      ? Colors.transparent
                                      : (index < controller.currentStepIndex.value
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFCBD5E1)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isCurrent
                                  ? const Color(0xFF2563EB)
                                  : (isCompleted ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                            ),
                          ),
                          if (step.date.isNotEmpty)
                            Text(
                              step.date,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // Active Step Info Details Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Col: Title & Description
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Production Planning (Step 7 of 14)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Plan Production Schedule, assign resources and determine fabrication priority for this project.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Middle Col: Planned Dates
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabelValue('Planned start date', '2024-10-10'),
                        const SizedBox(height: 8),
                        _buildLabelValue('Target Completion', '2024-10-10'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right Col: Planner & Priority
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabelValue('Assigned Planner', 'Sarah Lee'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Priority ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Medium',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Next Step
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Next Step', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        SizedBox(height: 4),
                        Text(
                          'Fabrication Production Started\nUpcoming After completion',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stepper Action Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => Get.dialog(const UpdateStepStatusDialog()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Update Step Status',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Get.dialog(const AddNotesDialog()),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Add Notes',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildInvoiceListTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          children: [
            // Title & Export Icons Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Text(
                    'Invoice List',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  // PDF icon (Red)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(  borderRadius: BorderRadius.circular(4),border: Border.all(color: AppColors.inputBorder)),
                     child:Padding(
                       padding: const EdgeInsets.all(4.0),
                       child: Image.asset(AppIcons.pdf, width: 14, height: 14),
                     ),
                  ),
                  const SizedBox(width: 8),
                  // Excel icon (Green)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(  border: Border.all(color: AppColors.inputBorder), borderRadius: BorderRadius.circular(4)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(AppIcons.xls, width: 14, height: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Print icon (Grey)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.inputBorder), borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.print ,color: AppColors.black, size: 14),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            // Header Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFF8FAFC),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: Text('Invoice Number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  Expanded(flex: 2, child: Text('Due Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  Expanded(flex: 2, child: Text('Paid', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  Expanded(flex: 2, child: Text('Amount Due', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            // Rows
            ...List.generate(controller.invoices.length, (index) {
              final item = controller.invoices[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(item.invoiceNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF97316)))),
                        Expanded(flex: 2, child: Text(item.dueDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        Expanded(flex: 2, child: Text(item.amount, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        Expanded(flex: 2, child: Text(item.paid, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        Expanded(flex: 2, child: Text(item.amountDue, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.isPaid ? AppColors.badgeGreenBg : AppColors.badgeRedBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.isPaid ? 'Paid' : 'Unpaid',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: item.isPaid ? AppColors.badgeGreenText : AppColors.badgeRedText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < controller.invoices.length - 1)
                    const Divider(height: 1, color: AppColors.divider),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeColumnSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column 1: Project Status (Donut Chart)
          Expanded(
            child: Container(
              height: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const Spacer(),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: CircularProgressIndicator(
                            value: 7 / 14,
                            strokeWidth: 10,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Step', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text('7', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('of 14', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text('Current step', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  const Text('Production Planning', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text('Started on', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                  const Text('2024-10-10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Column 2: Recent Activity
          Expanded(
            child: Container(
              height: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.activities.length,
                      itemBuilder: (context, index) {
                        final act = controller.activities[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Icon(Icons.radio_button_checked, size: 12, color: Color(0xFF8B5CF6)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(act.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                    if (act.subtitle.isNotEmpty)
                                      Text(act.subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 9, color: AppColors.textHint),
                                        const SizedBox(width: 3),
                                        Text(act.date, style: const TextStyle(fontSize: 9, color: AppColors.textHint)),
                                      ],
                                    ),
                                  ],
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
          const SizedBox(width: 16),

          // Column 3: Notes
          Expanded(
            child: Container(
              height: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.notes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            controller.notes[index],
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3),
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

  Widget _buildProjectPhotosSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Photos (Latest)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 110,
                    margin: EdgeInsets.only(right: index == 4 ? 0 : 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      'https://picsum.photos/300/200?random=$index',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE2E8F0),
                        child: const Center(
                          child: Icon(Icons.location_city, color: AppColors.textHint, size: 32),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
