import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_images.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/load_planning_workflow_controller.dart';
import '../model/bundle_data_model.dart';

class LoadPlanningWorkflowView extends GetView<LoadPlanningWorkflowController> {
  const LoadPlanningWorkflowView({super.key});

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
                if (controller.loading.value) return const CommonLoader();
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Stepper Bar
                      _stepper(),
                      const SizedBox(height: 24),

                      // Active Step View Body
                      _body(context),
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

  Widget _stepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: _cardDecoration(),
      child: Row(
        children: List.generate(LoadPlanningWorkflowController.steps.length, (index) {
          final isCompleted = index < controller.step.value;
          final isActive = index == controller.step.value;
          final activeOrDone = index <= controller.step.value;

          return Expanded(
            child: InkWell(
              onTap: () => controller.goToStep(index),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (index > 0)
                        Expanded(
                          child: Container(
                            height: 3,
                            color: activeOrDone
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          border: Border.all(
                            color: activeOrDone
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : isActive
                              ? Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF2563EB),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (index < LoadPlanningWorkflowController.steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 3,
                            color: isCompleted
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    LoadPlanningWorkflowController.steps[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: activeOrDone ? FontWeight.bold : FontWeight.w500,
                      color: activeOrDone
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (controller.error.value.isNotEmpty) {
      return _empty(controller.error.value);
    }

    switch (controller.step.value) {
      case 0:
        return _itemAnalysisStep();
      case 1:
        return _bundlePlannerStep(context);
      case 2:
        return _truckOptimizerStep(context);
      case 3:
        return _packingListStep(context);
      case 4:
        return _qrLabelStep(context);
      case 5:
        return _loadPlanReviewStep(context);
      case 6:
        return _freightSelectionStep(context);
      default:
        return _genericWorkflowStep();
    }
  }

  // --- STEP 0: ITEM ANALYSIS ---
  Widget _itemAnalysisStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Item Analysis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Analyze the material list for accuracy and identify missing or incompatible items.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: controller.autoOptimize,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Auto Optimize Bundles',
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
        _projectCard(),
        if (controller.pdfBytes.value != null) ...[
          const SizedBox(height: 24),
          Container(
            height: 720,
            padding: const EdgeInsets.all(12),
            decoration: _cardDecoration(),
            child: PdfPreview(
              build: (_) async => controller.pdfBytes.value!,
              allowPrinting: false,
              allowSharing: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              pdfFileName: controller.fileName,
            ),
          ),
        ],
      ],
    );
  }

  // --- STEP 1: BUNDLE PLANNER (Screenshots 1, 2, 3, 4) ---
  Widget _bundlePlannerStep(BuildContext context) {
    return Obx(() {
      final editing = controller.editingBundle.value;
      if (editing != null) {
        return _buildEditBundleScreen(context, editing);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Page Title & Header Toolbar
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bundle / Pallet Planner',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Group items into optimized bundles or pallets for efficient truck loading and site unloading.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Export Excel Button
                OutlinedButton.icon(
                  onPressed: controller.exportExcel,
                  icon: const Icon(
                    Icons.download_outlined,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  label: const Text(
                    'Export Excel',
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

                // Confirm Bundle Plan Button (Hides when confirmed)
                Obx(() {
                  if (!controller.isConfirmed.value) {
                    return ElevatedButton(
                      onPressed: controller.actionLoading.value
                          ? null
                          : controller.confirmBundles,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.actionLoading.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirm Bundle Plan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Proceed to Truckload Optimization Button
                Obx(
                  () => ElevatedButton(
                    onPressed: () {
                      if (!controller.isConfirmed.value) {
                        CommonSnackbar.showError(
                          title: 'Confirmation Required',
                          message: 'Please confirm the bundle plan before proceeding.',
                        );
                        return;
                      }
                      controller.goToStep(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isConfirmed.value
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFFA78BFA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Truckload Optimization',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),


        // Project Banner Card
        _projectBannerCard(
          title: 'Project: ${controller.projectName} | Bundle Plan ID: ${controller.displayBundlePlanId}',
          idLabel: 'Project ID:',
          idValue: controller.projectCode,
          planLabel: 'Bundle Plan Id:',
          planValue: controller.displayBundlePlanId,
        ),
        const SizedBox(height: 20),

        // Summary KPIs & Optimization Control Card
        _summaryKpiAndControlCard(),
        const SizedBox(height: 24),

        // Bundle Data Table Card
        _bundleDataTableCard(context),
      ],
    );
    });
  }

  Widget _summaryKpiAndControlCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryKpiColumn(),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                _optimizationControlColumn(),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _summaryKpiColumn()),
              Container(
                width: 1,
                height: 140,
                color: const Color(0xFFE2E8F0),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              Expanded(child: _optimizationControlColumn()),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryKpiColumn() {
    return Obx(() {
      final totalBundles = controller.totalBundlesCount;
      final avgWeight = controller.averageBundleWeightValue.toStringAsFixed(2);
      final totalWeight = controller.totalPlannedWeightValue.toStringAsFixed(2);
      final warnings = controller.bundleWarningsText;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Summary KPI'S",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _kpiRow('Total Bundles', '$totalBundles'),
          const SizedBox(height: 8),
          _kpiRow('Average Bundle Weight', '$avgWeight lbs'),
          const SizedBox(height: 8),
          _kpiRow('Total Planned Weight', '$totalWeight lbs'),
          const SizedBox(height: 8),
          _kpiRow('Bundle Warnings', warnings, isWarning: !warnings.startsWith('0')),
        ],
      );
    });
  }

  Widget _optimizationControlColumn() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optimization Control',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _kpiRow('Prefered Bundle Weight', controller.preferredBundleWeightText),
          const SizedBox(height: 8),
          _kpiRow('Maximum Bundle Weight', controller.maxBundleWeightText),
          const SizedBox(height: 8),
          _kpiRow('Maximum Bundle Length', controller.maxBundleLengthText),
          const SizedBox(height: 8),
          _kpiRow('Group by Profile', controller.groupByProfileText),
        ],
      );
    });
  }

  Widget _kpiRow(String label, String value, {bool isWarning = false}) {
    return Row(
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isWarning ? const Color(0xFFF97316) : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _bundleDataTableCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Bundle Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Dark Slate Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
            ),
            child: Row(
              children: const [
                SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('BUNDLE ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('PROFILE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('ITEMS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('LENGTH', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('UNIT WEIGHT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                SizedBox(width: 200, child: Text('ACTIONS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),
          // Rows
          Obx(() {
            final list = controller.bundleList;
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: const Text('No bundles found.'),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = list[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${index + 1}',
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
                          item.bundleId,
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
                          item.profile,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item.itemsCount} ${item.itemsCount == 1 ? 'item' : 'items'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.length,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item.unitWeight.toStringAsFixed(2)} lbs',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.status.toLowerCase() == 'confirmed'
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: item.status.toLowerCase() == 'confirmed'
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Text(
                              item.status.capitalizeFirst!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.status.toLowerCase() == 'confirmed'
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Edit Bundle Button
                            ElevatedButton(
                              onPressed: () => controller.startEditBundle(item),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF717D96),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Edit Bundle',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // View QR Button
                            ElevatedButton.icon(
                              onPressed: () => _showQrDialog(context, item),
                              icon: const Icon(Icons.qr_code, size: 14, color: Colors.white),
                              label: const Text(
                                'View QR',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
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
      ),
    );
  }

  // --- STEP 2: TRUCK OPTIMIZER (Screenshot 5) ---
  Widget _truckOptimizerStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title & Header Toolbar
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Truckload Optimizer',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Optimize bundle assignments into truckloads to maximize utilization and prepare shipments for dispatch.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => controller.goToStep(3),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Generate Packing List',
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

        // Project Banner Card
        _projectBannerCard(
          title: 'Project: ${controller.projectName} | Packing Plan ID: ${controller.displayPackingListPlanId}',
          idLabel: 'Project ID:',
          idValue: controller.projectCode,
          planLabel: 'Packing Plan Id:',
          planValue: controller.displayPackingListPlanId,
        ),
        const SizedBox(height: 20),

        // 2 Summary Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            if (isMobile) {
              return Column(
                children: [
                  _optimizationSummaryCard(),
                  const SizedBox(height: 16),
                  _truckSummaryCard(),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _optimizationSummaryCard()),
                const SizedBox(width: 16),
                Expanded(child: _truckSummaryCard()),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Truckload Table Card
        _truckloadTableCard(),
      ],
    );
  }

  Widget _optimizationSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optimization Summary Card',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _kpiRow('Total Bundles', '22'),
          const SizedBox(height: 8),
          _kpiRow('Planned Truck Loads', '2'),
          const SizedBox(height: 8),
          _kpiRow('Total Weight', '55,789.2 LBS'),
          const SizedBox(height: 8),
          _kpiRow('Average Load Utilization', '81%'),
        ],
      ),
    );
  }

  Widget _truckSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Truck Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _kpiRow("53' Semi Truck Count", '1'),
          const SizedBox(height: 8),
          _kpiRow("40' Hotshot Count", '1'),
          const SizedBox(height: 8),
          _kpiRow('Total Trucks', '2'),
        ],
      ),
    );
  }

  Widget _truckloadTableCard() {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Truckload Table',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Dark Slate Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
            ),
            child: Row(
              children: const [
                SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('LOAD ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('BUNDLE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('TOTAL WEIGHT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('UTILIZATION', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Rows
          Obx(() {
            final list = controller.truckloadList;
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: const Text('No truckloads found.'),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = list[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${index + 1}',
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
                          item.loadId,
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
                          '${item.bundlesCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item.totalWeight.toStringAsFixed(1)} LBS',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item.utilizationPercentage}%',
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
                          item.status,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
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

  // --- STEP 3: PACKING LIST (Screenshots 1 & 2) ---
  Widget _packingListStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Packing List',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Generate and manage packing lists for truckloads and bundles.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => controller.goToStep(4),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Generate QR Label',
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
        _projectBannerCard(
          title: 'Project: ${controller.projectName} | Truckloads: 2',
          idLabel: 'Project:',
          idValue: controller.projectName,
          planLabel: 'Packing List Plan ID:',
          planValue: controller.packingListPlanId,
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Optimization Summary Card',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _kpiRow('Truck Loads', '2'),
              const SizedBox(height: 8),
              _kpiRow('Total Bundles', '22'),
              const SizedBox(height: 8),
              _kpiRow('Total Weight', '55,789.2 LBS'),
              const SizedBox(height: 8),
              _kpiRow('Packing List Generated', '2'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Packing List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: const Color(0xFF1E293B),
                child: Row(
                  children: const [
                    SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Load ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Truck', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Bundles', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Weight', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Status', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    SizedBox(width: 140, child: Text('Actions', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const SizedBox(width: 32, child: Text('1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('PL-001', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('53 ft Semi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('18', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('44,651.8 LBS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('Draft', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    SizedBox(
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: controller.exportExcel,
                            icon: const Icon(Icons.download_outlined, size: 18, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: () => _showPackingListDetailsDialog(context, 'PL-001', '53 ft Semi', 18, '44,651.80'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF64748B),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const SizedBox(width: 32, child: Text('2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('PL-002', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('40 ft Hot Shot', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('4', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('11,137.4 LBS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('Draft', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    SizedBox(
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: controller.exportExcel,
                            icon: const Icon(Icons.download_outlined, size: 18, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: () => _showPackingListDetailsDialog(context, 'PL-002', '40 ft Hot Shot', 4, '11,137.40'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF64748B),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- STEP 4: QR LABEL GENERATOR (Screenshots 3 & 4) ---
  Widget _qrLabelStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'QR Label Generator',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Generate and print QR labels for bundles and pallets to enable scanning and tracking.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => controller.goToStep(5),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Review Load Plan',
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
        _projectBannerCard(
          title: 'Project: ${controller.projectName} | Packing Plan: ${controller.packingListPlanId}',
          idLabel: 'Project:',
          idValue: controller.projectName,
          planLabel: 'Packing List Plan ID:',
          planValue: controller.packingListPlanId,
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Summary Card',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _kpiRow('Total Bundles', '22'),
              const SizedBox(height: 8),
              _kpiRow('Labels Generated', '22'),
              const SizedBox(height: 8),
              _kpiRow('Labels Printed', '22'),
              const SizedBox(height: 8),
              _kpiRow('Pending Labels', '0'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Truck List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: const Color(0xFF1E293B),
                child: Row(
                  children: const [
                    SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Load ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Truck', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Bundles', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Weight', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Destination', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Status', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    SizedBox(width: 120, child: Text('Actions', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const SizedBox(width: 32, child: Text('1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('PL-001', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('53 ft Semi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('18', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('44,651.8 LBS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('Warehouse Site A', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('Confirmed', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    SizedBox(
                      width: 120,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _showQrLabelDetailsDialog(context, 'PL-001', '53 ft Semi', 18, '44,651.80'),
                          icon: const Icon(Icons.qr_code, size: 14, color: Colors.white),
                          label: const Text('View QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const SizedBox(width: 32, child: Text('2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('PL-002', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('40 ft Hot Shot', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('4', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('11,137.4 LBS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('Warehouse Site A', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('Confirmed', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    SizedBox(
                      width: 120,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _showQrLabelDetailsDialog(context, 'PL-002', '40 ft Hot Shot', 4, '11,137.40'),
                          icon: const Icon(Icons.qr_code, size: 14, color: Colors.white),
                          label: const Text('View QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- STEP 5: LOAD PLAN REVIEW (Screenshot 5) ---
  Widget _loadPlanReviewStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Load Plan Review',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Final check of the entire load plan, including bundles, trucks, and weights, before selecting freight carriers.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: controller.approveLoadPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Approve & Create Freight Request',
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
        _projectBannerCard(
          title: 'Project: ${controller.projectName} | Packing Plan: ${controller.displayPackingListPlanId}',
          idLabel: 'Project:',
          idValue: controller.projectName,
          planLabel: 'Status:',
          planValue: 'confirmed',
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Load Summary Card',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _kpiRow('Total Bundles', '22'),
              const SizedBox(height: 8),
              _kpiRow('Total Loads', '2'),
              const SizedBox(height: 8),
              _kpiRow('Total Weight', '55,789.2 LBS'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Truckload Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: const Color(0xFF1E293B),
                child: Row(
                  children: const [
                    SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Load ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Bundle', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Total Weight', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Ready', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    SizedBox(width: 100, child: Text('Action', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const SizedBox(width: 32, child: Text('1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('PL-001', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('18', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('44,651.8 LBS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Icon(Icons.check, size: 18, color: Color(0xFF1E293B))),
                    SizedBox(
                      width: 100,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => _showPackingListDetailsDialog(context, 'PL-001', '53 ft Semi', 18, '44,651.80'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64748B),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const SizedBox(width: 32, child: Text('2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('PL-002', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Text('4', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Text('11,137.4 LBS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    const Expanded(flex: 2, child: Icon(Icons.check, size: 18, color: Color(0xFF1E293B))),
                    SizedBox(
                      width: 100,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => _showPackingListDetailsDialog(context, 'PL-002', '40 ft Hot Shot', 4, '11,137.40'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64748B),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Bundle Verification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: const Color(0xFF1E293B),
                child: Row(
                  children: const [
                    SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Bundle ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Parts', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Weight', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text('Packing List Generated', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text('QR Labels Generated', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text('Bundles Assigned to Truck', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              _verificationRow(1, 'B-012', 'framing', '4,940.7 LBS'),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _verificationRow(2, 'B-004', 'framing', '4,848.3 LBS'),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _verificationRow(3, 'B-005', 'framing', '3,426.3 LBS'),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _verificationRow(4, 'B-009', 'framing', '2,747.4 LBS'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verificationRow(int num, String bundleId, String parts, String weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('$num', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(bundleId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(parts, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(weight, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            flex: 3,
            child: Image.asset(
              AppImages.icSuccessfully,
              width: 20,
              height: 20,
              errorBuilder: (ctx, err, stack) => const Icon(Icons.check_circle, size: 20, color: Color(0xFF16A34A)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Image.asset(
              AppImages.icSuccessfully,
              width: 20,
              height: 20,
              errorBuilder: (ctx, err, stack) => const Icon(Icons.check_circle, size: 20, color: Color(0xFF16A34A)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Image.asset(
              AppImages.icSuccessfully,
              width: 20,
              height: 20,
              errorBuilder: (ctx, err, stack) => const Icon(Icons.check_circle, size: 20, color: Color(0xFF16A34A)),
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOGS FOR PACKING LIST & QR LABEL DETAILS ---
  void _showPackingListDetailsDialog(
    BuildContext context,
    String loadId,
    String truckName,
    int bundlesCount,
    String totalWeight,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 820,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Download PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: controller.exportExcel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Export Excel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Load Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          _kpiRow('Packing List ID', loadId),
                          const SizedBox(height: 6),
                          _kpiRow('Load ID', controller.packingListPlanId),
                          const SizedBox(height: 6),
                          _kpiRow('Project', controller.projectName),
                          const SizedBox(height: 6),
                          _kpiRow('Truck', truckName),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Packing Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          _kpiRow('Total Bundles', '$bundlesCount'),
                          const SizedBox(height: 6),
                          _kpiRow('Total Items', '${bundlesCount * 2}'),
                          const SizedBox(height: 6),
                          _kpiRow('Total weight', '$totalWeight lbs'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Bundle List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: const Color(0xFF1E293B),
                        child: Row(
                          children: const [
                            SizedBox(width: 30, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Bundle ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Part Number', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Quantity', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Length', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Weight', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Status', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      _bundleDetailRow(1, 'B-012', 'framing', '72', '26.29ft', '4,940.70 LBS', 'Assigned_to_truck'),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _bundleDetailRow(2, 'B-004', 'framing', '9', '28.06ft', '4,848.30 LBS', 'Assigned_to_truck'),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _bundleDetailRow(3, 'B-009', 'framing', '2', '51.67ft', '2,747.40 LBS', 'Assigned_to_truck'),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _bundleDetailRow(4, 'B-010', 'framing', '30', '25.13ft', '2,403.20 LBS', 'Assigned_to_truck'),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _bundleDetailRow(5, 'B-013', 'framing', '26', '26.29ft', '1,772.90 LBS', 'Assigned_to_truck'),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _bundleDetailRow(6, 'B-011', 'framing', '24', '27.29ft', '1,709.60 LBS', 'Assigned_to_truck'),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _bundleDetailRow(7, 'B-016', 'panels', '74', '27.00ft', '5,280.70 LBS', 'Assigned_to_truck'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQrLabelDetailsDialog(
    BuildContext context,
    String loadId,
    String truckName,
    int bundlesCount,
    String totalWeight,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 820,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final bytes = await _generateQrLabelPdf(
                          projectName: controller.projectName,
                          shipperId: controller.requestId.isNotEmpty ? controller.requestId : '6a85db8f4aba512f82285789',
                          loadId: loadId,
                          bundleId: 'B-009',
                          parts: 'framing',
                          weight: totalWeight,
                          length: '51.67 ft',
                        );
                        await Printing.sharePdf(
                          bytes: bytes,
                          filename: 'QR_Label_$loadId.pdf',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Download PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: controller.exportExcel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Export Excel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: QrImageView(
                        data:
                            'project=${controller.projectName}\nShipper: shipper=${controller.packingListPlanId}\nLoad: load_id=$loadId\nBundles: bundle_ids=B-012, B-004, B-009, B-010, B-013, B-011, B-016\nParts: parts=framing, panels\nWeight: weight=$totalWeight LBS\nLength: length=51.67 FT',
                        version: QrVersions.auto,
                        size: 160.0,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('project=${controller.projectName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          _qrDetailRow('Shipper :', 'shipper=${controller.packingListPlanId}'),
                          _qrDetailRow('Load :', 'load_id=$loadId'),
                          _qrDetailRow('Bundles :', 'bundle_ids=B-012, B-004, B-009, B-010, B-013...'),
                          _qrDetailRow('Parts :', 'parts=framing, panels, mixed'),
                          _qrDetailRow('Weight :', 'weight=$totalWeight LBS'),
                          _qrDetailRow('Length :', 'length=51.67 FT'),
                          _qrDetailRow('URL :', 'https://mr-storage-vendor.vercel.app/packing-list-plan/6a86e4590340d598d3f34df6'),
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
                          const Text('Load Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          _kpiRow('Packing List ID', loadId),
                          const SizedBox(height: 6),
                          _kpiRow('Load ID', controller.packingListPlanId),
                          const SizedBox(height: 6),
                          _kpiRow('Project', controller.projectName),
                          const SizedBox(height: 6),
                          _kpiRow('Truck', truckName),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Packing Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          _kpiRow('Total Bundles', '$bundlesCount'),
                          const SizedBox(height: 6),
                          _kpiRow('Total Items', '${bundlesCount * 2}'),
                          const SizedBox(height: 6),
                          _kpiRow('Total weight', '$totalWeight lbs'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Bundle List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: const Color(0xFF1E293B),
                        child: Row(
                          children: const [
                            SizedBox(width: 30, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Bundle ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Part Number', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Quantity', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Length', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Weight', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Status', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      _bundleDetailRow(1, 'B-012', 'framing', '72', '26.29ft', '4,940.70 LBS', 'Assigned_to_truck'),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _bundleDetailRow(2, 'B-004', 'framing', '9', '28.06ft', '4,848.30 LBS', 'Assigned_to_truck'),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _bundleDetailRow(3, 'B-009', 'framing', '2', '51.67ft', '2,747.40 LBS', 'Assigned_to_truck'),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _bundleDetailRow(4, 'B-010', 'framing', '30', '25.13ft', '2,403.20 LBS', 'Assigned_to_truck'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bundleDetailRow(int num, String bId, String part, String qty, String len, String wt, String st) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text('$num', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(bId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(part, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(qty, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(len, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(wt, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(st, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  // --- STEP 6: CREATE FREIGHT REQUEST (Screenshots 2, 3, 4 & 5) ---
  Widget _freightSelectionStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Create Freight Request',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Request freight pricing from carriers and compare competitive bids',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          if (controller.hasActiveRequest.value) {
            return _buildActiveFreightRequestCard(context);
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 850;
              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _freightFormSection(context),
                    const SizedBox(height: 24),
                    _selectCarriersSection(context),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _freightFormSection(context)),
                  const SizedBox(width: 24),
                  Expanded(flex: 4, child: _selectCarriersSection(context)),
                ],
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildActiveFreightRequestCard(BuildContext context) {
    final active = controller.activeDelivery.value ?? {};
    final reqId = (active['requestId'] ?? '').toString();
    final status = (active['status'] ?? 'BIDDING SENT').toString();
    final fromLoc = (active['from'] ?? 'New York, United States').toString();
    final toLoc = (active['to'] ?? 'A, Los Angeles County, California, United St...').toString();
    final pickupDate = (active['pickup'] ?? '02/09/2026').toString();
    final deliveryDate = (active['delivery'] ?? '03/10/2026').toString();
    final weightStr = (active['weight'] ?? '55789.2 Lbs').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Freight Request In Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'An active freight bid request has already been initiated for this project.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (reqId.isNotEmpty) {
                    Get.toNamed(
                      AppRoutes.freightRequestDetails,
                      parameters: {'id': reqId},
                    );
                  } else {
                    Get.toNamed(AppRoutes.freightLoads);
                  }
                },
                icon: const Text(
                  'Go to Freight Request',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                label: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'ACTIVE DELIVERIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              if (reqId.isNotEmpty) {
                Get.toNamed(
                  AppRoutes.freightRequestDetails,
                  parameters: {'id': reqId},
                );
              } else {
                Get.toNamed(AppRoutes.freightLoads);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 290,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'From: ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: fromLoc,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'To: ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: toLoc,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Pickup: ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: pickupDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Delivery: ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: deliveryDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    weightStr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final formatted = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      controller.text = formatted;
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final formatted = '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
      controller.text = formatted;
    }
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      if (!context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final period = time.period == DayPeriod.am ? 'AM' : 'PM';
        final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        final formattedTime = '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
        controller.text = '$formattedDate, $formattedTime';
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
      );
      if (result.isNotEmpty) {
        controller.uploadedDocumentName.value = result.first.name;
      }
    } catch (_) {}
  }

  Widget _freightFormSection(BuildContext context) {
    return Column(
      children: [
        // 1. Load Details Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.inventory_2_outlined, color: Color(0xFFF97316), size: 20),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Load Details (Auto-Fill)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Describe what needs to be transported', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _formLabel('Load Description *'),
              const SizedBox(height: 6),
              _formTextField(controller: controller.loadDescriptionCtrl),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formLabel('Weight *'),
                        const SizedBox(height: 6),
                        _formTextField(controller: controller.weightCtrl, suffix: 'Lbs ˅'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formLabel('Dimensions'),
                        const SizedBox(height: 6),
                        _formTextField(controller: controller.dimensionsCtrl, prefixIcon: Icons.straighten),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _formLabel('Material Type'),
              const SizedBox(height: 6),
              _formDropdownField(
                controller: controller.materialTypeCtrl,
                options: const [
                  'Steel & Metal',
                  'framing, panels, mixed, accessories',
                ],
                hintText: 'Select Material Type',
              ),
              const SizedBox(height: 16),
              _formLabel('Pallet / Package Count'),
              const SizedBox(height: 6),
              _formTextField(controller: controller.palletCountCtrl),
              const SizedBox(height: 16),
              _formLabel('Loading Equipment'),
              const SizedBox(height: 6),
              _formDropdownField(
                controller: controller.loadingEquipmentCtrl,
                options: const [
                  'Crane',
                  'Forklift',
                ],
                hintText: 'Select Loading Equipment',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formLabel('Bid Deadline *'),
                        const SizedBox(height: 6),
                        _formTextField(
                          controller: controller.bidDeadlineCtrl,
                          suffixIcon: Icons.calendar_today,
                          onTap: () => _selectDateTime(context, controller.bidDeadlineCtrl),
                          onSuffixTap: () => _selectDateTime(context, controller.bidDeadlineCtrl),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formLabel('Document Upload'),
                        const SizedBox(height: 6),
                        Obx(() => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.inputBorder),
                              ),
                              child: InkWell(
                                onTap: _pickDocument,
                                child: Row(
                                  children: [
                                    const Icon(Icons.attach_file, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.uploadedDocumentName.value,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.file_upload_outlined, size: 16, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Locations Card (Live Address Search API)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_outlined, color: Color(0xFF2563EB), size: 20),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Locations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Pickup and delivery addresses', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pickup Location with Live Search
              _formLabel('Pickup Location *'),
              const SizedBox(height: 6),
              _formTextField(
                controller: controller.pickupLocationCtrl,
                prefixIcon: Icons.location_on,
                prefixColor: Colors.green,
                suffixIcon: Icons.close,
                onSuffixTap: () {
                  controller.pickupLocationCtrl.clear();
                  controller.pickupSuggestions.clear();
                },
                onChanged: (val) => controller.searchPickupAddress(val),
              ),
              Obx(() {
                if (controller.isSearchingPickup.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                if (controller.pickupSuggestions.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      children: controller.pickupSuggestions.map((addr) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on, size: 16, color: Colors.green),
                          title: Text(addr, style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            controller.pickupLocationCtrl.text = addr;
                            controller.pickupSuggestions.clear();
                          },
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),

              // Delivery Location with Live Search
              _formLabel('Delivery Location *'),
              const SizedBox(height: 6),
              _formTextField(
                controller: controller.deliveryLocationCtrl,
                prefixIcon: Icons.location_on,
                prefixColor: Colors.red,
                suffixIcon: Icons.close,
                onSuffixTap: () {
                  controller.deliveryLocationCtrl.clear();
                  controller.deliverySuggestions.clear();
                },
                onChanged: (val) => controller.searchDeliveryAddress(val),
              ),
              Obx(() {
                if (controller.isSearchingDelivery.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                if (controller.deliverySuggestions.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      children: controller.deliverySuggestions.map((addr) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on, size: 16, color: Colors.red),
                          title: Text(addr, style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            controller.deliveryLocationCtrl.text = addr;
                            controller.deliverySuggestions.clear();
                          },
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. Timing Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_month_outlined, color: Color(0xFF16A34A), size: 20),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Timing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Pickup and delivery schedule', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formLabel('Pickup Date *'),
                        const SizedBox(height: 6),
                        _formTextField(
                          controller: controller.pickupDateCtrl,
                          suffixIcon: Icons.calendar_today,
                          onTap: () => _selectDate(context, controller.pickupDateCtrl),
                          onSuffixTap: () => _selectDate(context, controller.pickupDateCtrl),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formLabel('Pickup Time'),
                        const SizedBox(height: 6),
                        _formTextField(
                          controller: controller.pickupTimeCtrl,
                          suffixIcon: Icons.access_time,
                          onTap: () => _selectTime(context, controller.pickupTimeCtrl),
                          onSuffixTap: () => _selectTime(context, controller.pickupTimeCtrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formLabel('Delivery Date *'),
                        const SizedBox(height: 6),
                        _formTextField(
                          controller: controller.deliveryDateCtrl,
                          suffixIcon: Icons.calendar_today,
                          onTap: () => _selectDate(context, controller.deliveryDateCtrl),
                          onSuffixTap: () => _selectDate(context, controller.deliveryDateCtrl),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formLabel('Delivery Time'),
                        const SizedBox(height: 6),
                        _formTextField(
                          controller: controller.deliveryTimeCtrl,
                          suffixIcon: Icons.access_time,
                          onTap: () => _selectTime(context, controller.deliveryTimeCtrl),
                          onSuffixTap: () => _selectTime(context, controller.deliveryTimeCtrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. Coordination Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.person_outline, color: Color(0xFF8B5CF6), size: 20),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coordination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Contact and special requirements', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _formLabel('Receiving POC *'),
              const SizedBox(height: 6),
              _formTextField(controller: controller.receivingPocCtrl, prefixIcon: Icons.person_outline),
              const SizedBox(height: 16),
              _formLabel('Pickup Contact Phone *'),
              const SizedBox(height: 6),
              _formTextField(controller: controller.pickupPhoneCtrl, prefixIcon: Icons.phone_outlined),
              const SizedBox(height: 16),
              _formLabel('Special Requirements'),
              const SizedBox(height: 6),
              _formTextField(controller: controller.specialRequirementsCtrl, hintText: 'e.g., Crane unloading required, liftgate needed, fragile...', maxLines: 3),
              const SizedBox(height: 16),
              _formLabel('Additional Notes'),
              const SizedBox(height: 6),
              _formTextField(controller: controller.additionalNotesCtrl, hintText: 'Any other information for carriers...', maxLines: 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _selectCarriersSection(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: Color(0xFF2563EB), size: 20),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Carriers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          SizedBox(height: 2),
                          Text('Send bid request to carriers', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.tune, color: AppColors.textSecondary, size: 18),
                ],
              ),
              const SizedBox(height: 20),

              // Carrier Item 1 (Unchecked)
              Obx(() {
                final isSelected = controller.selectedCarriers.contains('React6 Carrier Pvt Ltd');
                return InkWell(
                  onTap: () => controller.toggleCarrier('React6 Carrier Pvt Ltd'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (val) => controller.toggleCarrier('React6 Carrier Pvt Ltd'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('React6 Carrier Pvt Ltd', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 13, color: Color(0xFFEAB308)),
                                  SizedBox(width: 4),
                                  Text('4.7  •  Last: \$8,066.67', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text('Flatbed', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('On-time rate: 94%', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('Service Area: texas, oklahoma', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Carrier Item 2 (Checked by default)
              Obx(() {
                final isSelected = controller.selectedCarriers.contains('Ayesha LLC');
                return InkWell(
                  onTap: () => controller.toggleCarrier('Ayesha LLC'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (val) => controller.toggleCarrier('Ayesha LLC'),
                          activeColor: const Color(0xFF16A34A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Ayesha LLC', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 13, color: Color(0xFFEAB308)),
                                  SizedBox(width: 4),
                                  Text('5.0  •  Last: \$14,812.5', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text('Dry Vans', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('On-time rate: 94%', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('Service Area: Texas', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Selected Carriers Info Banner
              Obx(() {
                final count = controller.selectedCarriers.length;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: Color(0xFF2563EB)),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$count Carriers Selected', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          const Text('Select carriers to request freight quotes', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons Column
        Obx(() {
          final count = controller.selectedCarriers.length;
          return Column(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showEmailQuoteDialog(context),
                icon: const Icon(Icons.send, size: 16, color: Colors.white),
                label: Text('Send to $count Carriers', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => controller.submitFreightRequest(isDraft: true),
                icon: const Icon(Icons.save_outlined, size: 16, color: AppColors.textPrimary),
                label: const Text('Save as Draft', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.inputBorder),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: Get.back,
                child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _formLabel(String label) => Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary));

  Widget _formTextField({
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
    Color? prefixColor,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    String? suffix,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: 16, color: prefixColor ?? AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textHint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (suffix != null) ...[
            Text(suffix, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
          if (suffixIcon != null) ...[
            GestureDetector(
              onTap: onSuffixTap ?? onTap,
              child: Icon(suffixIcon, size: 16, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _formDropdownField({
    required TextEditingController controller,
    required List<String> options,
    String? hintText,
  }) {
    final isOpen = false.obs;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: PopupMenuButton<String>(
        onOpened: () => isOpen.value = true,
        onCanceled: () => isOpen.value = false,
        onSelected: (val) {
          isOpen.value = false;
          controller.text = val;
        },
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        offset: const Offset(0, 42),
        itemBuilder: (context) => options
            .map((opt) => PopupMenuItem<String>(
                  value: opt,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, val, _) {
                      final isSelected = val.text == opt;
                      return Text(
                        opt,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ))
            .toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final text = value.text;
                    return Text(
                      text.isNotEmpty ? text : (hintText ?? 'Select option'),
                      style: TextStyle(
                        fontSize: 12,
                        color: text.isNotEmpty ? AppColors.textPrimary : AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              Obx(() => Icon(
                    isOpen.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.textSecondary,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // EMAIL QUOTE PREVIEW DIALOG (Screenshot 4)
  void _showEmailQuoteDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 680,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Email', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 20),

                // Email Header Banner
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.email, color: Color(0xFFEF4444), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Freight Request – 22 bundle(s) for bundle plan ${controller.bundlePlanId} | Pickup & Delivery Details',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _emailDetailLine('Project:', '22 bundle(s) for bundle plan ${controller.bundlePlanId}'),
                _emailDetailLine('Pickup Date:', 'August 21, 2026 at 21:10'),
                _emailDetailLine('Delivery Date:', 'August 29, 2026 at 20:10'),
                _emailDetailLine('POC:', 'Jouns'),
                _emailDetailLine('Delivery Location:', 'Califonia craft beer, 43381;43387, Mission Boulevard, Mission San Jose District, Fremont, Alameda County, California, 94537, United States'),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Load Details:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          const Text('•  Total Weight: 55,789.2 Lbs', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          const Text('•  Bundles: 22', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          const Text('•  Material: framing, panels, mixed, accessories', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          const Text('•  Equipment: Crane', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Site Details:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          const Text('•  Pickup: Texas, United States', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          const Text('•  Deadline: August 28, 2026 at 21:10', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await controller.submitFreightRequest(isDraft: false);
                      _showFreightRequestSentDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Submit your quote to Carriers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailDetailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  // FREIGHT REQUEST SENT SUCCESS DIALOG (Screenshot 5)
  void _showFreightRequestSentDialog(BuildContext context) {
    final count = controller.selectedCarriers.length;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Freight request sent to $count Carriers',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              Image.asset(
                AppImages.icSuccessfully,
                height: 110,
                width: 110,
                errorBuilder: (ctx, err, stack) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 64),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.offNamed(AppRoutes.freightLoads); // navigate to Freight Loads list view
                  CommonSnackbar.showSuccess(title: 'Request Sent', message: 'Freight request sent to selected carriers successfully.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Carriers Quotations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- GENERIC WORKFLOW STEP ---
  Widget _genericWorkflowStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _projectCard(),
        const SizedBox(height: 22),
        _responseSections(),
        const SizedBox(height: 22),
        Align(
          alignment: Alignment.centerRight,
          child: _actionButton(
            controller.step.value == 5
                ? 'Approve & Create Freight Request'
                : controller.step.value == 6
                ? 'Finish'
                : 'Continue',
            controller.step.value == 5
                ? controller.approveLoadPlan
                : controller.step.value == 6
                ? () async => controller.finish()
                : controller.next,
          ),
        ),
      ],
    );
  }

  // --- DIALOGS (Screenshot 2 & Screenshot 3) ---

  Widget _buildEditBundleScreen(BuildContext context, BundleDataModel item) {
    final instructionsCtrl = TextEditingController(text: item.handlingInstructions);
    final notesCtrl = TextEditingController(text: item.notes);
    final qty1Ctrl = TextEditingController(text: '${item.qty > 0 ? item.qty : 74}');
    final qty2Ctrl = TextEditingController(text: '24');
    final qty3Ctrl = TextEditingController(text: '1');
    final qty4Ctrl = TextEditingController(text: '1');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: controller.cancelEditBundle,
              icon: const Icon(Icons.arrow_back, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Edit Bundle',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Select Items and edit details to update the bundle',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                item.handlingInstructions = instructionsCtrl.text;
                item.notes = notesCtrl.text;
                final newQty = int.tryParse(qty1Ctrl.text) ?? item.qty;
                item.qty = newQty;
                item.unitWeight = newQty * (item.unitWeightSingle > 0 ? item.unitWeightSingle : 68.62);
                controller.bundleList.refresh();
                controller.cancelEditBundle();
                CommonSnackbar.showSuccess(
                  title: 'Bundle Saved',
                  message: 'Bundle ${item.bundleId} details updated successfully.',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Bundle',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('BUNDLE ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('PROFILE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('ITEMS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('LENGTH', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('TOTAL WEIGHT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const SizedBox(width: 32, child: Text('1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text(item.bundleId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text(item.profile, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text('${item.partNumber} × ${item.itemsCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(item.length, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text('${item.unitWeight.toStringAsFixed(2)} LBS', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text(item.status.capitalizeFirst!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HANDLING INSTRUCTIONS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: instructionsCtrl,
                          decoration: InputDecoration(
                            hintText: 'Enter handling instructions',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOTES',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: notesCtrl,
                          decoration: InputDecoration(
                            hintText: 'Enter notes',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 32, child: Icon(Icons.check_box, size: 18, color: Color(0xFF2563EB))),
                          SizedBox(width: 80, child: Text('QTY ↕', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          SizedBox(width: 100, child: Text('Item ↕', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          Expanded(child: Text('DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          SizedBox(width: 90, child: Text('Length ↕', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          SizedBox(width: 100, child: Text('UNIT WEIGHT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          SizedBox(width: 100, child: Text('TOTAL WEIGHT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _editableItemRow(
                      qtyCtrl: qty1Ctrl,
                      itemCode: item.partNumber,
                      description: item.description,
                      length: item.length,
                      unitWeight: item.unitWeightSingle > 0 ? item.unitWeightSingle : 68.62,
                      totalWeight: item.unitWeight > 0 ? item.unitWeight : 5077.94,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _editableItemRow(
                      qtyCtrl: qty2Ctrl,
                      itemCode: item.partNumber,
                      description: 'Wall Girt',
                      length: item.length,
                      unitWeight: 0.00,
                      totalWeight: 0.00,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _editableItemRow(
                      qtyCtrl: qty3Ctrl,
                      itemCode: item.partNumber,
                      description: 'Wall Girt',
                      length: '24.13 ft',
                      unitWeight: 0.00,
                      totalWeight: 0.00,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _editableItemRow(
                      qtyCtrl: qty4Ctrl,
                      itemCode: item.partNumber,
                      description: 'Wall Girt',
                      length: '24.13 ft',
                      unitWeight: 0.00,
                      totalWeight: 0.00,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editableItemRow({
    required TextEditingController qtyCtrl,
    required String itemCode,
    required String description,
    required String length,
    required double unitWeight,
    required double totalWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 32,
            child: Icon(Icons.check_box, size: 18, color: Color(0xFF2563EB)),
          ),
          SizedBox(
            width: 80,
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: qtyCtrl,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: Text(
              itemCode,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              length,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              unitWeight.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              totalWeight.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // QR CODE DATA DIALOG (Screenshot 3)
  void _showQrDialog(BuildContext context, BundleDataModel item) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 540,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QR Code Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: QrImageView(
                      data:
                          'project=${controller.projectName}\nLoad : load_id=1\nBundle : bundle_id=${item.bundleId}\nParts : parts=${item.profile.toLowerCase()}\nWeight : weight=${item.unitWeight}\nLength : Length=${item.length.replaceAll(' ft', '')}',
                      version: QrVersions.auto,
                      size: 140.0,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'project=${controller.projectName}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _qrDetailRow('Load :', 'load_id=1'),
                        _qrDetailRow('Bundle :', 'bundle_id=${item.bundleId}'),
                        _qrDetailRow('Parts :', 'parts=${item.profile.toLowerCase()}'),
                        _qrDetailRow('Weight :', 'weight=${item.unitWeight.toStringAsFixed(2)}'),
                        _qrDetailRow('Length :', 'Length=${item.length.replaceAll(' ft', '')}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final bytes = await _generateQrLabelPdf(
                          projectName: controller.projectName,
                          shipperId: controller.requestId.isNotEmpty ? controller.requestId : '6a85db8f4aba512f82285789',
                          loadId: '4',
                          bundleId: item.bundleId,
                          parts: item.profile.toLowerCase(),
                          weight: item.unitWeight.toStringAsFixed(2),
                          length: item.length,
                        );
                        await Printing.sharePdf(
                          bytes: bytes,
                          filename: 'QR_Label_${item.bundleId}.pdf',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Export PDF',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final bytes = await _generateQrLabelPdf(
                          projectName: controller.projectName,
                          shipperId: controller.requestId.isNotEmpty ? controller.requestId : '6a85db8f4aba512f82285789',
                          loadId: '4',
                          bundleId: item.bundleId,
                          parts: item.profile.toLowerCase(),
                          weight: item.unitWeight.toStringAsFixed(2),
                          length: item.length,
                        );
                        await Printing.layoutPdf(
                          onLayout: (format) async => bytes,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Print',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qrDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generateQrLabelPdf({
    required String projectName,
    required String shipperId,
    required String loadId,
    required String bundleId,
    required String parts,
    required String weight,
    required String length,
  }) async {
    final pdf = pw.Document();

    final qrData =
        'project=$projectName\nShipper: shipper=$shipperId\nLoad: load_id=$loadId\nBundle: bundle_id=$bundleId\nParts: parts=$parts\nWeight: weight=$weight LBS\nLength: length=$length';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Center(
            child: pw.Container(
              width: 340,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(16),
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 1.5),
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    projectName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#0F172A'),
                    ),
                  ),
                  pw.SizedBox(height: 18),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrData,
                    drawText: false,
                    width: 150,
                    height: 150,
                  ),
                  pw.SizedBox(height: 22),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F8FAFC'),
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 1),
                    ),
                    child: pw.Column(
                      children: [
                        _pdfDetailRowItem('Shipper:', shipperId),
                        pw.SizedBox(height: 4),
                        pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 0.5),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem('Load ID:', loadId),
                        pw.SizedBox(height: 4),
                        pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 0.5),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem('Bundle ID:', bundleId),
                        pw.SizedBox(height: 4),
                        pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 0.5),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem('Parts:', parts),
                        pw.SizedBox(height: 4),
                        pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 0.5),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem('Weight:', weight.contains('LBS') ? weight : '$weight LBS'),
                        pw.SizedBox(height: 4),
                        pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 0.5),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem('Length:', length.contains('ft') ? length : '$length ft'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfDetailRowItem(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#334155'),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            color: PdfColor.fromHex('#0F172A'),
          ),
        ),
      ],
    );
  }

  Widget _projectBannerCard({
    required String title,
    required String idLabel,
    required String idValue,
    required String planLabel,
    required String planValue,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '$idLabel  ',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                idValue,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 32),
              Text(
                '$planLabel  ',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                planValue,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _projectCard() {
    return _projectBannerCard(
      title: 'Project: ${controller.projectName}',
      idLabel: 'Project ID:',
      idValue: controller.projectCode,
      planLabel: 'Vendor:',
      planValue: controller.vendorName,
    );
  }

  Widget _responseSections() {
    final entries = controller.data.entries
        .where((e) => !_isProjectField(e.key))
        .toList();
    if (entries.isEmpty) {
      return _empty('No workflow data was returned for this step.');
    }
    return Column(
      children: entries
          .map((entry) => _dynamicSection(_title(entry.key), entry.value))
          .toList(),
    );
  }

  Widget _dynamicSection(String title, dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final scalar = <String, dynamic>{};
      final nested = <MapEntry<String, dynamic>>[];
      for (final entry in map.entries) {
        if (entry.value is Map || entry.value is List) {
          nested.add(entry);
        } else {
          scalar[entry.key] = entry.value;
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (scalar.isNotEmpty) _mapSection(title, scalar),
          ...nested.map(
            (entry) => _dynamicSection(_title(entry.key), entry.value),
          ),
        ],
      );
    }
    if (value is List) {
      if (value.isEmpty) return const SizedBox.shrink();
      final rows = value
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      if (rows.isEmpty) {
        return _mapSection(title, {'Values': value.join(', ')});
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _listSection(title, value),
          ...rows.asMap().entries.expand((indexed) {
            final nested = indexed.value.entries.where(
              (entry) => entry.value is Map || entry.value is List,
            );
            return nested.map(
              (entry) => _dynamicSection(
                '$title ${indexed.key + 1} · ${_title(entry.key)}',
                entry.value,
              ),
            );
          }),
        ],
      );
    }
    return _mapSection(title, {'Value': value});
  }

  Widget _mapSection(String title, Map<String, dynamic> map) {
    if (map.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 42,
            runSpacing: 18,
            children: map.entries
                .map((e) => _labelValue(_title(e.key), _display(e.value)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _listSection(String title, List values) {
    final rows = values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    final keys = <String>{};
    for (final row in rows) {
      keys.addAll(
        row.entries
            .where((e) => e.value is! Map && e.value is! List)
            .map((e) => e.key),
      );
    }
    final columns = keys.take(9).toList();
    if (columns.isEmpty) {
      return _empty('No workflow data was returned for this step.');
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              columns: columns
                  .map((key) => DataColumn(label: Text(_title(key))))
                  .toList(),
              rows: rows
                  .map(
                    (row) => DataRow(
                      cells: columns
                          .map(
                            (key) => DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  _display(row[key]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Future<void> Function() action) {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.actionLoading.value ? null : action,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.actionLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _labelValue(String label, String value) => SizedBox(
    width: 260,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  Widget _empty(String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(48),
    decoration: _cardDecoration(),
    child: Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
      ),
    ),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFE2E8F0)),
  );

  bool _isProjectField(String key) =>
      const {'Project ID', 'Vendor', 'Shipper file'}.contains(key);
  String _display(dynamic value) => value == null || value.toString().isEmpty
      ? '-'
      : value is bool
      ? (value ? 'Yes' : 'No')
      : value.toString();
  String _title(String value) => value
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAll('_', ' ')
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
}

