import 'dart:async';

import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../../app/services/shared_pref_service.dart';
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
  final RxString selectedTimeFilter = 'month'.obs;

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
    selectedTimeFilter.value = filter;
    loadDashboardData();
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
      final socketService = Get.find<PlantSocketService>();
      if (!socketService.isConnected.value) {
        socketService.connect();
      }
      _socketSubscription = socketService.listenFor(
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

  String _cleanId(dynamic value) {
    if (value == null) return '';
    final str = value.toString().trim();
    return (str == '—' || str == '-') ? '' : str;
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
    final currentFilter = selectedTimeFilter.value;
    try {
      final dashboardFuture = repository.fetchDashboard(filter: currentFilter);
      final bomStatsFuture =
          repository.fetchBomStats(filter: currentFilter).catchError((_) => null);
      final shipperStatsFuture = repository
          .fetchShipperFilesStats(filter: currentFilter)
          .catchError((_) => null);
      final deliveriesStatsFuture = repository
          .fetchDeliveriesStats(filter: currentFilter)
          .catchError((_) => null);

      final data = await dashboardFuture;
      if (version != _requestVersion || isClosed) return;

      final bomStats = await bomStatsFuture;
      final shipperStats = await shipperStatsFuture;
      final deliveriesStats = await deliveriesStatsFuture;

      final stats = data['stats'];
      if (stats is! Map) throw const FormatException('Invalid dashboard statistics.');

      final mergedBomStats =
          bomStats ?? (data['bomStats'] as Map<String, dynamic>?);
      final mergedShipperStats =
          shipperStats ?? (data['shipperStats'] as Map<String, dynamic>?);
      final mergedDeliveriesStats =
          deliveriesStats ?? (data['deliveriesStats'] as Map<String, dynamic>?);

      final productionOverviewKey = currentFilter == 'today'
          ? 'productionOverviewToday'
          : (currentFilter == 'week'
              ? 'productionOverviewWeek'
              : 'productionOverviewMonth');
      final production = (data[productionOverviewKey] ??
              data['productionOverview${currentFilter.capitalizeFirst}'] ??
              data['productionOverview'] ??
              data['productionOverviewToday']) as Map? ??
          {};

      final files = _rows(data, 'recentShipperFiles');
      final alerts = _rows(data, 'plantAlerts');
      final carriers = _rows(data, 'freightCarriers');
      final drawings = _rows(data, 'drawingApprovalStatus');

      topMetrics.assignAll([
        TopMetricModel(
          title: 'Total Projects',
          count: _text(stats['totalProjects']),
          iconAsset: AppIcons.totalProject,
          backgroundColor: AppColors.totalProjectsCard,
        ),
        TopMetricModel(
          title: 'In Production',
          count: _text(stats['inProduction']),
          iconAsset: AppIcons.inProduction,
          backgroundColor: AppColors.inProductionCard,
        ),
        TopMetricModel(
          title: 'Ready to Dispatch',
          count: _text(stats['readyToDispatch']),
          iconAsset: AppIcons.readyToDispatch,
          backgroundColor: AppColors.readyToDispatchCard,
        ),
        TopMetricModel(
          title: 'Dispatched Today',
          count: _text(stats['dispatchedToday']),
          iconAsset: AppIcons.dispatchedToday,
          backgroundColor: AppColors.dispatchedTodayCard,
        ),
        TopMetricModel(
          title: 'Pending Approval',
          count: _text(stats['pendingApproval']),
          iconAsset: AppIcons.pendingApproval,
          backgroundColor: AppColors.pendingApprovalCard,
        ),
      ]);

      final totalBomFiles = mergedBomStats?['totalBomFilesUploaded'] ??
          mergedBomStats?['totalBomFiles'] ??
          mergedBomStats?['totalProjects'] ??
          mergedBomStats?['total'];
      final readyForShipper = mergedBomStats?['readyForShipper'] ??
          mergedBomStats?['readyForReview'] ??
          mergedBomStats?['ready'];
      final shipperOrders = mergedShipperStats?['ordersSent'] ??
          mergedShipperStats?['approved'] ??
          mergedShipperStats?['totalSent'];
      final totalDeliveries = mergedDeliveriesStats?['totalCount'] ??
          mergedDeliveriesStats?['total'] ??
          mergedDeliveriesStats?['count'];
      final issuesDetected = mergedBomStats?['issuesDetected'] ??
          mergedBomStats?['issues'] ??
          0;

      if (totalBomFiles != null ||
          readyForShipper != null ||
          shipperOrders != null ||
          totalDeliveries != null) {
        productionOverviewItems.assignAll([
          ProductionOverviewModel(
            iconAsset: AppIcons.plannedTonnage,
            label: 'BOM Uploads',
            value: '${totalBomFiles ?? 0} Files',
          ),
          ProductionOverviewModel(
            iconAsset: AppIcons.producedTonnage,
            label: 'Ready for Shipper',
            value: '${readyForShipper ?? 0} Items',
          ),
          ProductionOverviewModel(
            iconAsset: AppIcons.utilization,
            label: 'Shipper Orders',
            value: '${shipperOrders ?? 0} Sent',
          ),
          ProductionOverviewModel(
            iconAsset: AppIcons.onTimeDelivery,
            label: 'Total Deliveries',
            value: '${totalDeliveries ?? 0} Loads',
          ),
          ProductionOverviewModel(
            iconAsset: AppIcons.rework,
            label: 'Issues Detected',
            value: '$issuesDetected',
          ),
        ]);
      } else {
        productionOverviewItems.assignAll([
          ProductionOverviewModel(
            iconAsset: AppIcons.plannedTonnage,
            label: 'Planned Tonnage',
            value: _quantity(production['plannedTonnage'], 'MT'),
          ),
          ProductionOverviewModel(
            iconAsset: AppIcons.producedTonnage,
            label: 'Produced Tonnage',
            value: _quantity(production['producedTonnage'], 'MT'),
          ),
          ProductionOverviewModel(
            iconAsset: AppIcons.utilization,
            label: 'Utilization',
            value: _quantity(
              production['utilizationPct'] ?? production['utilization'],
              '%',
            ),
          ),
          ProductionOverviewModel(
            iconAsset: AppIcons.onTimeDelivery,
            label: 'On-Time Delivery',
            value: _quantity(
              production['onTimeDeliveryPct'] ?? production['onTimeDelivery'],
              '%',
            ),
          ),
          ProductionOverviewModel(
            iconAsset: AppIcons.rework,
            label: 'Rework/Rejection',
            value: _quantity(
              production['reworkRejectionPct'] ?? production['reworkRejection'],
              '%',
            ),
          ),
        ]);
      }

      final fileByFileName = <String, Map<String, dynamic>>{};
      final fileByProjectName = <String, Map<String, dynamic>>{};
      for (final f in files) {
        final fName = (f['fileName'] ?? '').toString().trim().toLowerCase();
        if (fName.isNotEmpty) {
          fileByFileName[fName] = f;
        }
        final pName = (f['projectName'] ?? '').toString().trim().toLowerCase();
        if (pName.isNotEmpty) {
          fileByProjectName[pName] = f;
        }
      }

      recentShipperCards.assignAll(files.map((row) => RecentShipperFileCardModel(
        requestId: _cleanId(row['requestId'] ?? row['_id'] ?? row['id']),
        projectCode: _text(row['projectId']),
        title: _text(row['projectName']),
        site: _text(row['vendorName']),
        fileName: _text(row['fileName']),
        uploadDate: _formatDate(row['uploadDate']?.toString()),
        items: _text(row['items']),
        rates: row['rate'] == null ? '—' : '\$${row['rate']}',
        weight: _quantity(row['weight'], 'lbs'),
        status: _text(row['status']).replaceAll('_', ' '),
        statusType: _badge(row['status']),
      )));
      shipperFiles.assignAll(files.map((row) => ShipperFileReceivedModel(
        title: _text(row['projectName']),
        subtitle: _text(row['fileName']),
        itemCount: _text(row['items']),
        date: _formatDate(row['uploadDate']?.toString()),
        time: _formatTime(row['uploadDate']?.toString()),
        iconAsset: AppIcons.pdf,
        iconBgColor: AppColors.badgeBlueBg,
        iconColor: AppColors.badgeBlueText,
      )));
      plantAlerts.assignAll(alerts.map((row) => PlantAlertModel(
        title: _text(row['message']),
        timeText: _formatTime(row['occurredAt']?.toString()),
        iconAsset: AppIcons.file,
        iconBgColor: AppColors.badgeBlueBg,
        iconColor: AppColors.badgeBlueText,
      )));
      if (carriers.isNotEmpty) {
        freightCarriers.assignAll(carriers.map((row) => FreightCarrierModel(
          title: _text(row['carrierName']),
          loadsCount: '${_text(row['loadsToday'])} Loads Today',
          status: _text(row['status']),
          isOnTime: row['status'] == 'On Time',
          iconAsset: AppIcons.truckDelivery,
        )));
      } else if (mergedDeliveriesStats != null &&
          (mergedDeliveriesStats['totalCount'] != null ||
              mergedDeliveriesStats['scheduledCount'] != null)) {
        final totalLoads = mergedDeliveriesStats['totalCount'] ?? 0;
        final scheduledLoads = mergedDeliveriesStats['scheduledCount'] ?? 0;
        final inTransitLoads = mergedDeliveriesStats['inTransitCount'] ?? 0;
        final deliveredLoads = mergedDeliveriesStats['deliveredCount'] ?? 0;
        freightCarriers.assignAll([
          FreightCarrierModel(
            title: 'Active Freight Shipments',
            loadsCount: '$totalLoads Total Loads',
            status: inTransitLoads > 0 ? 'In Transit ($inTransitLoads)' : 'Active',
            isOnTime: true,
            iconAsset: AppIcons.roadkingLogistics,
          ),
          FreightCarrierModel(
            title: 'Scheduled Dispatches',
            loadsCount: '$scheduledLoads Scheduled',
            status: 'Scheduled',
            isOnTime: true,
            iconAsset: AppIcons.swiftTransport,
          ),
          FreightCarrierModel(
            title: 'Delivered Orders',
            loadsCount: '$deliveredLoads Delivered',
            status: 'Delivered',
            isOnTime: true,
            iconAsset: AppIcons.globalFreightLines,
          ),
        ]);
      } else {
        freightCarriers.clear();
      }
      drawingApprovalItems.assignAll(drawings.map((row) {
        final client = _text(row['client']);
        final projName = _text(row['projectName']);
        final fName = _text(row['fileName']);
        final statusVal = _text(row['status']);

        final match = fileByFileName[fName.toLowerCase()] ??
            fileByProjectName[projName.toLowerCase()] ??
            fileByProjectName[client.toLowerCase()];

        final reqId = _cleanId(
            row['requestId'] ?? match?['requestId'] ?? match?['_id'] ?? match?['id']);
        final projId = _cleanId(row['projectId'] ?? match?['projectId']);
        final bId = _cleanId(row['buildingId']);

        return DrawingApprovalStatusModel(
          clientName: client,
          projectName: projName,
          fileName: fName,
          sentDate: _formatDate(row['sentDate']?.toString()),
          status: statusVal.replaceAll('_', ' '),
          statusType: _badge(row['status']),
          avatarInitial: client.isNotEmpty && client != '—'
              ? client.substring(0, 1).toUpperCase()
              : 'P',
          requestId: reqId,
          projectId: projId,
          buildingId: bId,
        );
      }));
    } catch (error) {
      if (version != _requestVersion || isClosed) return;
      _clearData();
      errorMessage.value = error.toString();
    } finally {
      if (version == _requestVersion && !isClosed) isLoading.value = false;
    }
  }

  Future<void> openShipperFileDetails({
    String? requestId,
    String? projectName,
    String? clientName,
    String? projectId,
    String? buildingId,
    String? fileName,
  }) async {
    String directId = (requestId ?? '').trim();
    final pName = (projectName ?? '').trim().toLowerCase();
    final cName = (clientName ?? '').trim().toLowerCase();
    final pCode = (projectId ?? '').trim().toLowerCase();
    final fName = (fileName ?? '').trim().toLowerCase();

    if (directId.isEmpty) {

      for (final card in recentShipperCards) {
        if (card.requestId.trim().isEmpty) continue;
        if (fName.isNotEmpty && card.fileName.trim().toLowerCase() == fName) {
          directId = card.requestId.trim();
          break;
        }
        if (pCode.isNotEmpty && card.projectCode.trim().toLowerCase() == pCode) {
          directId = card.requestId.trim();
          break;
        }
        if (pName.isNotEmpty && card.title.trim().toLowerCase() == pName) {
          directId = card.requestId.trim();
          break;
        }
        if (cName.isNotEmpty && card.site.trim().toLowerCase() == cName) {
          directId = card.requestId.trim();
          break;
        }
      }
    }

    if (directId.isEmpty) {
      try {
        final projects = await repository.fetchShipperProjects();
        Map<String, dynamic>? matchedProject;
        for (final p in projects) {
          final projName = (p['projectName'] ?? '').toString().trim().toLowerCase();
          final custName = (p['customerName'] ?? '').toString().trim().toLowerCase();
          final projCode = (p['projectId'] ?? p['jobId'] ?? '').toString().trim().toLowerCase();

          if (pCode.isNotEmpty && projCode == pCode) {
            matchedProject = p;
            break;
          }
          if (pName.isNotEmpty &&
              (projName == pName || projName.contains(pName) || pName.contains(projName))) {
            matchedProject = p;
            break;
          }
          if (cName.isNotEmpty &&
              (custName == cName || custName.contains(cName) || cName.contains(custName))) {
            matchedProject = p;
            break;
          }
        }

        if (matchedProject != null) {
          final leadId = (matchedProject['leadId'] ?? '').toString().trim();
          if (leadId.isNotEmpty) {
            final requests = await repository.fetchProjectShipperRequests(leadId);
            if (requests.isNotEmpty) {
              directId = (requests.first['requestId'] ?? requests.first['_id'] ?? '').toString().trim();
            }
          }
        }
      } catch (_) {}
    }

    if (directId.isNotEmpty) {
      if (Get.isRegistered<SharedPrefService>()) {
        Get.find<SharedPrefService>().setLastShipperRequestId(directId);
      }
      Get.toNamed(
        AppRoutes.shipperFileDetails,
        parameters: {'id': directId},
      );
      return;
    }

    Get.toNamed(AppRoutes.shipperFiles);
  }
}
