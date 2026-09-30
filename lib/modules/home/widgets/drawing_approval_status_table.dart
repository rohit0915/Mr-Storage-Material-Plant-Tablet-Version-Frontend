import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../controller/home_controller.dart';
import '../model/dashboard_models.dart';

class DrawingApprovalStatusTable extends StatelessWidget {
  final List<DrawingApprovalStatusModel> items;

  const DrawingApprovalStatusTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Drawing Approval Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth =
                  constraints.maxWidth < 850 ? 850 : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Container(
                    decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    // Header row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 24), // Checkbox spacing
                          const SizedBox(width: 12),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Client Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Project Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'File Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Sent Date ↕',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32), // Action spacing
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    // Rows
                    ...items.map((row) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                // Checkbox placeholder
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.inputBorder),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                // Client Name with Avatar
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                        child: Text(
                                          row.avatarInitial,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          row.clientName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Project Name
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    row.projectName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                // File Name
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    row.fileName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                // Sent Date
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    row.sentDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                // Status Pill
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildStatusPill(row.status, row.statusType),
                                  ),
                                ),
                                // Eye Action Button
                                InkWell(
                                  onTap: () {
                                    if (Get.isRegistered<HomeController>()) {
                                      Get.find<HomeController>().openShipperFileDetails(
                                        requestId: row.requestId,
                                        projectName: row.projectName,
                                        clientName: row.clientName,
                                        projectId: row.projectId,
                                        buildingId: row.buildingId,
                                        fileName: row.fileName,
                                      );
                                    } else if (row.requestId.isNotEmpty) {
                                      Get.toNamed(
                                        AppRoutes.shipperFileDetails,
                                        parameters: {'id': row.requestId},
                                      );
                                    } else {
                                      Get.toNamed(AppRoutes.shipperFiles);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/icons/ic_eye.png',
                                      color: Colors.white,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.visibility, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ],
      ),
    );
  }

  Widget _buildStatusPill(String text, BadgeStatusType type) {
    Color bg = AppColors.badgeYellowBg;
    Color fg = AppColors.badgeYellowText;
    IconData? icon;

    if (type == BadgeStatusType.approved) {
      bg = AppColors.badgeGreenBg;
      fg = AppColors.badgeGreenText;
      icon = Icons.check_circle_outline;
    } else if (type == BadgeStatusType.revisionSent) {
      bg = AppColors.badgeBlueBg;
      fg = AppColors.badgeBlueText;
      icon = Icons.refresh;
    } else if (type == BadgeStatusType.pending) {
      bg = AppColors.badgeYellowBg;
      fg = AppColors.badgeYellowText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 12, color: fg),
          ],
        ],
      ),
    );
  }
}
