import 'package:flutter/material.dart';
import 'package:steel_building_plant_panel/app/utils/app_icons.dart';
import '../../../app/utils/app_colors.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
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
            children: const [
              Text(
                'Welcome, John!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'plant@steelbuilding.depot',
                style: TextStyle(
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
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                enabled: false,
                child: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 12),
                        child: Text(
                          'Plant Alerts & Notifications',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 8),
                      _buildNotificationItem(
                        icon: Icons.description_outlined,
                        iconBg: AppColors.badgeBlueBg,
                        iconFg: AppColors.badgeBlueText,
                        title: 'Shipper File Comparison Completed SH-001',
                        action: 'View Result',
                      ),
                      _buildNotificationItem(
                        icon: Icons.local_shipping_outlined,
                        iconBg: AppColors.badgeGreenBg,
                        iconFg: AppColors.badgeGreenText,
                        title: 'Oder ORD-1045 Marked as ready to dispatch',
                        time: '08:20:13 PM',
                      ),
                      _buildNotificationItem(
                        icon: Icons.square_foot_outlined,
                        iconBg: AppColors.badgePurpleBg,
                        iconFg: AppColors.badgePurpleText,
                        title: 'Drawing DRG-098 Uploaded',
                        time: '04:10:12 PM',
                      ),
                      _buildNotificationItem(
                        icon: Icons.show_chart,
                        iconBg: AppColors.badgeYellowBg,
                        iconFg: AppColors.badgeYellowText,
                        title: 'Production Target for todayis 63%',
                        time: '03:40:14 PM',
                      ),
                      _buildNotificationItem(
                        icon: Icons.description_outlined,
                        iconBg: AppColors.badgeRedBg,
                        iconFg: AppColors.badgeRedText,
                        title: 'Oder ORD-1045 Marked as ready to dispatch',
                        time: '05:00:14 PM',
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'View All Notifications',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Image.asset(AppIcons.notification, color: AppColors.white, fit: BoxFit.contain),
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(width: 10),

          // User Profile Icon with Popover Menu
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            onSelected: (value) {},
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
                padding: const EdgeInsets.all(4.0),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconFg, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (action != null)
            Text(
              action,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            )
          else if (time != null)
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
