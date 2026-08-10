import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../freight_loads/model/freight_loads_model.dart';
import '../model/awarded_loads_model.dart';
import '../widgets/freight_filter_dialog.dart';

class AwardedLoadsController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<FreightLoadSummaryStatModel> summaryStats = <FreightLoadSummaryStatModel>[].obs;
  final RxList<AwardedLoadItemModel> awardedLoadsList = <AwardedLoadItemModel>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSummaryStats();
    loadAwardedLoadsData();
  }

  void loadSummaryStats() {
    summaryStats.assignAll([
      FreightLoadSummaryStatModel(
        label: 'Total Awarded',
        value: '4',
        themeColor: const Color(0xFF16A34A),
        icon: Icons.workspace_premium_outlined,
      ),
      FreightLoadSummaryStatModel(
        label: 'In Transit',
        value: '1',
        themeColor: const Color(0xFFEA580C),
        icon: Icons.local_shipping_outlined,
      ),
      FreightLoadSummaryStatModel(
        label: 'Delivered',
        value: '1',
        themeColor: const Color(0xFF16A34A),
        icon: Icons.check_circle_outline,
      ),
      FreightLoadSummaryStatModel(
        label: 'Total Spent',
        value: r'$7,650',
        themeColor: const Color(0xFF2563EB),
        icon: Icons.attach_money,
      ),
    ]);
  }

  void loadAwardedLoadsData() {
    isLoading.value = true;
    awardedLoadsList.assignAll([
      AwardedLoadItemModel(
        requestId: 'LOAD-002',
        requestedDate: '2024-03-16',
        subStatus: 'Scheduled',
        project: 'Storage Facility B',
        description: 'Roll-up door panels',
        pickupLocation: 'Dallas, TX',
        deliveryLocation: 'San Antonio, TX',
        pickupDate: '2024-03-27',
        deliveryDate: '2024-03-28',
        carrierName: 'Quick Haul Transport',
        carrierPhone: '(555) 222-3333',
        budget: r'$1,850',
        awardedAmount: r'$1,850',
        bidsCount: 3,
        status: 'Awarded',
      ),
      AwardedLoadItemModel(
        requestId: 'LOAD-005',
        requestedDate: '2024-03-16',
        subStatus: 'In Transit',
        project: 'Industrial Complex A',
        description: 'Secondary steel beams',
        pickupLocation: 'Houston, TX',
        deliveryLocation: 'Austin, TX',
        pickupDate: '2024-03-28',
        deliveryDate: '2024-03-29',
        carrierName: 'Fast Freight LLC',
        carrierPhone: '(555) 222-3333',
        budget: r'$1,850',
        awardedAmount: r'$1,850',
        bidsCount: 3,
        status: 'Awarded',
      ),
      AwardedLoadItemModel(
        requestId: 'LOAD-007',
        requestedDate: '2024-03-16',
        subStatus: 'In Transit',
        project: 'Warehouse Complex',
        description: 'Electrical fixtures - bulk',
        pickupLocation: 'San Antonio, TX',
        deliveryLocation: 'Fort Worth, TX',
        pickupDate: '2024-03-30',
        deliveryDate: '2024-03-31',
        carrierName: 'Regional Logistics',
        carrierPhone: '(555) 222-3333',
        budget: r'$1,850',
        awardedAmount: r'$1,850',
        bidsCount: 3,
        status: 'Awarded',
      ),
      AwardedLoadItemModel(
        requestId: 'LOAD-006',
        requestedDate: '2024-03-16',
        subStatus: 'Delivered',
        project: 'Storage Project C',
        description: 'Insulation materials',
        pickupLocation: 'Dallas, TX',
        deliveryLocation: 'Houston, TX',
        pickupDate: '2024-03-22',
        deliveryDate: '2024-03-23',
        carrierName: 'Quick Haul Transport',
        carrierPhone: '(555) 222-3333',
        budget: r'$1,850',
        awardedAmount: r'$1,850',
        bidsCount: 3,
        status: 'Awarded',
      ),
      AwardedLoadItemModel(
        requestId: 'LOAD-006',
        requestedDate: '2024-03-16',
        subStatus: 'Delivered',
        project: 'Storage Project C',
        description: 'Insulation materials',
        pickupLocation: 'Houston, TX',
        deliveryLocation: 'Dallas, TX',
        pickupDate: '2024-03-22',
        deliveryDate: '2024-03-23',
        carrierName: 'Quick Haul Transport',
        carrierPhone: '(555) 222-3333',
        budget: r'$1,850',
        awardedAmount: r'$1,850',
        bidsCount: 3,
        status: 'Awarded',
      ),
    ]);
    isLoading.value = false;
  }

  void openFreightRequestDetails(AwardedLoadItemModel item) {
    Get.toNamed(AppRoutes.freightRequestDetails);
  }

  void showFilterDialog() {
    Get.dialog(
      const FreightFilterDialog(),
      barrierDismissible: true,
    );
  }
}
