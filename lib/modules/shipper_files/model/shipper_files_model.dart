class ProjectShipperFileModel {
  final String projectId;
  final String projectName;
  final String fileReceived;
  final int totalShipperFiles;
  bool isSelected;

  ProjectShipperFileModel({
    required this.projectId,
    required this.projectName,
    required this.fileReceived,
    required this.totalShipperFiles,
    this.isSelected = false,
  });
}

class ShipperFileItemModel {
  final String id;
  final String shipperName;
  final String fileName;
  final String uploadDate;
  final int items;
  final String rate;
  String status; // 'File Received', 'Compared', 'Revision Sent', 'Order Sent'
  final String avatarUrl;
  bool isSelected;

  ShipperFileItemModel({
    required this.id,
    required this.shipperName,
    required this.fileName,
    required this.uploadDate,
    required this.items,
    required this.rate,
    required this.status,
    this.avatarUrl = '',
    this.isSelected = false,
  });
}
