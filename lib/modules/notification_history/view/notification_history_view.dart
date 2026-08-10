import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/notification_history_controller.dart';
import '../model/notification_history_model.dart';
import '../../delivery_details/widgets/delivery_scheduled_dialog.dart';

class NotificationHistoryView extends GetView<NotificationHistoryController> {
  const NotificationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      _buildHeaderRow(),
                      const SizedBox(height: 20),

                      // 4 Summary Stat Cards Row (Thick Left Border Accent Design)
                      _buildSummaryStatsRow(),
                      const SizedBox(height: 20),

                      // Search & Filter Bar Row
                      _buildFilterRow(),
                      const SizedBox(height: 20),

                      // Notifications Data Table Card
                      _buildNotificationsTableCard(),
                      const SizedBox(height: 20),

                      // Bottom Info Card (Automated Notification System)
                      _buildBottomInfoCard(),
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

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Notification History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 4),
            Text(
              'Track all delivery notifications and reminders',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => controller.exportCSV(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Export',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStatsRow() {
    return Row(
      children: controller.summaryStats.map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: stat.themeColor, width: 4.5),
                top: BorderSide(color: stat.themeColor, width: 1.5),
                right: BorderSide(color: stat.themeColor, width: 1.5),
                bottom: BorderSide(color: stat.themeColor, width: 1.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stat.value,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Icon(stat.icon, size: 26, color: stat.themeColor),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      decoration: const InputDecoration(
                        hintText: 'Search notifications...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.textHint),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => controller.openFilterDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Filter',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTableCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: const [
                SizedBox(width: 24, child: Icon(Icons.check_box_outline_blank, size: 16, color: AppColors.textSecondary)),
                SizedBox(width: 12),
                Expanded(flex: 3, child: Text('NOTIFICATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('CHANNEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('DELIVERY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('RECIPIENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('DELIVERY STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('RECIPIENT TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('SENT DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Table Rows List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.notificationsList.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final item = controller.notificationsList[index];
              return _buildNotificationRow(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationRow(NotificationItemModel item) {
    return InkWell(
      onTap: () => Get.dialog(const DeliveryScheduledDialog()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
        children: [
          const SizedBox(width: 24, child: Icon(Icons.check_box_outline_blank, size: 16, color: AppColors.textSecondary)),
          const SizedBox(width: 12),

          // Notification Title & ID
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.notificationTitle,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(item.id, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),

          // Channel Icon & Text
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                  child: const Icon(Icons.email_outlined, size: 14, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.channel,
                    style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Delivery ID & Project
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.deliveryId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(item.project, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(item.itemDescription, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),

          // Recipient Name & Contact Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 12, color: Color(0xFFA855F7)),
                    const SizedBox(width: 4),
                    Text(item.recipientName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(item.recipientContact, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),

          // Delivery Status
          Expanded(
            flex: 2,
            child: Text(
              item.deliveryStatus,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),

          // Recipient Type
          Expanded(
            flex: 2,
            child: Text(
              item.recipientType,
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
            ),
          ),

          // Sent Date & Error Message
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.sentDate, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                if (item.isError && item.errorMessage != null) ...[
                  const SizedBox(height: 2),
                  Text(item.errorMessage!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBottomInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_none, size: 20, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Automated Notification System',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                ),
                SizedBox(height: 4),
                Text(
                  'All notifications are sent automatically based on delivery schedules. Email confirmations are sent immediately, SMS reminders at 48 hours and 24 hours before delivery, and delivery day reminders on the morning of delivery.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF1E3A8A), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
