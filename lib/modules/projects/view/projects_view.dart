import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/projects_controller.dart';
import '../widgets/projects_data_table.dart';
import '../widgets/projects_header.dart';
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CommonLoader();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                const DashboardAppBar(),

                // Projects Header
                const ProjectsHeader(),

                // Stat Cards (Total Projects, Active Projects, Pending, Canceled)
                ProjectsStatCards(stats: controller.projectStats),

                // Toolbar (Import CSV, Export Data, Filter dropdowns)
                const ProjectsToolbar(),

                // Projects Data Table
                ProjectsDataTable(
                  items: controller.projectItems,
                  selectAll: controller.selectAllRows.value,
                  onSelectAll: controller.toggleSelectAll,
                  onSelectRow: controller.toggleRowSelect,
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }
}
