import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../controller/home_controller.dart';
import '../model/dashboard_models.dart';

class RecentShipperFilesGrid extends StatelessWidget {
  final List<RecentShipperFileCardModel> cardItems;

  const RecentShipperFilesGrid({super.key, required this.cardItems});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Shipper Files',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.shipperFiles),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(cardItems.length, (index) {
                final item = cardItems[index];
                void openDetails() {
                  if (Get.isRegistered<HomeController>()) {
                    Get.find<HomeController>().openShipperFileDetails(
                      requestId: item.requestId,
                      projectName: item.title,
                      projectId: item.projectCode,
                      fileName: item.fileName,
                    );
                  } else if (item.requestId.isNotEmpty) {
                    Get.toNamed(
                      AppRoutes.shipperFileDetails,
                      parameters: {'id': item.requestId},
                    );
                  } else {
                    Get.toNamed(AppRoutes.shipperFiles);
                  }
                }

                return SizedBox(
                  width: 230,
                  child: InkWell(
                    onTap: openDetails,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index == cardItems.length - 1 ? 0 : 12.0,
                      ),
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Project code badge
                          Text(
                            item.projectCode,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Title
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Subtitle
                          Text(
                            item.site,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Fields list
                          _buildKvRow('File Name', item.fileName),
                          _buildKvRow('Upload Date', item.uploadDate),
                          _buildKvRow('Items', item.items),
                          _buildKvRow('Rates', item.rates),
                          _buildKvRow('Weight', item.weight),
                          const SizedBox(height: 8),
                          // Status & Action Eye Button Row
                          Row(
                            children: [
                              const Text(
                                'Status:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: _buildStatusBadge(item.status, item.statusType),
                              ),
                              const SizedBox(width: 8),
                              const Spacer(),
                              InkWell(
                                onTap: openDetails,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                padding: const EdgeInsets.all(6),
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.visibility, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKvRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, BadgeStatusType type) {
    Color bg = AppColors.badgeYellowBg;
    Color fg = AppColors.badgeYellowText;

    if (type == BadgeStatusType.orderSent) {
      bg = AppColors.badgeGreenBg;
      fg = AppColors.badgeGreenText;
    } else if (type == BadgeStatusType.revisionSent) {
      bg = AppColors.badgeBlueBg;
      fg = AppColors.badgeBlueText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
