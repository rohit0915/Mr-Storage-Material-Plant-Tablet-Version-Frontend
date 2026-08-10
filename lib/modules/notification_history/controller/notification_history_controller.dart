import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../awarded_loads/widgets/freight_filter_dialog.dart';
import '../model/notification_history_model.dart';

class NotificationHistoryController extends GetxController {
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  final summaryStats = <NotificationStatModel>[].obs;
  final notificationsList = <NotificationItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotificationsData();
  }

  void loadNotificationsData() {
    isLoading.value = true;

    summaryStats.assignAll([
      NotificationStatModel(label: 'Total Sent', value: '6', icon: Icons.notifications_none, themeColor: const Color(0xFF2563EB)),
      NotificationStatModel(label: 'Delivered', value: '3', icon: Icons.check_circle_outline, themeColor: const Color(0xFF22C55E)),
      NotificationStatModel(label: 'Pending', value: '1', icon: Icons.access_time, themeColor: const Color(0xFFEA580C)),
      NotificationStatModel(label: 'Failed', value: '1', icon: Icons.cancel_outlined, themeColor: const Color(0xFFEF4444)),
    ]);

    notificationsList.assignAll([
      NotificationItemModel(
        id: 'NOT-001',
        notificationTitle: 'Delivery Scheduled: Primary frame steel',
        channel: 'Email Confirmation',
        deliveryId: 'DEL-001',
        project: 'Industrial Complex A',
        itemDescription: 'Primary Frame Steel',
        recipientName: 'Austin McClume',
        recipientContact: 'austin@acmecorp.com',
        deliveryStatus: 'Scheduled',
        recipientType: 'Customer',
        sentDate: '2024-03-15 10:30 AM',
      ),
      NotificationItemModel(
        id: 'NOT-002',
        notificationTitle: 'Reminder: Delivery in 48 hours',
        channel: '48-Hour Reminder\nChannel: SMS',
        deliveryId: 'DEL-001',
        project: 'Industrial Complex A',
        itemDescription: 'Primary Frame Steel',
        recipientName: 'Austin McClume',
        recipientContact: '+1 555-0303',
        deliveryStatus: 'Rescheduled',
        recipientType: 'Internal Staff',
        sentDate: '2024-03-23 8:00 AM',
      ),
      NotificationItemModel(
        id: 'NOT-003',
        notificationTitle: 'Delivery Scheduled: Roll-up doors',
        channel: 'Email Confirmation',
        deliveryId: 'DEL-002',
        project: 'Storage Facility B',
        itemDescription: 'Primary Frame Steel',
        recipientName: 'Sarah Johnson',
        recipientContact: 'sarah@buildtech.com',
        deliveryStatus: 'In Transit',
        recipientType: 'Customer',
        sentDate: '2024-03-16 2:15 PM',
      ),
      NotificationItemModel(
        id: 'NOT-004',
        notificationTitle: 'Reminder: Delivery tomorrow',
        channel: '48-Hour Reminder\nChannel: SMS',
        deliveryId: 'DEL-001',
        project: 'Industrial Complex A',
        itemDescription: 'Primary Frame Steel',
        recipientName: 'Austin McClume',
        recipientContact: '+1 555-0303',
        deliveryStatus: 'Scheduled',
        recipientType: 'Internal Staff',
        sentDate: '2024-03-24 8:00 AM',
      ),
      NotificationItemModel(
        id: 'NOT-005',
        notificationTitle: 'Delivery Date Changed',
        channel: 'Reschedule Notice',
        deliveryId: 'DEL-003',
        project: 'Warehouse Complex',
        itemDescription: 'Primary Frame Steel',
        recipientName: 'Mike Davis',
        recipientContact: 'mike@steelmasters.com',
        deliveryStatus: 'Rescheduled',
        recipientType: 'Customer',
        sentDate: '2024-03-17 11:45 AM',
      ),
      NotificationItemModel(
        id: 'NOT-006',
        notificationTitle: 'Automated voice call',
        channel: 'Voice Reminder',
        deliveryId: 'DEL-002',
        project: 'Storage Facility B',
        itemDescription: 'Primary Frame Steel',
        recipientName: 'Sarah Johnson',
        recipientContact: '+1 555-0404',
        deliveryStatus: 'In Transit',
        recipientType: 'Internal Staff',
        sentDate: '2024-03-18 9:00 AM',
        isError: true,
        errorMessage: 'Invalid phone number',
      ),
      NotificationItemModel(
        id: 'NOT-006',
        notificationTitle: 'Delivery Update',
        channel: 'Email Confirmation',
        deliveryId: 'DEL-002',
        project: 'Storage Facility B',
        itemDescription: 'Primary Frame Steel',
        recipientName: 'Sarah Johnson',
        recipientContact: '+1 555-0404',
        deliveryStatus: 'Rescheduled',
        recipientType: 'Customer',
        sentDate: '2024-03-18 9:00 AM',
      ),
    ]);

    isLoading.value = false;
  }

  void openFilterDialog() {
    Get.dialog(const FreightFilterDialog());
  }

  void exportCSV() {
    Get.snackbar(
      'Export CSV',
      'Notification history exported successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
