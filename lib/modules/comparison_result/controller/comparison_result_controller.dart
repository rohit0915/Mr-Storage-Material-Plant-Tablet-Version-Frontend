import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/file_export_service.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';
import '../model/comparison_result_model.dart';

class ComparisonResultController extends GetxController {
  final ShipperRequestWorkflowRepository repository;
  ComparisonResultController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxList<ComparisonResultItemModel> comparisonItems =
      <ComparisonResultItemModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString requestId = ''.obs;
  final RxInt matched = 0.obs;
  final RxInt unmatched = 0.obs;
  final RxBool canProceedToApproval = false.obs;

  @override
  void onInit() {
    super.onInit();
    requestId.value = Get.parameters['id'] ?? '';
    loadComparisonData();
  }

  Future<void> loadComparisonData() async {
    if (requestId.value.isEmpty) return;
    isLoading.value = true;
    try {
      final data = await Future.wait([
        repository.comparisonSummary(requestId.value),
        repository.comparisonResults(requestId.value),
      ]);
      final summary = data[0];
      final results = data[1];
      matched.value = _int(summary['matched']);
      unmatched.value = _int(summary['unmatched']);
      canProceedToApproval.value = summary['canProceedToApproval'] == true;
      final raw = results['results'] ?? summary['items'];
      final items = raw is List ? raw : const [];
      comparisonItems.assignAll(
        items.whereType<Map>().map(
          (item) => ComparisonResultItemModel(
            partNumber: (item['partNumber'] ?? item['itemCode'] ?? '')
                .toString(),
            description: (item['description'] ?? '').toString(),
            orderedQty: (item['orderedQty'] ?? item['bomQuantity'] ?? 0)
                .toString(),
            shippedQty: (item['shippedQty'] ?? item['shipperQuantity'] ?? 0)
                .toString(),
            difference: (item['difference'] ?? 0).toString(),
            reason: (item['reason'] ?? item['category'] ?? '').toString(),
          ),
        ),
      );
    } catch (error) {
      Get.snackbar('Unable to load comparison', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendReportToShippers() async {
    if (requestId.value.isEmpty) return;
    isLoading.value = true;
    try {
      if (!canProceedToApproval.value) {
        await repository.requestResubmit(
          requestId.value,
          note: 'Please resolve comparison exceptions and resubmit.',
        );
        Get.snackbar(
          'Revision requested',
          'The shipper was asked to resubmit.',
        );
        return;
      }
      await repository.approve(requestId.value);
      final bundle = await repository.generateBundlePlan(requestId.value);
      Get.toNamed(
        AppRoutes.generateShipperOrder,
        parameters: {
          'id': requestId.value,
          'bundlePlanId': (bundle['bundlePlanId'] ?? '').toString(),
        },
      );
    } catch (error) {
      Get.snackbar('Unable to continue', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadExcelReport() async {
    try {
      await FileExportService.saveCsv(
        fileName:
            'comparison_report_${requestId.value.isEmpty ? 'export' : requestId.value}',
        rows: [
          const [
            'Part Number',
            'Description',
            'Ordered Qty',
            'Shipped Qty',
            'Difference',
            'Reason',
          ],
          ...comparisonItems.map(
            (item) => [
              item.partNumber,
              item.description,
              item.orderedQty,
              item.shippedQty,
              item.difference,
              item.reason,
            ],
          ),
        ],
      );
      Get.snackbar(
        'Report downloaded',
        'Comparison CSV was created successfully.',
        backgroundColor: const Color(0xFF2563EB),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (error) {
      Get.snackbar('Download failed', error.toString());
    }
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
