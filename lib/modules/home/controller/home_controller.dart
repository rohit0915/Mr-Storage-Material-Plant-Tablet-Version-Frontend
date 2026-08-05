import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_icons.dart';
import '../model/dashboard_models.dart';
import '../repository/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository repository;

  HomeController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedDrawerItem = 'Dashboard'.obs;

  // Rx Data Lists
  final RxList<TopMetricModel> topMetrics = <TopMetricModel>[].obs;
  final RxList<ProductionOverviewModel> productionOverviewItems = <ProductionOverviewModel>[].obs;
  final RxList<ShipperFileReceivedModel> shipperFiles = <ShipperFileReceivedModel>[].obs;
  final RxList<PlantAlertModel> plantAlerts = <PlantAlertModel>[].obs;
  final RxList<FreightCarrierModel> freightCarriers = <FreightCarrierModel>[].obs;
  final RxList<RecentShipperFileCardModel> recentShipperCards = <RecentShipperFileCardModel>[].obs;
  final RxList<DrawingApprovalStatusModel> drawingApprovalItems = <DrawingApprovalStatusModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() {
    isLoading.value = true;

    topMetrics.assignAll([
      TopMetricModel(
        title: 'Total Projects',
        count: '04',
        iconAsset: AppIcons.totalProject,
        backgroundColor: AppColors.totalProjectsCard,
      ),
      TopMetricModel(
        title: 'In Production',
        count: '02',
        iconAsset: AppIcons.inProduction,
        backgroundColor: AppColors.inProductionCard,
      ),
      TopMetricModel(
        title: 'Ready to Dispatch',
        count: '01',
        iconAsset: AppIcons.readyToDispatch,
        backgroundColor: AppColors.readyToDispatchCard,
      ),
      TopMetricModel(
        title: 'Dispatched Today',
        count: '01',
        iconAsset: AppIcons.dispatchedToday,
        backgroundColor: AppColors.dispatchedTodayCard,
      ),
      TopMetricModel(
        title: 'Pending Approval',
        count: '01',
        iconAsset: AppIcons.pendingApproval,
        backgroundColor: AppColors.pendingApprovalCard,
      ),
    ]);

    productionOverviewItems.assignAll([
      ProductionOverviewModel(
        iconAsset: AppIcons.plannedTonnage,
        label: 'Planned Tonnage',
        value: '125.50 MT',
      ),
      ProductionOverviewModel(
        iconAsset: AppIcons.producedTonnage,
        label: 'Produced Tonnage',
        value: '78.80 MT',
      ),
      ProductionOverviewModel(
        iconAsset: AppIcons.utilization,
        label: 'Utilization',
        value: '63%',
      ),
      ProductionOverviewModel(
        iconAsset: AppIcons.onTimeDelivery,
        label: 'On-Time Delivery',
        value: '92%',
      ),
      ProductionOverviewModel(
        iconAsset: AppIcons.rework,
        label: 'Rework/Rejection',
        value: '2.4%',
      ),
    ]);

    shipperFiles.assignAll([
      ShipperFileReceivedModel(
        title: 'ABC Warehouse',
        subtitle: 'SHP-1044 | ABC Steel',
        itemCount: '120 Items',
        date: 'Mar 15, 2025',
        time: '05:00:14 PM',
        iconAsset: AppIcons.pdf,
        iconBgColor: AppColors.badgeRedBg,
        iconColor: AppColors.badgeRedText,
      ),
      ShipperFileReceivedModel(
        title: 'Tech Park Dev',
        subtitle: 'SHP-1044 | ABC Steel',
        itemCount: '95 Items',
        date: 'Jan 8, 2025',
        time: '08:20:13 PM',
        iconAsset: AppIcons.xls,
        iconBgColor: AppColors.badgeGreenBg,
        iconColor: AppColors.badgeGreenText,
      ),
      ShipperFileReceivedModel(
        title: 'Downtown Plaza',
        subtitle: 'SHP-1044 | ABC Steel',
        itemCount: '50 Items',
        date: 'Aug 6, 2025',
        time: '04:10:12 PM',
        iconAsset: AppIcons.pdf,
        iconBgColor: AppColors.badgePurpleBg,
        iconColor: AppColors.badgePurpleText,
      ),
      ShipperFileReceivedModel(
        title: 'Riverside complex',
        subtitle: 'SHP-1044 | ABC Steel',
        itemCount: '120 Items',
        date: 'Jan 6, 2025',
        time: '03:40:14 PM',
        iconAsset: AppIcons.xls,
        iconBgColor: AppColors.badgeRedBg,
        iconColor: AppColors.badgeRedText,
      ),
      ShipperFileReceivedModel(
        title: 'Techpark Dev',
        subtitle: 'SHP-1044 | ABC Steel',
        itemCount: '120 Items',
        date: 'Oct 12, 2025',
        time: '05:00:14 PM',
        iconAsset: AppIcons.pdf,
        iconBgColor: AppColors.badgeRedBg,
        iconColor: AppColors.badgeRedText,
      ),
    ]);

    plantAlerts.assignAll([
      PlantAlertModel(
        title: 'Shipper File Comparison Completed SH-001',
        actionText: 'View Result',
        iconAsset: AppIcons.file,
        iconBgColor: AppColors.badgeBlueBg,
        iconColor: AppColors.badgeBlueText,
      ),
      PlantAlertModel(
        title: 'Shipper File Comparison Failed SH-002',
        actionText: 'Try Again',
        iconAsset: AppIcons.shipperFile,
        iconBgColor: AppColors.badgeRedBg,
        iconColor: AppColors.badgeRedText,
      ),
      PlantAlertModel(
        title: 'Oder ORD-1045 Marked as ready to dispatch',
        timeText: '04:10:12 PM',
        iconAsset: AppIcons.truckDelivery,
        iconBgColor: AppColors.badgeGreenBg,
        iconColor: AppColors.badgeGreenText,
      ),
      PlantAlertModel(
        title: 'Drawing DRG-098 Uploaded',
        timeText: '03:40:14 PM',
        iconAsset: AppIcons.drawing,
        iconBgColor: AppColors.badgePurpleBg,
        iconColor: AppColors.badgePurpleText,
      ),
      PlantAlertModel(
        title: 'Production Target for todayis 63%',
        timeText: '05:00:14 PM',
        iconAsset: AppIcons.productionTarget,
        iconBgColor: AppColors.badgeYellowBg,
        iconColor: AppColors.badgeYellowText,
      ),
    ]);

    freightCarriers.assignAll([
      FreightCarrierModel(
        title: 'Roadking Logistics',
        loadsCount: '12 Loads Today',
        status: 'On Time',
        isOnTime: true,
        iconAsset: AppIcons.roadkingLogistics,
      ),
      FreightCarrierModel(
        title: 'Swift Transport',
        loadsCount: '08 Loads Today',
        status: 'On Time',
        isOnTime: true,
        iconAsset: AppIcons.swiftTransport,
      ),
      FreightCarrierModel(
        title: 'Global Freight Lines',
        loadsCount: '12 Loads Today',
        status: 'Delayed',
        isOnTime: false,
        iconAsset: AppIcons.globalFreightLines,
      ),
      FreightCarrierModel(
        title: 'Eagle Freight',
        loadsCount: '08 Loads Today',
        status: 'On Time',
        isOnTime: true,
        iconAsset: AppIcons.eagleFreight,
      ),
      FreightCarrierModel(
        title: 'Prime Carriers',
        loadsCount: '12 Loads Today',
        status: 'Delayed',
        isOnTime: false,
        iconAsset: AppIcons.primeCarriers,
      ),
    ]);

    recentShipperCards.assignAll([
      RecentShipperFileCardModel(
        projectCode: 'PRJ-001',
        title: 'Downtown Office Complex',
        site: 'Site A',
        fileName: 'SHP-1044',
        uploadDate: '12/09/2026',
        items: '120',
        rates: '\$2100',
        weight: '18,000 lbs',
        status: 'File Received',
        statusType: BadgeStatusType.fileReceived,
      ),
      RecentShipperFileCardModel(
        projectCode: 'PRJ-002',
        title: 'Residential Tower A',
        site: 'Site A',
        fileName: 'SHP-1044',
        uploadDate: '12/09/2026',
        items: '120',
        rates: '\$2100',
        weight: '18,000 lbs',
        status: 'Order Sent',
        statusType: BadgeStatusType.orderSent,
      ),
      RecentShipperFileCardModel(
        projectCode: 'PRJ-004',
        title: 'Shopping Mall Renovation',
        site: 'Site A',
        fileName: 'SHP-1044',
        uploadDate: '12/09/2026',
        items: '120',
        rates: '\$2100',
        weight: '18,000 lbs',
        status: 'Revision Sent',
        statusType: BadgeStatusType.revisionSent,
      ),
      RecentShipperFileCardModel(
        projectCode: 'PRJ-001',
        title: 'Downtown Office Complex',
        site: 'Site A',
        fileName: 'SHP-1044',
        uploadDate: '12/09/2026',
        items: '120',
        rates: '\$2100',
        weight: '18,000 lbs',
        status: 'File Received',
        statusType: BadgeStatusType.fileReceived,
      ),
    ]);

    drawingApprovalItems.assignAll([
      DrawingApprovalStatusModel(
        clientName: 'ABC Steel',
        projectName: 'ABC Warehouse',
        fileName: 'Drawing',
        sentDate: '22 Feb 2025',
        status: 'Pending',
        statusType: BadgeStatusType.pending,
        avatarInitial: 'A',
      ),
      DrawingApprovalStatusModel(
        clientName: 'Steel Works LTD',
        projectName: 'Tech Park Dev',
        fileName: 'Drawing',
        sentDate: '07 Feb 2025',
        status: 'Approved',
        statusType: BadgeStatusType.approved,
        avatarInitial: 'S',
      ),
      DrawingApprovalStatusModel(
        clientName: 'Metro Steel',
        projectName: 'Downtown Plaza',
        fileName: 'Drawing',
        sentDate: '30 Jan 2025',
        status: 'Revision Sent',
        statusType: BadgeStatusType.revisionSent,
        avatarInitial: 'M',
      ),
      DrawingApprovalStatusModel(
        clientName: 'ABC Steel',
        projectName: 'Riverside Complex',
        fileName: 'Drawing',
        sentDate: '17 Jan 2025',
        status: 'Pending',
        statusType: BadgeStatusType.pending,
        avatarInitial: 'A',
      ),
      DrawingApprovalStatusModel(
        clientName: 'Steel Works LTD',
        projectName: 'Tech Park Dev',
        fileName: 'Drawing',
        sentDate: '04 Jan 2025',
        status: 'Approved',
        statusType: BadgeStatusType.approved,
        avatarInitial: 'S',
      ),
      DrawingApprovalStatusModel(
        clientName: 'Metro Steel',
        projectName: 'Downtown Plaza',
        fileName: 'Drawing',
        sentDate: '08 Dec 2024',
        status: 'Approved',
        statusType: BadgeStatusType.approved,
        avatarInitial: 'M',
      ),
    ]);

    isLoading.value = false;
  }
}
