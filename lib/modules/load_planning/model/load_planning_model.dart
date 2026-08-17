class ProjectLoadPlanningSummaryModel {
  final String id;
  final String displayProjectId;
  final String projectName;
  final String fileReceived;
  final int totalLoadPlanning;
  bool isSelected;

  ProjectLoadPlanningSummaryModel({
    required this.id,
    required this.displayProjectId,
    required this.projectName,
    required this.fileReceived,
    required this.totalLoadPlanning,
    this.isSelected = false,
  });
}

class LoadPlanItemModel {
  final String loadPlanId;
  final String shipperReference;
  final String vendorName;
  final String vendorAvatar;
  final int bundles;
  final int loads;
  final String weight;
  final String status;
  final String date;
  bool isSelected;

  LoadPlanItemModel({
    required this.loadPlanId,
    required this.shipperReference,
    required this.vendorName,
    required this.vendorAvatar,
    required this.bundles,
    required this.loads,
    required this.weight,
    required this.status,
    required this.date,
    this.isSelected = false,
  });
}
