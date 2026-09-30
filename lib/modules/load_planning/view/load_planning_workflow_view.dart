import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/services/file_export_service.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/load_planning_workflow_controller.dart';
import '../model/bundle_data_model.dart';
import '../widgets/packing_list_modal_dialog.dart';

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header Bar with Back Button
                      Row(
                        children: const [
                          AppBackButton(),
                          SizedBox(width: 16),
                          Text(
                            'Load Planning Workflow',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

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
        children: List.generate(LoadPlanningWorkflowController.steps.length, (
          index,
        ) {
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
                      if (index <
                          LoadPlanningWorkflowController.steps.length - 1)
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
                      fontWeight: activeOrDone
                          ? FontWeight.bold
                          : FontWeight.w500,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Obx(() {
              final isBusy = controller.actionLoading.value;
              return ElevatedButton(
                onPressed: isBusy ? null : controller.autoOptimize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  disabledBackgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isBusy
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Optimizing Bundles...',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Auto Optimize Bundles',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              );
            }),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
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
                            message:
                                'Please confirm the bundle plan before proceeding.',
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
            title:
                'Project: ${controller.projectName} | Bundle Plan ID: ${controller.displayBundlePlanId}',
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
          _kpiRow(
            'Bundle Warnings',
            warnings,
            isWarning: !warnings.startsWith('0'),
          ),
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
          _kpiRow(
            'Prefered Bundle Weight',
            controller.preferredBundleWeightText,
          ),
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
            decoration: const BoxDecoration(color: Color(0xFF1E293B)),
            child: Row(
              children: const [
                SizedBox(
                  width: 32,
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
                    'BUNDLE ID',
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
                    'PROFILE',
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
                    'ITEMS',
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
                    'LENGTH',
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
                    'UNIT WEIGHT',
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
                    'STATUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    'ACTIONS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
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
                              icon: const Icon(
                                Icons.qr_code,
                                size: 14,
                                color: Colors.white,
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
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
    if (controller.truckloadList.isEmpty && !controller.loading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.truckloadList.isEmpty && controller.step.value == 2) {
          controller.loadTruckPlan();
        }
      });
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
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Obx(
              () => ElevatedButton(
                onPressed: controller.actionLoading.value
                    ? null
                    : () => controller.confirmAndGeneratePackingList(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.actionLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Generate Packing List',
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
        const SizedBox(height: 20),

        // Project Banner Card
        Obx(
          () => _projectBannerCard(
            title:
                'Project: ${controller.displayProjectName} | Packing Plan ID: ${controller.displayPackingListPlanId}',
            idLabel: 'Project ID:',
            idValue: controller.displayProjectId,
            planLabel: 'Packing Plan Id:',
            planValue: controller.displayPackingListPlanId,
          ),
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
      child: Obx(
        () => Column(
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
            _kpiRow('Total Bundles', '${controller.truckloadTotalBundles}'),
            const SizedBox(height: 8),
            _kpiRow('Planned Truck Loads', '${controller.truckloadPlannedLoads}'),
            const SizedBox(height: 8),
            _kpiRow('Total Weight', controller.truckloadTotalWeightText),
            const SizedBox(height: 8),
            _kpiRow(
              'Average Load Utilization',
              '${controller.truckloadAverageUtilization}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _truckSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Obx(
        () => Column(
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
            _kpiRow("53' Semi Truck Count", '${controller.truckloadSemi53Count}'),
            const SizedBox(height: 8),
            _kpiRow("40' Hotshot Count", '${controller.truckloadHotshot40Count}'),
            const SizedBox(height: 8),
            _kpiRow('Total Trucks', '${controller.truckloadTotalTrucks}'),
          ],
        ),
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
            decoration: const BoxDecoration(color: Color(0xFF1E293B)),
            child: Row(
              children: const [
                SizedBox(
                  width: 32,
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
                    'LOAD ID',
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
                    'BUNDLE',
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
                    'TOTAL WEIGHT',
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
                    'UTILIZATION',
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
                    'STATUS',
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
          // Rows
          Obx(() {
            if (controller.actionLoading.value ||
                (controller.loading.value && controller.truckloadList.isEmpty)) {
              return Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                          item.utilizationPercentage > 0
                              ? '${item.utilizationPercentage}%'
                              : '—',
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.status.toLowerCase() == 'confirmed' ||
                                    item.status.toLowerCase() == 'ready'
                                ? const Color(0xFF16A34A)
                                : AppColors.textSecondary,
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

  // --- STEP 3: PACKING LIST ---
  Widget _packingListStep(BuildContext context) {
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
                  onPressed: () => controller.goToStep(2),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Obx(() => ElevatedButton(
              onPressed: controller.actionLoading.value ? null : () => controller.goToStep(4),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: controller.actionLoading.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Generate QR Label',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            )),
          ],
        ),
        const SizedBox(height: 20),

        // Project Banner Card
        Obx(
          () => _projectBannerCard(
            title:
                'Project: ${controller.displayProjectName} | Truckloads: ${controller.truckloadPlannedLoads}',
            idLabel: 'Project ID:',
            idValue: controller.displayProjectId,
            planLabel: 'Packing Plan Id:',
            planValue: controller.displayPackingListPlanId,
          ),
        ),
        const SizedBox(height: 20),

        // Optimization Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Optimization Summary Card',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                _kpiRow('Truck Loads', '${controller.truckloadPlannedLoads}'),
                const SizedBox(height: 8),
                _kpiRow('Total Bundles', '${controller.truckloadTotalBundles}'),
                const SizedBox(height: 8),
                _kpiRow('Total Weight', controller.truckloadTotalWeightText),
                const SizedBox(height: 8),
                _kpiRow('Packing List Generated', '${controller.rawPackingLists.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Packing List Table Card
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
                decoration: const BoxDecoration(color: Color(0xFF1E293B)),
                child: Row(
                  children: const [
                    SizedBox(width: 36, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('LOAD ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('TRUCK', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('BUNDLES', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('WEIGHT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('STATUS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    SizedBox(width: 120, child: Text('ACTIONS', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Obx(() {
                final lists = controller.rawPackingLists;
                if (lists.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Text('No packing lists available.'),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lists.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final item = lists[index];
                    final pNo = (item['packingListNo'] ?? 'PL-00${index + 1}').toString();
                    final truck = (item['truckLabel'] ?? item['truckType'] ?? item['truckNo'] ?? '—').toString();
                    final bundles = item['totalBundles']?.toString() ?? '—';
                    final weight = item['totalWeight'] is num ? '${(item['totalWeight'] as num).toStringAsFixed(1)} LBS' : '—';
                    final status = (item['status'] ?? 'Ready').toString();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          SizedBox(width: 36, child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(pNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          Expanded(flex: 2, child: Text(truck, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 1, child: Text(bundles, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(weight, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(
                            flex: 1,
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'ready'
                                    ? const Color(0xFF16A34A)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () => _downloadPackingListPdf(item),
                                  icon: const Icon(Icons.file_download_outlined, size: 18, color: Color(0xFF64748B)),
                                  tooltip: 'Download PDF',
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () => PackingListModalDialog.show(
                                    context,
                                    packingList: item,
                                    allBundles: controller.rawBundles,
                                    projectName: controller.displayProjectName,
                                    planNumber: controller.displayPackingListPlanId,
                                    showQr: false,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    foregroundColor: const Color(0xFF334155),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
        ),
      ],
    );
  }

  // --- STEP 4: QR LABEL GENERATOR (Matches Web) ---
  Widget _qrLabelStep(BuildContext context) {
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
                  onPressed: () => controller.goToStep(3),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Obx(() => ElevatedButton(
              onPressed: controller.actionLoading.value ? null : () => controller.goToStep(5),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: controller.actionLoading.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Review Load Plan',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            )),
          ],
        ),
        const SizedBox(height: 20),

        // Project Banner Card
        Obx(
          () => _projectBannerCard(
            title:
                'Project: ${controller.displayProjectName} | Packing Plan ID: ${controller.displayPackingListPlanId}',
            idLabel: 'Project ID:',
            idValue: controller.displayProjectId,
            planLabel: 'Packing Plan Id:',
            planValue: controller.displayPackingListPlanId,
          ),
        ),
        const SizedBox(height: 20),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary Card',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                _kpiRow('Total Bundles', '${controller.truckloadTotalBundles}'),
                const SizedBox(height: 8),
                _kpiRow('Labels Generated', '${controller.truckloadTotalBundles}'),
                const SizedBox(height: 8),
                _kpiRow('Labels Printed', '${controller.truckloadTotalBundles}'),
                const SizedBox(height: 8),
                _kpiRow('Pending Labels', '0'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Truck List Table Card with View QR Action
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
                decoration: const BoxDecoration(color: Color(0xFF1E293B)),
                child: Row(
                  children: const [
                    SizedBox(width: 36, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('LOAD ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('TRUCK', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('BUNDLES', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('WEIGHT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('DESTINATION', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('STATUS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    SizedBox(width: 130, child: Text('ACTIONS', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Obx(() {
                final lists = controller.rawPackingLists;
                if (lists.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Text('No truck loads available.'),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lists.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final item = lists[index];
                    final pNo = (item['packingListNo'] ?? 'PL-00${index + 1}').toString();
                    final truck = (item['truckLabel'] ?? item['truckType'] ?? item['truckNo'] ?? '—').toString();
                    final bundles = item['totalBundles']?.toString() ?? '—';
                    final weight = item['totalWeight'] is num ? '${(item['totalWeight'] as num).toStringAsFixed(1)} LBS' : '—';
                    final destination = '${controller.displayProjectName} Site A';
                    final status = (item['status'] ?? 'Ready').toString();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          SizedBox(width: 36, child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(pNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          Expanded(flex: 2, child: Text(truck, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 1, child: Text(bundles, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(weight, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(destination, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(
                            flex: 1,
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'ready'
                                    ? const Color(0xFF16A34A)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            child: ElevatedButton.icon(
                              onPressed: () => PackingListModalDialog.show(
                                context,
                                packingList: item,
                                allBundles: controller.rawBundles,
                                projectName: controller.displayProjectName,
                                planNumber: controller.displayPackingListPlanId,
                                showQr: true,
                              ),
                              icon: const Icon(Icons.qr_code_2, size: 16, color: Colors.white),
                              label: const Text(
                                'View QR',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E51A4),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
        ),
      ],
    );
  }

  // --- STEP 5: LOAD PLAN REVIEW ---
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
                  onPressed: () => controller.goToStep(4),
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
                      'Review the finalized load plan before freight bidding.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Obx(() => ElevatedButton(
              onPressed: controller.actionLoading.value ? null : controller.approveLoadPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: controller.actionLoading.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Approve Load Plan',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            )),
          ],
        ),
        const SizedBox(height: 20),

        Obx(
          () => _projectBannerCard(
            title:
                'Project: ${controller.displayProjectName} | Load Plan Review',
            idLabel: 'Project ID:',
            idValue: controller.displayProjectId,
            planLabel: 'Packing Plan Id:',
            planValue: controller.displayPackingListPlanId,
          ),
        ),
        const SizedBox(height: 20),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Load Summary',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                _kpiRow('Planned Truck Loads', '${controller.truckloadPlannedLoads}'),
                const SizedBox(height: 8),
                _kpiRow('Total Bundles', '${controller.truckloadTotalBundles}'),
                const SizedBox(height: 8),
                _kpiRow('Total Weight', controller.truckloadTotalWeightText),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Truckloads Table
        Container(
          width: double.infinity,
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Final Load Allocation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(color: Color(0xFF1E293B)),
                child: Row(
                  children: const [
                    SizedBox(width: 36, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('LOAD ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('TRUCK', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('BUNDLES', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('WEIGHT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('STATUS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    SizedBox(width: 100, child: Text('ACTIONS', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Obx(() {
                final lists = controller.rawPackingLists;
                if (lists.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Text('No load allocations available.'),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lists.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final item = lists[index];
                    final pNo = (item['packingListNo'] ?? 'PL-00${index + 1}').toString();
                    final truck = (item['truckLabel'] ?? item['truckType'] ?? item['truckNo'] ?? '—').toString();
                    final bundles = item['totalBundles']?.toString() ?? '—';
                    final weight = item['totalWeight'] is num ? '${(item['totalWeight'] as num).toStringAsFixed(1)} LBS' : '—';
                    final status = (item['status'] ?? 'Ready').toString();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          SizedBox(width: 36, child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(pNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                          Expanded(flex: 2, child: Text(truck, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 1, child: Text(bundles, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(weight, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(flex: 1, child: Text(status, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          SizedBox(
                            width: 100,
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () => PackingListModalDialog.show(
                                  context,
                                  packingList: item,
                                  allBundles: controller.rawBundles,
                                  projectName: controller.displayProjectName,
                                  planNumber: controller.displayPackingListPlanId,
                                  showQr: false,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  foregroundColor: const Color(0xFF334155),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
        ),
      ],
    );
  }

  Future<void> _downloadPackingListPdf(Map<String, dynamic> item) async {
    try {
      final pListNo = (item['packingListNo'] ?? item['loadId'] ?? 'PL-001').toString();
      final id = (item['_id'] ?? item['id'] ?? pListNo).toString();
      final url = 'https://storage-material-vendor-deployment.vercel.app/packing-list/$id';
      final bytes = await FileExportService.qrPdf(
        title: 'Packing List — $pListNo',
        payload: url,
      );
      await FileExportService.savePdf(
        fileName: 'packing_list_$pListNo',
        bytes: Uint8List.fromList(bytes),
      );
      CommonSnackbar.showSuccess(
        title: 'Download Successful',
        message: 'Packing list PDF has been downloaded.',
      );
    } catch (e) {
      CommonSnackbar.showError(
        title: 'Download Failed',
        message: e.toString(),
      );
    }
  }

  Widget _freightSelectionStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppBackButton(
              onPressed: () => controller.goToStep(5),
            ),
            const SizedBox(width: 16),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvailableDeliveriesSection(context),
                        const SizedBox(height: 24),
                        _freightFormSection(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 360,
                    child: _buildRightCarriersSidebar(context),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvailableDeliveriesSection(context),
                const SizedBox(height: 24),
                _freightFormSection(context),
                const SizedBox(height: 24),
                _buildRightCarriersSidebar(context),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvailableDeliveriesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
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
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Available Deliveries to Send',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Select an existing delivery load to pre-fill details',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final deliveries = controller.projectDeliveries;
            final isLoading = controller.isLoadingDeliveries.value;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading && deliveries.isEmpty)
                    Container(
                      width: 260,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (deliveries.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: const Text(
                        'No deliveries available for this project.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    ...deliveries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final delivery = entry.value;
                      final id = (delivery['_id'] ??
                              delivery['id'] ??
                              delivery['deliveryId'] ??
                              delivery['requestId'] ??
                              '')
                          .toString();
                      final isSelected =
                          controller.selectedDeliveryId.value == id;
                      return Padding(
                        padding: EdgeInsets.only(left: index == 0 ? 0 : 16),
                        child: _buildDeliveryLoadCard(
                          delivery: delivery,
                          isSelected: isSelected,
                        ),
                      );
                    }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryLoadCard({
    required Map<String, dynamic> delivery,
    required bool isSelected,
  }) {
    final statusRaw = (delivery['status'] ?? 'draft').toString().toUpperCase().replaceAll('_', ' ');
    final isDraft = statusRaw.contains('DRAFT');

    final fromLoc = (delivery['pickupLocation'] ?? delivery['from'] ?? delivery['vendorAddress'] ?? 'Plant Yard').toString();
    final toLoc = (delivery['deliveryLocation'] ?? delivery['to'] ?? delivery['siteAddress'] ?? 'Destination Site').toString();

    final pickupDate = controller.formatDateDisplay(delivery['pickupDate'] ?? delivery['pickup']);
    final deliveryDate = controller.formatDateDisplay(delivery['deliveryDate'] ?? delivery['delivery']);

    final weightVal = delivery['weight'] ?? delivery['loadWeight'] ?? delivery['totalWeight'] ?? controller.totalPlannedWeightValue;
    final weightStr = '$weightVal Lbs';

    return InkWell(
      onTap: () => controller.selectDelivery(isSelected ? null : delivery),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 270,
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDraft ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusRaw,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDraft ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
              maxLines: 1,
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
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weightStr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightCarriersSidebar(BuildContext context) {
    return Obx(() {
      final selectedCount = controller.selectedCarriers.length;
      final loading = controller.carriersLoading.value;
      final error = controller.carriersError.value;
      final carriers = controller.filteredCarriers;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_shipping_outlined,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Select Carriers',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Send bid request to carriers',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => _showCarrierFilterDialog(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: controller.activeFiltersCount > 0
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.activeFiltersCount > 0
                                ? AppColors.primary
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Icon(
                          Icons.tune,
                          size: 18,
                          color: controller.activeFiltersCount > 0
                              ? AppColors.primary
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
                if (controller.activeFiltersCount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: controller.clearCarrierFilters,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Clear filter', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (loading) const LinearProgressIndicator(),
                if (error.isNotEmpty) ...[
                  Text(error, style: const TextStyle(fontSize: 12, color: Colors.red)),
                  TextButton(onPressed: controller.loadCarriers, child: const Text('Retry')),
                ],
                if (!loading && error.isEmpty && controller.availableCarriers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No active carriers available.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                if (!loading && error.isEmpty && controller.availableCarriers.isNotEmpty && carriers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Text('No carriers match filter.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        TextButton(onPressed: controller.clearCarrierFilters, child: const Text('Clear Filter')),
                      ],
                    ),
                  ),
                if (carriers.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 440),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: carriers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final carrier = carriers[index];
                        final id = (carrier['_id'] ?? '').toString();
                        final name = (carrier['carrierName'] ?? carrier['name'] ?? '').toString();
                        final isSelected = controller.selectedCarriers.contains(id);
                        final rating = carrier['rating']?.toString() ?? '4.8';
                        final lastPrice = carrier['lastPrice']?.toString() ?? '\$0';
                        final services = carrier['services']?.toString() ?? 'Dry Vans';
                        final onTimeRate = carrier['onTimeRate']?.toString() ?? '94%';
                        final serviceArea = carrier['serviceArea']?.toString() ?? 'Texas';

                        return _buildCarrierSidebarItem(
                          id: id,
                          name: name,
                          isSelected: isSelected,
                          rating: rating,
                          lastPrice: lastPrice,
                          services: services,
                          onTimeRate: onTimeRate,
                          serviceArea: serviceArea,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$selectedCount Carriers Selected',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Select carriers to request freight quotes',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: controller.actionLoading.value
                  ? null
                  : () {
                      if (!controller.validateFreightForm()) {
                        CommonSnackbar.showError(
                          title: 'Required fields missing',
                          message: 'Please fill in all required fields indicated in red.',
                        );
                        return;
                      }
                      if (controller.selectedCarriers.isEmpty) {
                        CommonSnackbar.showError(
                          title: 'Select carriers',
                          message: 'Please select at least one carrier to send quote request.',
                        );
                        return;
                      }
                      _showEmailQuoteDialog(context);
                    },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(
                'Send to $selectedCount Carriers',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: controller.actionLoading.value
                  ? null
                  : () => controller.submitFreightRequest(isDraft: true),
              icon: const Icon(Icons.bookmark_outline, size: 16),
              label: const Text(
                'Save as Draft',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => controller.goToStep(5),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCarrierSidebarItem({
    required String id,
    required String name,
    required bool isSelected,
    required String rating,
    required String lastPrice,
    required String services,
    required String onTimeRate,
    required String serviceArea,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: id.isEmpty ? null : () => controller.toggleCarrier(id),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0x1A2563EB)
                    : const Color(0x0A000000),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: id.isEmpty ? null : (_) => controller.toggleCarrier(id),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 14),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_shipping_outlined, size: 12, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              services,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last: $lastPrice',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Text(
                        'On-time: $onTimeRate',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 2),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: Text(
                          serviceArea,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _initialDateFor(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      try {
        if (text.contains('/')) {
          final parts = text.split(RegExp(r'[/, ]+'));
          if (parts.length >= 3) {
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final year = int.tryParse(parts[2]);
            if (day != null && month != null && year != null) {
              final d = DateTime(year, month, day);
              if (d.isAfter(DateTime(2020)) && d.isBefore(DateTime(2030))) {
                return d;
              }
            }
          }
        }
        final parsed = DateTime.tryParse(text);
        if (parsed != null &&
            parsed.isAfter(DateTime(2020)) &&
            parsed.isBefore(DateTime(2030))) {
          return parsed;
        }
      } catch (_) {}
    }
    return DateTime.now();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _initialDateFor(controller),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      controller.text = formatted;
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final formatted =
          '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
      controller.text = formatted;
    }
  }

  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _initialDateFor(controller),
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
        final formattedDate =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        final formattedTime =
            '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
        controller.text = '$formattedDate, $formattedTime';
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result.isNotEmpty) {
        await controller.uploadFreightDocument(result.first.name, await result.first.readAsBytes());
      }
    } catch (error) {
      Get.snackbar('Upload failed', error.toString());
    }
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
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFFF97316),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Load Details (Auto-Fill)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Describe what needs to be transported',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _formLabel('Load Description *'),
              const SizedBox(height: 6),
              Obx(() => _formTextField(
                controller: controller.loadDescriptionCtrl,
                errorText: controller.formErrors['loadDescription'],
                onChanged: (_) => controller.clearFormError('loadDescription'),
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formLabel('Weight *'),
                        const SizedBox(height: 6),
                        Obx(() => _formTextField(
                          controller: controller.weightCtrl,
                          suffix: 'Lbs ˅',
                          errorText: controller.formErrors['weight'],
                          onChanged: (_) => controller.clearFormError('weight'),
                        )),
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
                        _formTextField(
                          controller: controller.dimensionsCtrl,
                          prefixIcon: Icons.straighten,
                        ),
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
                options: const ['Crane', 'Forklift'],
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
                        Obx(() => _formTextField(
                          controller: controller.bidDeadlineCtrl,
                          suffixIcon: Icons.calendar_today,
                          hintText: 'dd/mm/yyyy, --:-- --',
                          errorText: controller.formErrors['bidDeadline'],
                          onTap: () async {
                            await _selectDateTime(
                              context,
                              controller.bidDeadlineCtrl,
                            );
                            controller.clearFormError('bidDeadline');
                          },
                          onSuffixTap: () async {
                            await _selectDateTime(
                              context,
                              controller.bidDeadlineCtrl,
                            );
                            controller.clearFormError('bidDeadline');
                          },
                        )),
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
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.inputBorder),
                            ),
                            child: InkWell(
                              onTap: _pickDocument,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.attach_file,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.uploadedDocumentName.value,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.file_upload_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
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

        // 2. Locations Card (Live Address Search API)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Locations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pickup and delivery addresses',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pickup Location with Live Search
              _formLabel('Pickup Location *'),
              const SizedBox(height: 6),
              Obx(() => _formTextField(
                controller: controller.pickupLocationCtrl,
                hintText: 'e.g., Steel Mill, Pittsburgh, PA',
                prefixIcon: Icons.location_on,
                prefixColor: Colors.green,
                suffixIcon: Icons.close,
                errorText: controller.formErrors['pickupLocation'],
                onSuffixTap: () {
                  controller.pickupLocationCtrl.clear();
                  controller.pickupSuggestions.clear();
                  controller.clearFormError('pickupLocation');
                },
                onChanged: (val) {
                  controller.clearFormError('pickupLocation');
                  controller.searchPickupAddress(val);
                },
              )),
              Obx(() {
                if (controller.isSearchingPickup.value) {
                  return Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1E51A4),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Searching locations...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (controller.pickupSuggestions.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: controller.pickupSuggestions.map((addr) {
                          return InkWell(
                            onTap: () {
                              controller.pickupLocationCtrl.text = addr;
                              controller.pickupSuggestions.clear();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFF1F5F9),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      addr,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),

              // Delivery Location with Live Search
              _formLabel('Delivery Location *'),
              const SizedBox(height: 6),
              Obx(() => _formTextField(
                controller: controller.deliveryLocationCtrl,
                hintText: 'e.g., Construction Site, Austin, TX',
                prefixIcon: Icons.location_on,
                prefixColor: Colors.red,
                suffixIcon: Icons.close,
                errorText: controller.formErrors['deliveryLocation'],
                onSuffixTap: () {
                  controller.deliveryLocationCtrl.clear();
                  controller.deliverySuggestions.clear();
                  controller.clearFormError('deliveryLocation');
                },
                onChanged: (val) {
                  controller.clearFormError('deliveryLocation');
                  controller.searchDeliveryAddress(val);
                },
              )),
              Obx(() {
                if (controller.isSearchingDelivery.value) {
                  return Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1E51A4),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Searching locations...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (controller.deliverySuggestions.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: controller.deliverySuggestions.map((addr) {
                          return InkWell(
                            onTap: () {
                              controller.deliveryLocationCtrl.text = addr;
                              controller.deliverySuggestions.clear();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFF1F5F9),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      addr,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
                  Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pickup and delivery schedule',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
                        Obx(() => _formTextField(
                          controller: controller.pickupDateCtrl,
                          hintText: 'dd/mm/yyyy',
                          prefixIcon: Icons.calendar_today_outlined,
                          suffixIcon: Icons.calendar_month,
                          errorText: controller.formErrors['pickupDate'],
                          onTap: () async {
                            await _selectDate(context, controller.pickupDateCtrl);
                            controller.clearFormError('pickupDate');
                          },
                          onSuffixTap: () async {
                            await _selectDate(context, controller.pickupDateCtrl);
                            controller.clearFormError('pickupDate');
                          },
                        )),
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
                          hintText: '--:-- --',
                          prefixIcon: Icons.access_time,
                          suffixIcon: Icons.access_time,
                          onTap: () =>
                              _selectTime(context, controller.pickupTimeCtrl),
                          onSuffixTap: () =>
                              _selectTime(context, controller.pickupTimeCtrl),
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
                        Obx(() => _formTextField(
                          controller: controller.deliveryDateCtrl,
                          hintText: 'dd/mm/yyyy',
                          prefixIcon: Icons.calendar_today_outlined,
                          suffixIcon: Icons.calendar_month,
                          errorText: controller.formErrors['deliveryDate'],
                          onTap: () async {
                            await _selectDate(context, controller.deliveryDateCtrl);
                            controller.clearFormError('deliveryDate');
                          },
                          onSuffixTap: () async {
                            await _selectDate(context, controller.deliveryDateCtrl);
                            controller.clearFormError('deliveryDate');
                          },
                        )),
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
                          hintText: '--:-- --',
                          prefixIcon: Icons.access_time,
                          suffixIcon: Icons.access_time,
                          onTap: () =>
                              _selectTime(context, controller.deliveryTimeCtrl),
                          onSuffixTap: () =>
                              _selectTime(context, controller.deliveryTimeCtrl),
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
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E8FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        color: Color(0xFF8B5CF6),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coordination',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Contact and special requirements',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 20),
              _formLabel('Receiving POC *'),
              const SizedBox(height: 6),
              Obx(() => _formTextField(
                controller: controller.receivingPocCtrl,
                hintText: 'Full name of on-site contact',
                prefixIcon: Icons.person_outline,
                errorText: controller.formErrors['receivingPoc'],
                onChanged: (_) => controller.clearFormError('receivingPoc'),
              )),
              const SizedBox(height: 16),
              _formLabel('Pickup Contact Phone *'),
              const SizedBox(height: 6),
              Obx(() => _formTextField(
                controller: controller.pickupPhoneCtrl,
                prefixIcon: Icons.person_outline,
                errorText: controller.formErrors['pickupPhone'],
                onChanged: (_) => controller.clearFormError('pickupPhone'),
              )),
              const SizedBox(height: 16),
              _formLabel('Special Requirements'),
              const SizedBox(height: 6),
              _formTextField(
                controller: controller.specialRequirementsCtrl,
                hintText:
                    'e.g., Crane unloading required, liftgate needed, fragile...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _formLabel('Additional Notes'),
              const SizedBox(height: 6),
              _formTextField(
                controller: controller.additionalNotesCtrl,
                hintText: 'Any other information for carriers...',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCarrierFilterDialog(BuildContext context) {
    String tempEquipment = controller.selectedFilterEquipment.value;
    String tempRegion = controller.selectedFilterRegion.value;
    int? tempRating = controller.selectedFilterRating.value;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              Widget buildOptionItem({
                required String label,
                required bool isSelected,
                required VoidCallback onTap,
              }) {
                return InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : Colors.transparent,
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: const Color(0xFF3B82F6),
                                    width: 2,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Carrier Filter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Equipment type section
                  const Text(
                    'Equipment type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      buildOptionItem(
                        label: 'Equipment 1',
                        isSelected: tempEquipment == 'Equipment 1',
                        onTap: () {
                          setDialogState(() {
                            tempEquipment = tempEquipment == 'Equipment 1'
                                ? ''
                                : 'Equipment 1';
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      buildOptionItem(
                        label: 'Equipment 2',
                        isSelected: tempEquipment == 'Equipment 2',
                        onTap: () {
                          setDialogState(() {
                            tempEquipment = tempEquipment == 'Equipment 2'
                                ? ''
                                : 'Equipment 2';
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      buildOptionItem(
                        label: 'Equipment 3',
                        isSelected: tempEquipment == 'Equipment 3',
                        onTap: () {
                          setDialogState(() {
                            tempEquipment = tempEquipment == 'Equipment 3'
                                ? ''
                                : 'Equipment 3';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 16),

                  // Region section
                  const Text(
                    'Region',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      buildOptionItem(
                        label: 'Region 1',
                        isSelected: tempRegion == 'Region 1',
                        onTap: () {
                          setDialogState(() {
                            tempRegion =
                                tempRegion == 'Region 1' ? '' : 'Region 1';
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      buildOptionItem(
                        label: 'Region 2',
                        isSelected: tempRegion == 'Region 2',
                        onTap: () {
                          setDialogState(() {
                            tempRegion =
                                tempRegion == 'Region 2' ? '' : 'Region 2';
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      buildOptionItem(
                        label: 'Region 3',
                        isSelected: tempRegion == 'Region 3',
                        onTap: () {
                          setDialogState(() {
                            tempRegion =
                                tempRegion == 'Region 3' ? '' : 'Region 3';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 16),

                  // Rating section
                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [1, 2, 3, 4, 5].map((rating) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: buildOptionItem(
                          label: '$rating',
                          isSelected: tempRating == rating,
                          onTap: () {
                            setDialogState(() {
                              tempRating =
                                  tempRating == rating ? null : rating;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E293B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          controller.applyCarrierFilters(
                            equipment: tempEquipment,
                            region: tempRegion,
                            rating: tempRating,
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3754DB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Apply Filter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _formLabel(String label) {
    if (label.endsWith('*')) {
      final textPart = label.substring(0, label.length - 1);
      return RichText(
        text: TextSpan(
          text: textPart,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          children: const [
            TextSpan(
              text: '*',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      );
    }
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

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
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError ? const Color(0xFFEF4444) : AppColors.inputBorder,
              width: hasError ? 1.2 : 1.0,
            ),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(
                  prefixIcon,
                  size: 16,
                  color: prefixColor ?? AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  onTap: onTap,
                  onChanged: onChanged,
                  maxLines: maxLines,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (suffix != null) ...[
                Text(
                  suffix,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (suffixIcon != null) ...[
                GestureDetector(
                  onTap: onSuffixTap ?? onTap,
                  child: Icon(
                    suffixIcon,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
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
            .map(
              (opt) => PopupMenuItem<String>(
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
              ),
            )
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
                        color: text.isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              Obx(
                () => Icon(
                  isOpen.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // EMAIL QUOTE PREVIEW DIALOG (Gmail style matching screenshot)
  void _showEmailQuoteDialog(BuildContext context) {
    if (!controller.validateFreightForm()) {
      CommonSnackbar.showError(
        title: 'Required fields missing',
        message: 'Please fill in all required fields indicated in red.',
      );
      return;
    }

    final loadDesc = controller.loadDescriptionCtrl.text.trim().isNotEmpty
        ? controller.loadDescriptionCtrl.text.trim()
        : (controller.totalBundlesCount > 0
            ? '${controller.totalBundlesCount} bundle(s) for bundle plan ${controller.displayBundlePlanId.isNotEmpty ? controller.displayBundlePlanId : 'BP-0012'}'
            : (controller.projectName.isNotEmpty ? controller.projectName : 'Load Plan'));

    final projectDisplay = loadDesc;
    final pickupDateDisplay = _formatEmailDate(controller.pickupDateCtrl.text.trim());
    final deliveryDateDisplay = _formatEmailDate(controller.deliveryDateCtrl.text.trim());
    final pocDisplay = controller.receivingPocCtrl.text.trim().isNotEmpty
        ? controller.receivingPocCtrl.text.trim()
        : 'N/A';
    final deliveryLocDisplay = controller.deliveryLocationCtrl.text.trim().isNotEmpty
        ? controller.deliveryLocationCtrl.text.trim()
        : 'N/A';

    final rawWeight = controller.weightCtrl.text.trim();
    String totalWeightDisplay = 'N/A';
    if (rawWeight.isNotEmpty) {
      final numVal = double.tryParse(rawWeight.replaceAll(',', ''));
      if (numVal != null) {
        final parts = numVal.toStringAsFixed(1).split('.');
        final whole = parts[0].replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
        totalWeightDisplay = '$whole.${parts[1]} Lbs';
      } else {
        totalWeightDisplay = '$rawWeight Lbs';
      }
    }

    final rawBundles = controller.palletCountCtrl.text.trim();
    final bundlesDisplay = rawBundles.isNotEmpty ? rawBundles : 'N/A';
    final materialDisplay = controller.materialTypeCtrl.text.trim().isNotEmpty
        ? controller.materialTypeCtrl.text.trim()
        : 'N/A';
    final equipmentDisplay = controller.loadingEquipmentCtrl.text.trim().isNotEmpty
        ? controller.loadingEquipmentCtrl.text.trim()
        : 'Crane';

    final pickupDisplay = controller.pickupLocationCtrl.text.trim().isNotEmpty
        ? controller.pickupLocationCtrl.text.trim()
        : 'Texas, United States';
    final deadlineDisplay = _formatEmailDate(controller.bidDeadlineCtrl.text.trim());

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 660,
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Banner: Gmail icon + Subject
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/icons/ic_gmail.png',
                      width: 44,
                      height: 34,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => _buildGmailFallbackIcon(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Freight Request – $loadDesc | Pickup & Delivery Details',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Metadata list
              _buildEmailMetaRow('Project', projectDisplay),
              _buildEmailMetaRow('Pickup Date', pickupDateDisplay),
              _buildEmailMetaRow('Delivery Date', deliveryDateDisplay),
              _buildEmailMetaRow('POC', pocDisplay),
              _buildEmailMetaRow('Delivery Location', deliveryLocDisplay),

              const SizedBox(height: 16),

              // Two columns: Load Details & Site Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Load Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Load Details:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildEmailBulletItem('Total Weight', totalWeightDisplay),
                        _buildEmailBulletItem('Bundles', bundlesDisplay),
                        _buildEmailBulletItem('Material', materialDisplay),
                        _buildEmailBulletItem('Equipment', equipmentDisplay),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right: Site Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Site Details:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildEmailBulletItem('Pickup', pickupDisplay),
                        _buildEmailBulletItem('Deadline', deadlineDisplay),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Centered Submit Button
              Center(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.submitFreightRequest(isDraft: false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 11),
                    ),
                    child: const Text(
                      'Submit your quote to Carriers',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  String _formatEmailDate(String raw) {
    if (raw.trim().isEmpty) return 'N/A';
    final parsed = controller.parseDateFlexible(raw.trim());
    if (parsed != null) {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
    }
    return raw;
  }

  Widget _buildEmailMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF334155),
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            TextSpan(
              text: value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailBulletItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(
                    text: value.isNotEmpty ? value : 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF475569),
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

  Widget _buildGmailFallbackIcon() {
    return Container(
      width: 44,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: CustomPaint(
        size: const Size(44, 34),
        painter: _GmailEnvelopePainter(),
      ),
    );
  }

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

  Widget _buildEditBundleScreen(BuildContext context, BundleDataModel item) =>
      _BundleEditor(
        key: ValueKey(item.recordId),
        item: item,
        controller: controller,
      );

  void _showQrDialog(BuildContext context, BundleDataModel item) {
    final bundleTargetId =
        item.recordId.isNotEmpty ? item.recordId : item.bundleId;
    final bundleUrl =
        'https://storage-material-vendor-deployment.vercel.app/bundle/$bundleTargetId';
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
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
                    padding: const EdgeInsets.all(6),
                    child: QrImageView(
                      data: bundleUrl,
                      version: QrVersions.auto,
                      size: 128.0,
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
                        _qrDetailRow(
                          'Parts :',
                          'parts=${item.profile.toLowerCase()}',
                        ),
                        _qrDetailRow(
                          'Weight :',
                          'weight=${item.unitWeight.toStringAsFixed(2)}',
                        ),
                        _qrDetailRow(
                          'Length :',
                          'Length=${item.length.replaceAll(' ft', '')}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'URL: $bundleUrl',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                          shipperId: controller.requestId.isNotEmpty
                              ? controller.requestId
                              : '6a85db8f4aba512f82285789',
                          loadId: '4',
                          bundleId: item.bundleId,
                          recordId: item.recordId,
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
                          shipperId: controller.requestId.isNotEmpty
                              ? controller.requestId
                              : '6a85db8f4aba512f82285789',
                          loadId: '4',
                          bundleId: item.bundleId,
                          recordId: item.recordId,
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
    String? recordId,
    required String parts,
    required String weight,
    required String length,
  }) async {
    final pdf = pw.Document();

    final bundleTarget =
        (recordId != null && recordId.isNotEmpty) ? recordId : bundleId;
    final qrData =
        'https://storage-material-vendor-deployment.vercel.app/bundle/$bundleTarget';

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
                border: pw.Border.all(
                  color: PdfColor.fromHex('#E2E8F0'),
                  width: 1.5,
                ),
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
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#E2E8F0'),
                        width: 1,
                      ),
                    ),
                    child: pw.Column(
                      children: [
                        _pdfDetailRowItem('Shipper:', shipperId),
                        pw.SizedBox(height: 4),
                        pw.Divider(
                          color: PdfColor.fromHex('#E2E8F0'),
                          thickness: 0.5,
                        ),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem('Load ID:', loadId),
                        pw.SizedBox(height: 4),
                        pw.Divider(
                          color: PdfColor.fromHex('#E2E8F0'),
                          thickness: 0.5,
                        ),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem('Bundle ID:', bundleId),
                        pw.SizedBox(height: 4),
                        pw.Divider(
                          color: PdfColor.fromHex('#E2E8F0'),
                          thickness: 0.5,
                        ),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem('Parts:', parts),
                        pw.SizedBox(height: 4),
                        pw.Divider(
                          color: PdfColor.fromHex('#E2E8F0'),
                          thickness: 0.5,
                        ),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem(
                          'Weight:',
                          weight.contains('LBS') ? weight : '$weight LBS',
                        ),
                        pw.SizedBox(height: 4),
                        pw.Divider(
                          color: PdfColor.fromHex('#E2E8F0'),
                          thickness: 0.5,
                        ),
                        pw.SizedBox(height: 4),
                        _pdfDetailRowItem(
                          'Length:',
                          length.contains('ft') ? length : '$length ft',
                        ),
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
          style: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#0F172A')),
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
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                idValue,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 32),
              Text(
                '$planLabel  ',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                planValue,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
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
              border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 1),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

class _BundleEditor extends StatefulWidget {
  const _BundleEditor({
    super.key,
    required this.item,
    required this.controller,
  });
  final BundleDataModel item;
  final LoadPlanningWorkflowController controller;
  @override
  State<_BundleEditor> createState() => _BundleEditorState();
}

class _BundleEditorState extends State<_BundleEditor> {
  final formKey = GlobalKey<FormState>();
  late final instructions = TextEditingController(
    text: widget.item.handlingInstructions,
  );
  late final notes = TextEditingController(text: widget.item.notes);
  late final quantities = widget.item.items
      .map((item) => TextEditingController(text: '${item['qty'] ?? 0}'))
      .toList();
  @override
  void dispose() {
    instructions.dispose();
    notes.dispose();
    for (final quantity in quantities) {
      quantity.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: widget.controller.cancelEditBundle,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to bundles'),
        ),
        Text(
          'Edit ${widget.item.bundleId}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        for (var index = 0; index < widget.item.items.length; index++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: quantities[index],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    '${widget.item.items[index]['partCode'] ?? ''} ${widget.item.items[index]['description'] ?? ''} — quantity',
              ),
              validator: (value) => (int.tryParse(value ?? '') ?? -1) < 0
                  ? 'Enter a non-negative whole quantity.'
                  : null,
            ),
          ),
        TextFormField(
          controller: instructions,
          decoration: const InputDecoration(labelText: 'Handling instructions'),
        ),
        TextFormField(
          controller: notes,
          decoration: const InputDecoration(labelText: 'Notes'),
        ),
        const SizedBox(height: 16),
        Obx(
          () => ElevatedButton(
            onPressed: widget.controller.actionLoading.value
                ? null
                : () {
                    if (!formKey.currentState!.validate()) return;
                    final rows = List.generate(
                      widget.item.items.length,
                      (index) => <String, dynamic>{
                        if (widget.item.items[index]['_id'] != null)
                          '_id': widget.item.items[index]['_id'],
                        'vendorQuoteLineId':
                            widget.item.items[index]['vendorQuoteLineId'],
                        'qty': int.parse(quantities[index].text),
                      },
                    );
                    widget.controller.saveBundle(
                      widget.item,
                      rows,
                      instructions.text,
                      notes.text,
                    );
                  },
            child: Text(
              widget.controller.actionLoading.value ? 'Saving…' : 'Save bundle',
            ),
          ),
        ),
      ],
    ),
  );
}

class _GmailEnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, bgPaint);
    canvas.drawRRect(rect, borderPaint);

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(5, size.height - 5);
    path.lineTo(5, 7);
    path.lineTo(size.width / 2, size.height * 0.58);
    path.lineTo(size.width - 5, 7);
    path.lineTo(size.width - 5, size.height - 5);
    canvas.drawPath(path, redPaint);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(5, 7), Offset(5, size.height - 5), bluePaint);

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width - 5, 7), Offset(size.width - 5, size.height - 5), greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
