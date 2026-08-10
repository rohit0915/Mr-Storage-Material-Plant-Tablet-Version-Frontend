import 'package:flutter/material.dart';

class NotificationItemModel {
  final String id;
  final String notificationTitle;
  final String channel;
  final String deliveryId;
  final String project;
  final String itemDescription;
  final String recipientName;
  final String recipientContact;
  final String deliveryStatus;
  final String recipientType;
  final String sentDate;
  final bool isError;
  final String? errorMessage;

  NotificationItemModel({
    required this.id,
    required this.notificationTitle,
    required this.channel,
    required this.deliveryId,
    required this.project,
    required this.itemDescription,
    required this.recipientName,
    required this.recipientContact,
    required this.deliveryStatus,
    required this.recipientType,
    required this.sentDate,
    this.isError = false,
    this.errorMessage,
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
