import 'package:flutter/material.dart';

class NotificationItemModel {
  final String id;
  final String refModel, refId, leadId;
  final String title;
  final String description;
  final String time;
  final String category; // 'all', 'unread', 'equipment', 'finance', 'meetings'
  final IconData icon;
  final Color iconBgColor;
  final Color iconFgColor;
  final bool isUnread;

  NotificationItemModel({
    required this.id,
    this.refModel = '',
    this.refId = '',
    this.leadId = '',
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.icon,
    required this.iconBgColor,
    required this.iconFgColor,
    this.isUnread = false,
  });
}

class NotificationStatModel {
  final String label;
  final String value;
  final IconData icon;
  final Color themeColor;

  NotificationStatModel({
    required this.label,
    required this.value,
    required this.icon,
    required this.themeColor,
  });
}
