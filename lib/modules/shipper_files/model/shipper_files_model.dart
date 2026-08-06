class ShipperFileItemModel {
  final String id;
  final String shipperName;
  final String fileName;
  final String uploadDate;
  final int items;
  final String rate;
  final String status; // 'Pending', 'Approved', 'Compared'
  final String avatarUrl;

  ShipperFileItemModel({
    required this.id,
    required this.shipperName,
    required this.fileName,
    required this.uploadDate,
    required this.items,
    required this.rate,
    required this.status,
    this.avatarUrl = '',
  });
}
