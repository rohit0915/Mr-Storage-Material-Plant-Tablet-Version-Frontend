import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../model/freight_loads_model.dart';
import '../widgets/award_load_dialog.dart';
import '../widgets/request_revision_dialog.dart';

class FreightLoadsController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<FreightLoadSummaryStatModel> summaryStats = <FreightLoadSummaryStatModel>[].obs;
  final RxList<FreightLoadItemModel> freightLoadsList = <FreightLoadItemModel>[].obs;
  final RxList<CarrierBidModel> carrierBidsList = <CarrierBidModel>[].obs;

  final RxInt selectedDetailsTabIndex = 1.obs; // 0: Bid Comparison, 1: Request Details, 2: Email Exchange
  final RxString selectedLoadId = 'FRQ-2001'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSummaryStats();
    loadFreightLoadsData();
    loadCarrierBidsData();
  }

  void loadSummaryStats() {
    summaryStats.assignAll([
      FreightLoadSummaryStatModel(
        label: 'Total Awarded',
        value: '4',
        themeColor: const Color(0xFF22C55E),
        icon: Icons.workspace_premium_outlined,
      ),
      FreightLoadSummaryStatModel(
        label: 'In Transit',
        value: '1',
        themeColor: const Color(0xFFF97316),
        icon: Icons.local_shipping_outlined,
      ),
      FreightLoadSummaryStatModel(
        label: 'Delivered',
        value: '1',
        themeColor: const Color(0xFF22C55E),
        icon: Icons.check_circle_outline,
      ),
      FreightLoadSummaryStatModel(
        label: 'Total Spent',
        value: r'$7,650',
        themeColor: const Color(0xFF2563EB),
        icon: Icons.attach_money,
      ),
      FreightLoadSummaryStatModel(
        label: 'Requested Loads',
        value: '4',
        themeColor: const Color(0xFFEC4899),
        icon: Icons.local_shipping_outlined,
      ),
      FreightLoadSummaryStatModel(
        label: 'Bids Pending',
        value: '0',
        themeColor: const Color(0xFF3B82F6),
        icon: Icons.info_outline,
      ),
    ]);
  }

  void loadFreightLoadsData() {
    isLoading.value = true;
    freightLoadsList.assignAll([
      FreightLoadItemModel(
        requestId: 'LOAD-002',
        requestedDate: '2024-03-16',
        project: 'Storage Facility B',
        description: 'Roll-up door panels',
        routeFrom: 'Dallas, TX',
        routeTo: 'San Antonio, TX',
        pickupDate: '2024-03-27',
        deliveryDate: '2024-03-28',
        bids: r'$12000',
        status: 'Awarded',
      ),
      FreightLoadItemModel(
        requestId: 'LOAD-005',
        requestedDate: '2024-03-16',
        project: 'Industrial Complex A',
        description: 'Secondary steel beams',
        routeFrom: 'Houston, TX',
        routeTo: 'Austin, TX',
        pickupDate: '2024-03-28',
        deliveryDate: '2024-03-29',
        bids: r'$12000',
        status: 'Requested',
      ),
      FreightLoadItemModel(
        requestId: 'LOAD-007',
        requestedDate: '2024-03-16',
        project: 'Warehouse Complex',
        description: 'Electrical fixtures - bulk',
        routeFrom: 'San Antonio, TX',
        routeTo: 'Fort Worth, TX',
        pickupDate: '2024-03-30',
        deliveryDate: '2024-03-31',
        bids: r'$12000',
        status: 'Bids Received',
      ),
      FreightLoadItemModel(
        requestId: 'LOAD-006',
        requestedDate: '2024-03-16',
        project: 'Storage Project C',
        description: 'Insulation materials',
        routeFrom: 'Dallas, TX',
        routeTo: 'Houston, TX',
        pickupDate: '2024-03-22',
        deliveryDate: '2024-03-23',
        bids: r'$12000',
        status: 'Requested',
      ),
      FreightLoadItemModel(
        requestId: 'LOAD-006',
        requestedDate: '2024-03-16',
        project: 'Storage Project C',
        description: 'Insulation materials',
        routeFrom: 'Dallas, TX',
        routeTo: 'Houston, TX',
        pickupDate: '2024-03-22',
        deliveryDate: '2024-03-23',
        bids: r'$12000',
        status: 'Requested',
      ),
    ]);
    isLoading.value = false;
  }

  void loadCarrierBidsData() {
    carrierBidsList.assignAll([
      CarrierBidModel(
        carrierName: 'QuickFreight Solutions',
        rating: 4.8,
        bidAmount: r'$2,850',
        isBestRate: true,
      ),
      CarrierBidModel(
        carrierName: 'Apex Logistics Inc',
        rating: 4.6,
        bidAmount: r'$3,050',
      ),
      CarrierBidModel(
        carrierName: 'TransEast Express',
        rating: 4.9,
        bidAmount: r'$3,120',
      ),
      CarrierBidModel(
        carrierName: 'National Haulers',
        rating: 4.5,
        bidAmount: r'$3,300',
      ),
      CarrierBidModel(
        carrierName: 'LoneStar Transport',
        rating: 4.7,
        bidAmount: r'$3,450',
      ),
    ]);
  }

  void openFreightRequestDetails(FreightLoadItemModel item) {
    selectedLoadId.value = item.requestId;
    Get.toNamed(AppRoutes.freightRequestDetails);
  }

  void showAwardLoadDialog([CarrierBidModel? carrier]) {
    Get.dialog(
      AwardLoadDialog(
        carrierName: carrier?.carrierName ?? 'QuickFreight Solutions',
        awardAmount: carrier?.bidAmount ?? r'$2,850',
      ),
      barrierDismissible: true,
    );
  }

  void showRequestRevisionDialog([CarrierBidModel? carrier]) {
    Get.dialog(
      RequestRevisionDialog(
        carrierName: carrier?.carrierName ?? 'QuickFreight Solutions',
        currentBidAmount: carrier?.bidAmount ?? r'$2,850',
      ),
      barrierDismissible: true,
    );
  }
}
