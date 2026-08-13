import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/projects_controller.dart';
import '../widgets/projects_data_table.dart';
import '../widgets/projects_header.dart';
import '../widgets/projects_shimmer.dart';
import '../widgets/projects_stat_cards.dart';
import '../widgets/projects_toolbar.dart';

class ProjectsView extends GetView<ProjectsController> {
  const ProjectsView({super.key});

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
                  return const ProjectsShimmer();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Projects Header
                      const ProjectsHeader(),

                      // Stat Cards (Total Projects, Active Projects, Pending, Canceled)
                      Obx(() => ProjectsStatCards(stats: controller.projectStats.toList())),

                      // Toolbar (Import CSV, Export Data, Filter dropdowns)
                      const ProjectsToolbar(),

                      // Projects Data Table
                      Obx(() => ProjectsDataTable(
                            items: controller.projectItems.toList(),
                            selectAll: controller.selectAllRows.value,
                            onSelectAll: controller.toggleSelectAll,
                            onSelectRow: controller.toggleRowSelect,
                          )),

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
