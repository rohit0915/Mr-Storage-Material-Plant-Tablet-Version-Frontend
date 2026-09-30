import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/notification_history_model.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../repository/notification_repository.dart';

class NotificationHistoryController extends GetxController {
  final NotificationRepository repository;
  NotificationHistoryController({required this.repository});

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final selectedFilter = 'All'.obs;
  final summaryStats = <NotificationStatModel>[].obs;
  final allNotifications = <NotificationItemModel>[].obs;
  final filterChips = <String>[
    'All',
    'Unread',
    'High Priority',
    'delivery',
    'drawing',
    'payment',
    'material_request',
    'chat',
  ];
  final currentPage = 1.obs;
  final total = 0.obs;
  final actionLoading = false.obs;
  int generation = 0;
  int get totalPages => (total.value / 20).ceil().clamp(1, 1000000);
  void changePage(int page) {
    currentPage.value = page;
    loadNotificationsData();
  }

  @override
  void onInit() {
    super.onInit();
    loadNotificationsData();
  }

  Future<void> loadNotificationsData() async {
    final request = ++generation;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.list(
        page: currentPage.value,
        filter: selectedFilter.value,
      );
      if (request != generation) return;
      total.value = _int(data['total']);
      final stats = Map<String, dynamic>.from(data['stats'] as Map? ?? {});
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
            refModel: (item['refModel'] ?? '').toString(),
            refId: (item['refId'] ?? '').toString(),
            leadId: (item['leadId'] ?? '').toString(),
            title: (item['title'] ?? item['subject'] ?? 'Notification')
                .toString(),
            description:
                (item['body'] ?? item['message'] ?? item['description'] ?? '')
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
      summaryStats.assignAll([
        _stat(
          'Total',
          _int(stats['total'] ?? total.value),
          const Color(0xFF1D51A4),
        ),
        _stat('Unread', _int(stats['unread']), const Color(0xFF22C55E)),
        _stat(
          'High Priority',
          _int(stats['highPriority']),
          const Color(0xFFEAB308),
        ),
        _stat('Today', _int(stats['today']), const Color(0xFFF97316)),
      ]);
    } catch (error) {
      if (request != generation) return;
      errorMessage.value = error.toString();
      allNotifications.clear();
      summaryStats.clear();
    } finally {
      if (request == generation) isLoading.value = false;
    }
  }

  List<NotificationItemModel> get filteredNotifications => allNotifications;
  void selectFilter(String filter) {
    selectedFilter.value = filter;
    changePage(1);
  }

  Future<void> _action(Future<void> Function() operation) async {
    if (actionLoading.value) return;
    actionLoading.value = true;
    try {
      await operation();
      await loadNotificationsData();
    } catch (e) {
      CommonSnackbar.showError(
        title: 'Notification action failed',
        message: e.toString(),
      );
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> markAllRead() => _action(repository.markAllRead);
  Future<void> markRead(String id) => _action(() => repository.markRead(id));
  Future<void> deleteNotification(String id) =>
      _action(() => repository.delete(id));

  Future<void> openNotification(NotificationItemModel item) async {
    if (item.isUnread) await markRead(item.id);
    final id = item.refId.isNotEmpty ? item.refId : item.leadId;
    final project = item.leadId.isNotEmpty ? item.leadId : id;
    if (item.refModel.toLowerCase() == 'chat') {
      Get.toNamed(AppRoutes.chat);
      return;
    }
    if (id.isEmpty) return;
    final (route, target) = switch (item.refModel.toLowerCase()) {
      'delivery' ||
      'freightload' ||
      'freightrequest' => (AppRoutes.deliveryDetails, id),
      'drawing' || 'projectdrawing' => (AppRoutes.projectDrawings, project),
      'shipperfile' ||
      'shipperquote' => (AppRoutes.projectShipperFiles, project),
      'materialrequest' => (AppRoutes.additionalMaterialRequest, project),
      'loadplan' => (AppRoutes.loadPlanDetails, id),
      'packinglist' => (AppRoutes.projectPackingList, project),
      'bom' => (AppRoutes.projectDetails, project),
      _ => (AppRoutes.projectDetails, project),
    };
    Get.toNamed(route, parameters: {'id': target});
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
