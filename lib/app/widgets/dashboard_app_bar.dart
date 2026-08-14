import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steel_building_plant_panel/app/utils/app_icons.dart';
import '../routes/app_routes.dart';
import '../services/shared_pref_service.dart';
import '../utils/app_colors.dart';
import '../../modules/home/controller/home_controller.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    String userName = 'John';
    String userEmail = 'plant@steelbuilding.depot';

    if (Get.isRegistered<SharedPrefService>()) {
      final userJson = Get.find<SharedPrefService>().getUserData();
      if (userJson != null && userJson.isNotEmpty) {
        try {
          final Map<String, dynamic> userMap = jsonDecode(userJson);
          if (userMap['name'] != null && userMap['name'].toString().isNotEmpty) {
            userName = userMap['name'].toString();
          }
          if (userMap['email'] != null && userMap['email'].toString().isNotEmpty) {
            userEmail = userMap['email'].toString();
          }
        } catch (_) {}
      }
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Image.asset(AppIcons.icMenu, color: Colors.white, fit: BoxFit.contain),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 14),
          // User info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Search box
          Container(
            width: 280,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Notification Bell with Popover Menu
          PopupMenuButton<void>(
            offset: const Offset(0, 50),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            padding: EdgeInsets.zero,
            itemBuilder: (context) {
              final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
              final alerts = homeController?.plantAlerts ?? [];

              return [
                PopupMenuItem<void>(
                  enabled: false,
                  child: SizedBox(
                    width: 340,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 12),
                          child: Text(
                            'Plant Alerts & Notifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212B36),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E4E6)),
                        const SizedBox(height: 8),
                        if (alerts.isEmpty) ...[
                          _buildNotificationItem(
                            icon: Icons.description_outlined,
                            iconBg: const Color(0xFFDFF4FE),
                            iconFg: const Color(0xFF155DFC),
                            title: 'Shipper File Comparison Completed SH-001',
                            action: 'View Result',
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(AppRoutes.comparisonResult);
                            },
                          ),
                          _buildNotificationItem(
                            icon: Icons.local_shipping_outlined,
                            iconBg: const Color(0xFFECF6F1),
                            iconFg: const Color(0xFF3AB449),
                            title: 'Order ORD-1045 Marked as ready to dispatch',
                            time: '08:20:13 PM',
                          ),
                          _buildNotificationItem(
                            icon: Icons.square_foot_outlined,
                            iconBg: const Color(0xFFDDD1F6),
                            iconFg: const Color(0xFF7539FF),
                            title: 'Drawing DRG-098 Uploaded',
                            time: '04:10:12 PM',
                          ),
                          _buildNotificationItem(
                            icon: Icons.show_chart,
                            iconBg: const Color(0xFFFFF6D0),
                            iconFg: const Color(0xFFB78B00),
                            title: 'Production Target for today is 63%',
                            time: '03:40:14 PM',
                          ),
                          _buildNotificationItem(
                            icon: Icons.description_outlined,
                            iconBg: const Color(0xFFFFE7E4),
                            iconFg: const Color(0xFFEF4444),
                            title: 'Order ORD-1045 Marked as ready to dispatch',
                            time: '05:00:14 PM',
                          ),
                        ] else ...[
                          ...alerts.take(5).map((item) => _buildNotificationItem(
                                icon: Icons.notifications_active_outlined,
                                iconBg: item.iconBgColor,
                                iconFg: item.iconColor,
                                title: item.title,
                                action: item.actionText,
                                time: item.timeText,
                                onTap: () {
                                  Navigator.pop(context);
                                  Get.toNamed(AppRoutes.notificationHistory);
                                },
                              )),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Get.toNamed(AppRoutes.notificationHistory);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF155DFC)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: const Text(
                              'View All Notifications',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF155DFC),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ];
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(AppIcons.notification, color: AppColors.white, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // User Profile Icon with Popover Menu
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            onSelected: (value) async {
              if (value == 'signout') {
                if (Get.isRegistered<SharedPrefService>()) {
                  await Get.find<SharedPrefService>().clearSession();
                }
                Get.offAllNamed(AppRoutes.login);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(Icons.person_outline, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text(
                      'My profile',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: const [
                    Icon(Icons.settings_outlined, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 12),
                    Text(
                      'Sign out',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(AppIcons.profile, color: Colors.white, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    String? action,
    String? time,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconFg, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212B36),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (action != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                action,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF155DFC),
                ),
              ),
            )
          else if (time != null)
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF637381),
              ),
            ),
        ],
      ),
    );
  }
}
