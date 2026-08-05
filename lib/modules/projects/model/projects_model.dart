import 'package:flutter/material.dart';

enum ProjectStatusType {
  approved,
  bomReady,
  shipperFileReceived,
}

class ProjectStatModel {
  final String title;
  final String count;
  final IconData? iconData;
  final String? iconAsset;
  final Color backgroundColor;

  ProjectStatModel({
    required this.title,
    required this.count,
    this.iconData,
    this.iconAsset,
    required this.backgroundColor,
  });
}

class ProjectItemModel {
  final String id;
  final String projectName;
  final String projectSubtitle;
  final String customerName;
  final String customerAvatarInitial;
  final String buildingsCount;
  final String status;
  final ProjectStatusType statusType;
  final String projectValue;
  final String chatCount;
  bool isSelected;

  ProjectItemModel({
    required this.id,
    required this.projectName,
    required this.projectSubtitle,
    required this.customerName,
    required this.customerAvatarInitial,
    required this.buildingsCount,
    required this.status,
    required this.statusType,
    required this.projectValue,
    required this.chatCount,
    this.isSelected = false,
  });
}
