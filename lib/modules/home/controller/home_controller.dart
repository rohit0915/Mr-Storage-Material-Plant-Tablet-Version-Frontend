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
    if (isoString == null || isoString.isEmpty) return 'Recent';
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
      return 'Recent';
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

  Future<void> loadDashboardData({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = '';

    final currentFilter = selectedTimeFilter.value;

    try {
      final results = await Future.wait([
        repository.fetchProjectStats(filter: currentFilter),
        repository.fetchProjects(filter: currentFilter),
        repository.fetchShipperFilesStats(filter: currentFilter),
        repository.fetchBomStats(filter: currentFilter),
        repository.fetchDeliveriesStats(filter: currentFilter),
        repository.fetchNotifications(),
      ]);

      final projectStats = results[0];
      final projectsData = results[1];
      final shipperStats = results[2];
      final bomStats = results[3];
      final deliveriesStats = results[4];
      final notificationsData = results[5];

      // 1. Top Metrics
      final totalPrj =
          projectStats?['totalProjects'] ?? projectsData?['total'] ?? 0;
      final activePrj = projectStats?['activeProjects'] ?? 0;
      final pendingAppr = projectStats?['pendingCustomerApproval'] ?? 0;
      final readyDispatch =
          deliveriesStats?['scheduledCount'] ??
          (shipperStats?['ordersSent'] ?? 0);
      final dispatched =
          deliveriesStats?['deliveredCount'] ??
          (bomStats?['readyForShipper'] ?? 0);

      topMetrics.assignAll([
        TopMetricModel(
          title: 'Total Projects',
          count: totalPrj.toString().padLeft(2, '0'),
          iconAsset: AppIcons.totalProject,
          backgroundColor: AppColors.totalProjectsCard,
        ),
        TopMetricModel(
          title: 'In Production',
          count: activePrj.toString().padLeft(2, '0'),
          iconAsset: AppIcons.inProduction,
          backgroundColor: AppColors.inProductionCard,
        ),
        TopMetricModel(
          title: 'Ready to Dispatch',
          count: readyDispatch.toString().padLeft(2, '0'),
          iconAsset: AppIcons.readyToDispatch,
          backgroundColor: AppColors.readyToDispatchCard,
        ),
        TopMetricModel(
          title: 'Dispatched Today',
          count: dispatched.toString().padLeft(2, '0'),
          iconAsset: AppIcons.dispatchedToday,
          backgroundColor: AppColors.dispatchedTodayCard,
        ),
        TopMetricModel(
          title: 'Pending Approval',
          count: pendingAppr.toString().padLeft(2, '0'),
          iconAsset: AppIcons.pendingApproval,
          backgroundColor: AppColors.pendingApprovalCard,
        ),
      ]);

      // 2. Production Overview (Dynamic metrics from stats)
      productionOverviewItems.assignAll([
        ProductionOverviewModel(
          iconAsset: AppIcons.plannedTonnage,
          label: 'BOM Uploads',
          value: '${bomStats?['totalBomFilesUploaded'] ?? 0} Files',
        ),
        ProductionOverviewModel(
          iconAsset: AppIcons.producedTonnage,
          label: 'Ready for Shipper',
          value: '${bomStats?['readyForShipper'] ?? 0} Items',
        ),
        ProductionOverviewModel(
          iconAsset: AppIcons.utilization,
          label: 'Shipper Orders',
          value: '${shipperStats?['ordersSent'] ?? 0} Sent',
        ),
        ProductionOverviewModel(
          iconAsset: AppIcons.onTimeDelivery,
          label: 'Total Deliveries',
          value: '${deliveriesStats?['totalCount'] ?? 0} Loads',
        ),
        ProductionOverviewModel(
          iconAsset: AppIcons.rework,
          label: 'Issues Detected',
          value: '${bomStats?['issuesDetected'] ?? 0}',
        ),
      ]);

      // 3. Projects list mapping to Recent Shipper Cards, Drawing Approval Items, & Shipper Files
      if (projectsData != null && projectsData['projects'] is List) {
        final List list = projectsData['projects'];

        // Recent Shipper Cards
        final mappedCards = list.map((item) {
          final jobId = (item['jobId'] ?? item['projectId'] ?? 'PRJ-000')
              .toString();
          final name = (item['projectName'] ?? 'Project').toString();
          final loc = (item['location'] ?? 'Site').toString();
          final drawingStatus = (item['drawingStatus'] ?? 'pending').toString();
          final quoteVal = item['quoteValue'] != null
              ? '\$${item['quoteValue']}'
              : '\$0';
          final dateStr = _formatDate(item['createdAt']);

          BadgeStatusType statusType;
          if (drawingStatus == 'approved') {
            statusType = BadgeStatusType.approved;
          } else if (drawingStatus == 'pending') {
            statusType = BadgeStatusType.pending;
          } else if (drawingStatus == 'rejected') {
            statusType = BadgeStatusType.revisionSent;
          } else {
            statusType = BadgeStatusType.fileReceived;
          }

          return RecentShipperFileCardModel(
            projectCode: jobId,
            title: name,
            site: loc,
            fileName: 'SHP-FILE',
            uploadDate: dateStr,
            items: 'BOM: ${item['bomStatus'] ?? 'none'}',
            rates: quoteVal,
            weight: '${item['numberOfBuildings'] ?? 1} bldg',
            status: drawingStatus.toUpperCase(),
            statusType: statusType,
          );
        }).toList();
        recentShipperCards.assignAll(mappedCards);

        // Drawing Approval Items
        final mappedDrawings = list.map((item) {
          final clientName =
              (item['clientName'] ?? item['customer']?['firstName'] ?? 'Client')
                  .toString();
          final projectName = (item['projectName'] ?? 'Project').toString();
          final drawingStatus = (item['drawingStatus'] ?? 'pending').toString();
          final dateStr = _formatDate(item['createdAt']);

          BadgeStatusType statusType;
          String statusText;
          if (drawingStatus == 'approved') {
            statusType = BadgeStatusType.approved;
            statusText = 'Approved';
          } else if (drawingStatus == 'pending') {
            statusType = BadgeStatusType.pending;
            statusText = 'Pending';
          } else if (drawingStatus == 'rejected') {
            statusType = BadgeStatusType.revisionSent;
            statusText = 'Revision Sent';
          } else {
            statusType = BadgeStatusType.pending;
            statusText = drawingStatus.capitalizeFirst ?? 'Pending';
          }

          return DrawingApprovalStatusModel(
            clientName: clientName,
            projectName: projectName,
            fileName: 'Drawing (${item['jobId'] ?? ''})',
            sentDate: dateStr,
            status: statusText,
            statusType: statusType,
            avatarInitial: clientName.isNotEmpty
                ? clientName[0].toUpperCase()
                : 'C',
          );
        }).toList();
        drawingApprovalItems.assignAll(mappedDrawings);

        // Shipper Files Received Column
        final mappedShippers = list.map((item) {
          final projectName = (item['projectName'] ?? 'Project').toString();
          final jobId = (item['jobId'] ?? item['projectId'] ?? '').toString();
          final clientName = (item['clientName'] ?? 'Client').toString();
          final dateStr = _formatDate(item['createdAt']);
          final timeStr = _formatTime(item['createdAt']);

          return ShipperFileReceivedModel(
            title: projectName,
            subtitle: '$jobId | $clientName',
            itemCount: '${item['numberOfBuildings'] ?? 1} Buildings',
            date: dateStr,
            time: timeStr.isNotEmpty ? timeStr : 'Today',
            iconAsset: AppIcons.pdf,
            iconBgColor: AppColors.badgeBlueBg,
            iconColor: AppColors.badgeBlueText,
          );
        }).toList();
        shipperFiles.assignAll(mappedShippers);
      } else {
        recentShipperCards.clear();
        drawingApprovalItems.clear();
        shipperFiles.clear();
      }

      // 4. Plant Alerts (Dynamic notifications & system status)
      if (notificationsData != null &&
          notificationsData['notifications'] is List &&
          (notificationsData['notifications'] as List).isNotEmpty) {
        final List nList = notificationsData['notifications'];
        final mappedAlerts = nList.map((n) {
          return PlantAlertModel(
            title: (n['title'] ?? n['message'] ?? 'Notification').toString(),
            timeText: _formatTime(n['createdAt']),
            iconAsset: AppIcons.file,
            iconBgColor: AppColors.badgeBlueBg,
            iconColor: AppColors.badgeBlueText,
          );
        }).toList();
        plantAlerts.assignAll(mappedAlerts);
      } else {
        final List<PlantAlertModel> alerts = [];
        final pendingCount = projectStats?['pendingCustomerApproval'] ?? 0;
        if (pendingCount > 0) {
          alerts.add(
            PlantAlertModel(
              title: '$pendingCount Project(s) pending customer approval',
              actionText: 'View Projects',
              iconAsset: AppIcons.file,
              iconBgColor: AppColors.badgeBlueBg,
              iconColor: AppColors.badgeBlueText,
            ),
          );
        }

        final issues = bomStats?['issuesDetected'] ?? 0;
        if (issues > 0) {
          alerts.add(
            PlantAlertModel(
              title: '$issues BOM issue(s) detected',
              actionText: 'Resolve',
              iconAsset: AppIcons.shipperFile,
              iconBgColor: AppColors.badgeRedBg,
              iconColor: AppColors.badgeRedText,
            ),
          );
        }

        final totalDeliveries = deliveriesStats?['totalCount'] ?? 0;
        if (totalDeliveries > 0) {
          alerts.add(
            PlantAlertModel(
              title: '$totalDeliveries total deliveries recorded',
              timeText: 'Active',
              iconAsset: AppIcons.truckDelivery,
              iconBgColor: AppColors.badgeGreenBg,
              iconColor: AppColors.badgeGreenText,
            ),
          );
        }
        plantAlerts.assignAll(alerts);
      }

      // 5. Freight Carriers (Dynamic metrics based on delivery stats)
      final totalLoads = deliveriesStats?['totalCount'] ?? 0;
      final scheduledLoads = deliveriesStats?['scheduledCount'] ?? 0;
      final inTransitLoads = deliveriesStats?['inTransitCount'] ?? 0;
      final deliveredLoads = deliveriesStats?['deliveredCount'] ?? 0;

      freightCarriers.assignAll([
        FreightCarrierModel(
          title: 'Active Freight Shipments',
          loadsCount: '$totalLoads Total Loads',
          status: inTransitLoads > 0
              ? 'In Transit ($inTransitLoads)'
              : 'Active',
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
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
