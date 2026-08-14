import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../../app/widgets/common_pagination.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/all_projects_controller.dart';
import '../model/all_projects_model.dart';

class AllProjectsView extends GetView<AllProjectsController> {
  const AllProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Header (Fixed at top)
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                final prof = controller.userProfile.value;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button & All Projects Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
                              label: const Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'All Projects',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // User Profile Header Card
                      if (prof != null) _buildUserProfileCard(prof),

                      const SizedBox(height: 12),

                      // Search, Filter & Sort Toolbar Bar
                      _buildSearchFilterToolbar(),

                      const SizedBox(height: 12),

                      // Projects Data Table
                      _buildProjectsDataTable(),

                      const SizedBox(height: 16),

                      // Bottom Pagination Bar
                      _buildPaginationBar(),

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

  Widget _buildUserProfileCard(UserProfileHeaderModel prof) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.person, size: 44, color: AppColors.primary),
            ),
            const SizedBox(width: 18),
            // User Meta
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      prof.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.badgeGreenBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.badgeGreenText,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.badgeGreenText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  prof.id,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prof.joinedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Contact Information Grid
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactItem(Icons.phone_outlined, 'Phone', prof.phone),
                const SizedBox(height: 8),
                _buildContactItem(Icons.email_outlined, 'Email', prof.email, isEmail: true),
                const SizedBox(height: 8),
                _buildContactItem(Icons.location_on_outlined, 'Address', prof.address),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, {bool isEmail = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 65,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isEmail ? const Color(0xFF3B82F6) : AppColors.textPrimary,
          ),
        ),
        if (isEmail) ...[
          const SizedBox(width: 6),
          const Icon(Icons.copy_outlined, size: 13, color: Color(0xFF3B82F6)),
        ],
      ],
    );
  }

  Widget _buildSearchFilterToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // Search Input
          Container(
            width: 220,
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, size: 18, color: AppColors.textHint),
                SizedBox(width: 8),
                Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: const [
                Icon(Icons.filter_list_outlined, size: 16, color: AppColors.textPrimary),
                SizedBox(width: 6),
                Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Sort Dropdown
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                const Text(
                  'Sort by : ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Obx(() => Text(
                      controller.selectedSort.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    )),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsDataTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Obx(() => Checkbox(
                          value: controller.selectAll.value,
                          onChanged: controller.toggleSelectAll,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          activeColor: AppColors.primary,
                        )),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Project Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Building',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: const [
                        Text(
                          'Start Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.swap_vert, size: 14, color: AppColors.textHint),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: const [
                        Text(
                          'Stage',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.swap_vert, size: 14, color: AppColors.textHint),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: const [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.swap_vert, size: 14, color: AppColors.textHint),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 80), // Actions column width
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            // Table Rows
            ...List.generate(controller.projects.length, (index) {
              final item = controller.projects[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: item.isSelected,
                            onChanged: (_) => controller.toggleSelectRow(index),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.projectName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.buildingCount,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.startDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.stage,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.progress,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildStatusBadge(item.status, item.statusType),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: ElevatedButton(
                            onPressed: () => Get.toNamed(AppRoutes.projectDetails),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              elevation: 0,
                              minimumSize: const Size(64, 30),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text(
                              'View',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < controller.projects.length - 1)
                    const Divider(height: 1, color: AppColors.divider),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String statusText, AllProjectStatusType type) {
    Color bg = const Color(0xFFFEF08A);
    Color fg = const Color(0xFFA16207);

    switch (type) {
      case AllProjectStatusType.workInProgress:
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFFA16207);
        break;
      case AllProjectStatusType.active:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case AllProjectStatusType.completed:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF0F172A);
        break;
      case AllProjectStatusType.canceled:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFC2410C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: CommonPaginationFooter(
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages.value,
        rowsPerPage: controller.rowsPerPage.value,
        onPageChanged: (page) => controller.currentPage.value = page,
        onRowsPerPageChanged: (rows) => controller.rowsPerPage.value = rows,
      ),
    );
  }
}
