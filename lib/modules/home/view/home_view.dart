import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_error_widget.dart';
import '../../../app/widgets/common_loader.dart';
import '../controller/home_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/drawing_approval_status_table.dart';
import '../widgets/greeting_header_section.dart';
import '../widgets/production_overview_section.dart';
import '../widgets/recent_shipper_files_grid.dart';
import '../widgets/three_column_section.dart';
import '../widgets/top_metrics_row.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Fixed at top)
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                if (controller.errorMessage.isNotEmpty) {
                  return CommonErrorWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.loadDashboardData,
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting & Date/Time Section
                      const GreetingHeaderSection(),
                      
                      // 5 Metric Cards Row
                      TopMetricsRow(metrics: controller.topMetrics),
                      
                      // Production Overview Section
                      ProductionOverviewSection(overviewItems: controller.productionOverviewItems),
                      
                      // 3 Column Section (Shipper Files, Plant Alerts, Freight Carriers)
                      ThreeColumnSection(
                        shipperFiles: controller.shipperFiles,
                        plantAlerts: controller.plantAlerts,
                        freightCarriers: controller.freightCarriers,
                      ),
                      
                      // Recent Shipper Files 4 Cards Grid Row
                      RecentShipperFilesGrid(cardItems: controller.recentShipperCards),
                      
                      // Drawing Approval Status Data Table
                      DrawingApprovalStatusTable(items: controller.drawingApprovalItems),
                      
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
}
