class ProjectQrLabelsSummaryModel {
  final String id;
  final String projectName;
  final String qrGeneratedDate;
  final int totalQrLabels;
  bool isSelected;

  ProjectQrLabelsSummaryModel({
    required this.id,
    required this.projectName,
    required this.qrGeneratedDate,
    required this.totalQrLabels,
    this.isSelected = false,
  });
}

class BundleQrLabelItemModel {
  final String bundleId;
  final String loadId;
  final String parts;
  final String weight;
  final String length;
  final String status; // 'Printed' or 'Generated'
  final String shipper;
  bool isSelected;

  BundleQrLabelItemModel({
    required this.bundleId,
    required this.loadId,
    required this.parts,
    required this.weight,
    required this.length,
    required this.status,
    this.shipper = 'SHP-1044',
    this.isSelected = false,
  });
}
