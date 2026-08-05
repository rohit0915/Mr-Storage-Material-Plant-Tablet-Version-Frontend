import 'package:flutter/material.dart';

enum BadgeStatusType {
  fileReceived,
  orderSent,
  revisionSent,
  onTime,
  delayed,
  pending,
  approved,
}

class TopMetricModel {
  final String title;
  final String count;
  final String iconAsset;
  final Color backgroundColor;

  TopMetricModel({
    required this.title,
    required this.count,
    required this.iconAsset,
    required this.backgroundColor,
  });
}

class ProductionOverviewModel {
  final String iconAsset;
  final String label;
  final String value;

  ProductionOverviewModel({
    required this.iconAsset,
    required this.label,
    required this.value,
  });
}

class ShipperFileReceivedModel {
  final String title;
  final String subtitle;
  final String itemCount;
  final String date;
  final String time;
  final String iconAsset;
  final Color iconBgColor;
  final Color iconColor;

  ShipperFileReceivedModel({
    required this.title,
    required this.subtitle,
    required this.itemCount,
    required this.date,
    required this.time,
    required this.iconAsset,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class PlantAlertModel {
  final String title;
  final String? actionText;
  final String? timeText;
  final String iconAsset;
  final Color iconBgColor;
  final Color iconColor;

  PlantAlertModel({
    required this.title,
    this.actionText,
    this.timeText,
    required this.iconAsset,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class FreightCarrierModel {
  final String title;
  final String loadsCount;
  final String status;
  final bool isOnTime;
  final String iconAsset;

  FreightCarrierModel({
    required this.title,
    required this.loadsCount,
    required this.status,
    required this.isOnTime,
    required this.iconAsset,
  });
}

class RecentShipperFileCardModel {
  final String projectCode;
  final String title;
  final String site;
  final String fileName;
  final String uploadDate;
  final String items;
  final String rates;
  final String weight;
  final String status;
  final BadgeStatusType statusType;

  RecentShipperFileCardModel({
    required this.projectCode,
    required this.title,
    required this.site,
    required this.fileName,
    required this.uploadDate,
    required this.items,
    required this.rates,
    required this.weight,
    required this.status,
    required this.statusType,
  });
}

class DrawingApprovalStatusModel {
  final String clientName;
  final String projectName;
  final String fileName;
  final String sentDate;
  final String status;
  final BadgeStatusType statusType;
  final String avatarInitial;

  DrawingApprovalStatusModel({
    required this.clientName,
    required this.projectName,
    required this.fileName,
    required this.sentDate,
    required this.status,
    required this.statusType,
    required this.avatarInitial,
  });
}
