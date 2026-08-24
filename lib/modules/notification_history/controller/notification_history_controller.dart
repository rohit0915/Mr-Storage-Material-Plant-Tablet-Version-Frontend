import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/notification_history_model.dart';
import '../repository/notification_repository.dart';

class NotificationHistoryController extends GetxController {
  final NotificationRepository repository;
  NotificationHistoryController({required this.repository});

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final selectedFilter = 'All'.obs;
  final summaryStats = <NotificationStatModel>[].obs;
  final allNotifications = <NotificationItemModel>[].obs;
  final filterChips = <String>['All', 'Unread'];

  @override
  void onInit() {
    super.onInit();
    loadNotificationsData();
  }

  Future<void> loadNotificationsData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.list();
      final raw = data['notifications'] is List
          ? data['notifications'] as List
          : data['data'] is List
              ? data['data'] as List
              : data['items'] is List
                  ? data['items'] as List
                  : const [];
      allNotifications.assignAll(
        raw.whereType<Map>().map((entry) {
          final item = Map<String, dynamic>.from(entry);
          final unread = item['isRead'] != true && item['read'] != true;
          return NotificationItemModel(
            id: (item['_id'] ?? item['id'] ?? '').toString(),
            title: (item['title'] ?? item['subject'] ?? 'Notification')
                .toString(),
            description: (item['message'] ?? item['description'] ?? '')
                .toString(),
            time: _relativeTime(item['createdAt'] ?? item['sentAt']),
            category: unread ? 'Unread' : 'All',
            icon: _icon(item['type']),
            iconBgColor: unread
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFF1F5F9),
            iconFgColor: unread
                ? const Color(0xFF2563EB)
                : const Color(0xFF64748B),
            isUnread: unread,
          );
        }),
      );
      final unreadCount = _int(
        data['unreadCount'] ??
            allNotifications.where((item) => item.isUnread).length,
      );
      summaryStats.assignAll([
        _stat('Total', allNotifications.length, const Color(0xFF1D51A4)),
        _stat('Unread', unreadCount, const Color(0xFF22C55E)),
        _stat(
          'High Priority',
          allNotifications
              .where((item) => item.title.toLowerCase().contains('urgent'))
              .length,
          const Color(0xFFEAB308),
        ),
        _stat(
          'Today',
          allNotifications.where((item) => item.time == 'Today').length,
          const Color(0xFFF97316),
        ),
      ]);
    } catch (error) {
      errorMessage.value = error.toString();
      allNotifications.clear();
      summaryStats.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<NotificationItemModel> get filteredNotifications =>
      selectedFilter.value == 'Unread'
      ? allNotifications.where((item) => item.isUnread).toList()
      : allNotifications;
  void selectFilter(String filter) => selectedFilter.value = filter;
  Future<void> markAllRead() async {
    await repository.markAllRead();
    await loadNotificationsData();
  }

  Future<void> markRead(String id) async {
    await repository.markRead(id);
    await loadNotificationsData();
  }

  Future<void> deleteNotification(String id) async {
    await repository.delete(id);
    await loadNotificationsData();
  }

  NotificationStatModel _stat(String label, int value, Color color) =>
      NotificationStatModel(
        label: label,
        value: '$value',
        icon: Icons.notifications_outlined,
        themeColor: color,
      );
  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  IconData _icon(dynamic type) {
    final value = (type ?? '').toString().toLowerCase();
    if (value.contains('delivery')) return Icons.local_shipping_outlined;
    if (value.contains('warning') || value.contains('urgent')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.notifications_outlined;
  }

  String _relativeTime(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString())?.toLocal();
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}
