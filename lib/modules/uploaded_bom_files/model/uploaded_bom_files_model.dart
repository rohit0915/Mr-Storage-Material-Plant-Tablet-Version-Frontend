class UploadedBomFileModel {
  final String id;
  final String project;
  final String uploadDate;
  final int items;
  final String status; // 'Pending', 'Shared to Shippers', 'Locked'
  bool isSelected;

  UploadedBomFileModel({
    required this.id,
    required this.project,
    required this.uploadDate,
    required this.items,
    required this.status,
    this.isSelected = false,
  });
}
