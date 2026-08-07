import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../model/comparison_result_model.dart';

class ComparisonResultController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<ComparisonResultItemModel> comparisonItems = <ComparisonResultItemModel>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadComparisonData();
  }

  void loadComparisonData() {
    isLoading.value = true;
    comparisonItems.assignAll([
      ComparisonResultItemModel(
        partNumber: 'ML6CH',
        description: "Panel,Charcoal,26,Mloc,Prime Lifetime,Leg 1 Pieces @ 36' 3.25\"",
        orderedQty: '36.2708',
        shippedQty: '36.2708',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: '#1',
        description: '1/4"-14 x 1" Driller 5/16 " Hex Washer Head',
        orderedQty: '20000.0000',
        shippedQty: '0.0000',
        difference: '552.0835',
        reason: 'Part found in...',
      ),
      ComparisonResultItemModel(
        partNumber: '#11',
        description: '1/4" x 1 1/4" Nail Drive Masonry Anchor',
        orderedQty: '552.0835',
        shippedQty: '0.0000',
        difference: '35250.0000',
        reason: 'Part found in...',
      ),
      ComparisonResultItemModel(
        partNumber: '#12A',
        description: '12 x 1" Pancake Head Driller',
        orderedQty: '20000.0000',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: '#14',
        description: '1/8" x 0.337" Pop Rivet',
        orderedQty: '552.0835',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: '#14A',
        description: '1/8" x 0.525" Pop Rivet',
        orderedQty: '20000.0000',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: '#1B',
        description: '1/4"-14 x 1 1/4" Driller 5/16 " Hex Washer Head',
        orderedQty: '552.0835',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: "'60_VRR72'",
        description: "Panel,Charcoal,26,Mloc,Prime Lifetime,Leg 1 Pieces @ 36' 3.25\"",
        orderedQty: '20000.0000',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: "'30_UF48 '",
        description: '1/4"-14 x 1" Driller 5/16 " Hex Washer Head',
        orderedQty: '552.0835',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: "'30_UF72 '",
        description: '1/4" x 1 1/4" Nail Drive Masonry Anchor',
        orderedQty: '20000.0000',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: "'35_UF48 '",
        description: '12 x 1" Pancake Head Driller',
        orderedQty: '552.0835',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: "'35_UF72 '",
        description: '1/8" x 0.337" Pop Rivet',
        orderedQty: '20000.0000',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: "'40_UF48 '",
        description: '1/8" x 0.525" Pop Rivet',
        orderedQty: '552.0835',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
      ComparisonResultItemModel(
        partNumber: "'40_UF72 '",
        description: '1/4"-14 x 1 1/4" Driller 5/16 " Hex Washer Head',
        orderedQty: '20000.0000',
        shippedQty: '0.0000',
        difference: '0.0000',
        reason: '',
      ),
    ]);
    isLoading.value = false;
  }

  void sendReportToShippers() {
    Get.toNamed(AppRoutes.generateShipperOrder);
  }

  void downloadExcelReport() {
    Get.snackbar(
      'Download Report',
      'Comparison Excel report downloaded successfully.',
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
