import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/notification_history_model.dart';

class NotificationHistoryController extends GetxController {
  final isLoading = false.obs;
  final selectedFilter = 'All'.obs;

  final summaryStats = <NotificationStatModel>[].obs;
  final allNotifications = <NotificationItemModel>[].obs;

  final filterChips = [
    'All',
    'Unread(3)',
    'Equipment',
    'Finance',
    'Meetings(2)',
  ];

  @override
  void onInit() {
    super.onInit();
    loadNotificationsData();
  }

  void loadNotificationsData() {
    isLoading.value = true;

    summaryStats.assignAll([
      NotificationStatModel(
        label: 'Total',
        value: '8',
        icon: Icons.notifications_outlined,
        themeColor: const Color(0xFF1D51A4),
      ),
      NotificationStatModel(
        label: 'Unread',
        value: '3',
        icon: Icons.notifications_none_outlined,
        themeColor: const Color(0xFF22C55E),
      ),
      NotificationStatModel(
        label: 'High Priority',
        value: '3',
        icon: Icons.notifications_outlined,
        themeColor: const Color(0xFFEAB308),
      ),
      NotificationStatModel(
        label: 'Today',
        value: '5',
        icon: Icons.notifications_outlined,
        themeColor: const Color(0xFFF97316),
      ),
    ]);

    allNotifications.assignAll([
      // Notifications for "All" tab
      NotificationItemModel(
        id: '1',
        title: 'New Equipment Updated',
        description: 'Alice Johnson from The Steel Company has been Updated a Equipment.',
        time: '2 minutes ago',
        category: 'All',
        icon: Icons.person_outline_rounded,
        iconBgColor: const Color(0xFFEFF6FF),
        iconFgColor: const Color(0xFF3B82F6),
      ),
      NotificationItemModel(
        id: '2',
        title: 'Task Reminder',
        description: 'Follow up with Bob Smith is due in 30 minutes',
        time: '30 minutes ago',
        category: 'All',
        icon: Icons.assignment_outlined,
        iconBgColor: const Color(0xFFFEF9C3),
        iconFgColor: const Color(0xFFEAB308),
      ),
      NotificationItemModel(
        id: '3',
        title: 'AI Equipment Service Overdue',
        description: 'Service Overdue, Pay before 17 April',
        time: '1 hour ago',
        category: 'All',
        icon: Icons.warning_amber_rounded,
        iconBgColor: const Color(0xFFFEE2E2),
        iconFgColor: const Color(0xFFEF4444),
      ),
      NotificationItemModel(
        id: '4',
        title: 'Meeting scheduled',
        description: 'Meeting with Design studio confirmed for tomorrow at 2 pm',
        time: '2 hours ago',
        category: 'All',
        icon: Icons.calendar_today_outlined,
        iconBgColor: const Color(0xFFEFF6FF),
        iconFgColor: const Color(0xFF3B82F6),
      ),

      // Unread notifications
      NotificationItemModel(
        id: '5',
        title: 'Meeting scheduled',
        description: 'Meeting with Design studio confirmed for tomorrow at 2 pm',
        time: '2 min ago',
        category: 'Unread(3)',
        icon: Icons.calendar_today_outlined,
        iconBgColor: const Color(0xFFEFF6FF),
        iconFgColor: const Color(0xFF3B82F6),
        isUnread: true,
      ),
      NotificationItemModel(
        id: '6',
        title: 'AI Equipment Service Overdue',
        description: 'Service Overdue, Pay before 17 April',
        time: '1 hour ago',
        category: 'Unread(3)',
        icon: Icons.warning_amber_rounded,
        iconBgColor: const Color(0xFFFEE2E2),
        iconFgColor: const Color(0xFFEF4444),
        isUnread: true,
      ),
      NotificationItemModel(
        id: '7',
        title: 'Task Reminder',
        description: 'Follow up with Bob Smith is due in 30 minutes',
        time: '1 hour ago',
        category: 'Unread(3)',
        icon: Icons.assignment_outlined,
        iconBgColor: const Color(0xFFFEF9C3),
        iconFgColor: const Color(0xFFEAB308),
        isUnread: true,
      ),
      NotificationItemModel(
        id: '8',
        title: 'New Equipment Updated',
        description: 'Alice Johnson from The Steel Company has been Updated a Equipment.',
        time: '2 hour ago',
        category: 'Unread(3)',
        icon: Icons.person_outline_rounded,
        iconBgColor: const Color(0xFFEFF6FF),
        iconFgColor: const Color(0xFF3B82F6),
        isUnread: true,
      ),

      // Equipment notifications
      NotificationItemModel(
        id: '9',
        title: 'New Equipment Updated',
        description: 'Alice Johnson from The Steel Company has been Updated a Equipment.',
        time: '2 minutes ago',
        category: 'Equipment',
        icon: Icons.assignment_outlined,
        iconBgColor: const Color(0xFFFEF9C3),
        iconFgColor: const Color(0xFFEAB308),
      ),
      NotificationItemModel(
        id: '10',
        title: 'New Equipment Updated',
        description: 'Follow up with Bob Smith is due in 30 minutes',
        time: '30 minutes ago',
        category: 'Equipment',
        icon: Icons.assignment_outlined,
        iconBgColor: const Color(0xFFFEF9C3),
        iconFgColor: const Color(0xFFEAB308),
      ),
      NotificationItemModel(
        id: '11',
        title: 'New Equipment Updated',
        description: 'Service Overdue, Pay before 17 April',
        time: '1 hour ago',
        category: 'Equipment',
        icon: Icons.assignment_outlined,
        iconBgColor: const Color(0xFFFEF9C3),
        iconFgColor: const Color(0xFFEAB308),
      ),
      NotificationItemModel(
        id: '12',
        title: 'New Equipment Updated',
        description: 'Meeting with Design studio confirmed for tomorrow at 2 pm',
        time: '2 hours ago',
        category: 'Equipment',
        icon: Icons.assignment_outlined,
        iconBgColor: const Color(0xFFFEF9C3),
        iconFgColor: const Color(0xFFEAB308),
      ),

      // Finance notifications
      NotificationItemModel(
        id: '13',
        title: 'Payment Pending',
        description: 'Alice Johnson from The Steel Company has been Updated a Equipment.',
        time: '2 minutes ago',
        category: 'Finance',
        icon: Icons.warning_amber_rounded,
        iconBgColor: const Color(0xFFFEE2E2),
        iconFgColor: const Color(0xFFEF4444),
      ),
      NotificationItemModel(
        id: '14',
        title: 'Payment Pending',
        description: 'Follow up with Bob Smith is due in 30 minutes',
        time: '30 minutes ago',
        category: 'Finance',
        icon: Icons.warning_amber_rounded,
        iconBgColor: const Color(0xFFFEE2E2),
        iconFgColor: const Color(0xFFEF4444),
      ),
      NotificationItemModel(
        id: '15',
        title: 'Payment Pending',
        description: 'Service Overdue, Pay before 17 April',
        time: '1 hour ago',
        category: 'Finance',
        icon: Icons.warning_amber_rounded,
        iconBgColor: const Color(0xFFFEE2E2),
        iconFgColor: const Color(0xFFEF4444),
      ),
      NotificationItemModel(
        id: '16',
        title: 'Payment Pending',
        description: 'Meeting with Design studio confirmed for tomorrow at 2 pm',
        time: '2 hours ago',
        category: 'Finance',
        icon: Icons.warning_amber_rounded,
        iconBgColor: const Color(0xFFFEE2E2),
        iconFgColor: const Color(0xFFEF4444),
      ),

      // Meetings notifications
      NotificationItemModel(
        id: '17',
        title: 'Meeting scheduled',
        description: 'Meeting with Design studio confirmed for tomorrow at 2 pm',
        time: '2 minutes ago',
        category: 'Meetings(2)',
        icon: Icons.calendar_today_outlined,
        iconBgColor: const Color(0xFFEFF6FF),
        iconFgColor: const Color(0xFF3B82F6),
      ),
      NotificationItemModel(
        id: '18',
        title: 'Project Review Meeting',
        description: 'Weekly team review scheduled for 4:00 PM today.',
        time: '1 hour ago',
        category: 'Meetings(2)',
        icon: Icons.calendar_today_outlined,
        iconBgColor: const Color(0xFFEFF6FF),
        iconFgColor: const Color(0xFF3B82F6),
      ),
    ]);

    isLoading.value = false;
  }

  List<NotificationItemModel> get filteredNotifications {
    final filter = selectedFilter.value;
    if (filter == 'All') {
      return allNotifications.where((n) => n.category == 'All').toList();
    }
    return allNotifications.where((n) => n.category == filter).toList();
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }
}
