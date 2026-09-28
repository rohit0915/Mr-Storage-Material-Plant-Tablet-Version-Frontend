import 'dart:async';

import 'package:get/get.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_icons.dart';
import '../model/dashboard_models.dart';
import '../repository/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository repository;

  HomeController({required this.repository});
  StreamSubscription<PlantSocketEvent>? _socketSubscription;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedDrawerItem = 'Dashboard'.obs;
  final RxString selectedTimeFilter = 'today'.obs;

  String get timeFilterLabel {
    switch (selectedTimeFilter.value) {
      case 'today':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
      default:
        return 'This Month';
    }
  }

  void changeTimeFilter(String filter) {
    if (selectedTimeFilter.value != filter) {
      selectedTimeFilter.value = filter;
      loadDashboardData();
    }
  }

  // Rx Data Lists
  final RxList<TopMetricModel> topMetrics = <TopMetricModel>[].obs;
  final RxList<ProductionOverviewModel> productionOverviewItems =
      <ProductionOverviewModel>[].obs;
  final RxList<ShipperFileReceivedModel> shipperFiles =
      <ShipperFileReceivedModel>[].obs;
  final RxList<PlantAlertModel> plantAlerts = <PlantAlertModel>[].obs;
  final RxList<FreightCarrierModel> freightCarriers =
      <FreightCarrierModel>[].obs;
  final RxList<RecentShipperFileCardModel> recentShipperCards =
      <RecentShipperFileCardModel>[].obs;
  final RxList<DrawingApprovalStatusModel> drawingApprovalItems =
      <DrawingApprovalStatusModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor(
        PlantSocketService.plantEvents,
        (_) => loadDashboardData(silent: true),
      );
    }
    loadDashboardData();
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    super.onClose();
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '—';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '—';
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  String _text(dynamic value) => value == null || value.toString().isEmpty
      ? '—' : value.toString();

  String _quantity(dynamic value, String unit) => value == null
      ? '—' : '${value is num ? value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '') : value} $unit';

  List<Map<String, dynamic>> _rows(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return [];
    if (value is! List || value.any((row) => row is! Map)) {
      throw FormatException('Invalid dashboard $key response.');
    }
    return value.map((row) => Map<String, dynamic>.from(row as Map)).toList();
  }

  BadgeStatusType _badge(dynamic status) {
    switch (status) {
      case 'approved': return BadgeStatusType.approved;
      case 'rejected':
      case 'revision_sent': return BadgeStatusType.revisionSent;
      case 'order_sent': return BadgeStatusType.orderSent;
      case 'received': return BadgeStatusType.fileReceived;
      default: return BadgeStatusType.pending;
    }
  }

  void _clearData() {
    topMetrics.clear();
    productionOverviewItems.clear();
    shipperFiles.clear();
    plantAlerts.clear();
    freightCarriers.clear();
    recentShipperCards.clear();
    drawingApprovalItems.clear();
  }

  int _requestVersion = 0;
  Future<void> loadDashboardData({bool silent = false}) async {
    final version = ++_requestVersion;
    if (!silent) isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.fetchDashboard();
      if (version != _requestVersion || isClosed) return;
      final stats = data['stats'];
      if (stats is! Map) throw const FormatException('Invalid dashboard statistics.');
      final production = data['productionOverviewToday'] as Map? ?? {};
      final files = _rows(data, 'recentShipperFiles');
      final alerts = _rows(data, 'plantAlerts');
      final carriers = _rows(data, 'freightCarriers');
      final drawings = _rows(data, 'drawingApprovalStatus');
      topMetrics.assignAll([
        TopMetricModel(title: 'Total Projects', count: _text(stats['totalProjects']), iconAsset: AppIcons.totalProject, backgroundColor: AppColors.totalProjectsCard),
        TopMetricModel(title: 'In Production', count: _text(stats['inProduction']), iconAsset: AppIcons.inProduction, backgroundColor: AppColors.inProductionCard),
        TopMetricModel(title: 'Ready to Dispatch', count: _text(stats['readyToDispatch']), iconAsset: AppIcons.readyToDispatch, backgroundColor: AppColors.readyToDispatchCard),
        TopMetricModel(title: 'Dispatched Today', count: _text(stats['dispatchedToday']), iconAsset: AppIcons.dispatchedToday, backgroundColor: AppColors.dispatchedTodayCard),
        TopMetricModel(title: 'Pending Approval', count: _text(stats['pendingApproval']), iconAsset: AppIcons.pendingApproval, backgroundColor: AppColors.pendingApprovalCard),
      ]);
      productionOverviewItems.assignAll([
        ProductionOverviewModel(iconAsset: AppIcons.plannedTonnage, label: 'Planned Tonnage', value: _quantity(production['plannedTonnage'], 'MT')),
        ProductionOverviewModel(iconAsset: AppIcons.producedTonnage, label: 'Produced Tonnage', value: _quantity(production['producedTonnage'], 'MT')),
        ProductionOverviewModel(iconAsset: AppIcons.utilization, label: 'Utilization', value: _quantity(production['utilizationPct'] ?? production['utilization'], '%')),
        ProductionOverviewModel(iconAsset: AppIcons.onTimeDelivery, label: 'On-Time Delivery', value: _quantity(production['onTimeDeliveryPct'] ?? production['onTimeDelivery'], '%')),
        ProductionOverviewModel(iconAsset: AppIcons.rework, label: 'Rework/Rejection', value: _quantity(production['reworkRejectionPct'] ?? production['reworkRejection'], '%')),
      ]);
      recentShipperCards.assignAll(files.map((row) => RecentShipperFileCardModel(
        projectCode: _text(row['projectId']), title: _text(row['projectName']),
        site: _text(row['vendorName']), fileName: _text(row['fileName']),
        uploadDate: _formatDate(row['uploadDate']?.toString()), items: _text(row['items']),
        rates: row['rate'] == null ? '—' : '\$${row['rate']}',
        weight: _quantity(row['weight'], 'lbs'), status: _text(row['status']).replaceAll('_', ' '),
        statusType: _badge(row['status']),
      )));
      shipperFiles.assignAll(files.map((row) => ShipperFileReceivedModel(
        title: _text(row['projectName']), subtitle: _text(row['fileName']),
        itemCount: _text(row['items']), date: _formatDate(row['uploadDate']?.toString()),
        time: _formatTime(row['uploadDate']?.toString()), iconAsset: AppIcons.pdf,
        iconBgColor: AppColors.badgeBlueBg, iconColor: AppColors.badgeBlueText,
      )));
      plantAlerts.assignAll(alerts.map((row) => PlantAlertModel(
        title: _text(row['message']), timeText: _formatTime(row['occurredAt']?.toString()),
        iconAsset: AppIcons.file, iconBgColor: AppColors.badgeBlueBg, iconColor: AppColors.badgeBlueText,
      )));
      freightCarriers.assignAll(carriers.map((row) => FreightCarrierModel(
        title: _text(row['carrierName']), loadsCount: '${_text(row['loadsToday'])} Loads Today',
        status: _text(row['status']), isOnTime: row['status'] == 'On Time', iconAsset: AppIcons.truckDelivery,
      )));
      drawingApprovalItems.assignAll(drawings.map((row) => DrawingApprovalStatusModel(
        clientName: _text(row['client']), projectName: _text(row['projectName']),
        fileName: _text(row['fileName']), sentDate: _formatDate(row['sentDate']?.toString()),
        status: _text(row['status']).replaceAll('_', ' '), statusType: _badge(row['status']),
        avatarInitial: _text(row['client']).substring(0, 1).toUpperCase(),
      )));
    } catch (error) {
      if (version != _requestVersion || isClosed) return;
      _clearData();
      errorMessage.value = error.toString();
    } finally {
      if (version == _requestVersion && !isClosed) isLoading.value = false;
    }
  }
}
