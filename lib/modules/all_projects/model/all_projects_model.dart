class UserProfileHeaderModel {
  final String name;
  final String id;
  final String status;
  final String joinedDate;
  final String phone;
  final String email;
  final String address;

  UserProfileHeaderModel({
    required this.name,
    required this.id,
    required this.status,
    required this.joinedDate,
    required this.phone,
    required this.email,
    required this.address,
  });
}

enum AllProjectStatusType {
  workInProgress,
  active,
  completed,
  canceled,
}

class AllProjectRowModel {
  final String id;
  final String projectName;
  final String buildingCount;
  final String startDate;
  final String stage;
  final String progress;
  final String status;
  final AllProjectStatusType statusType;
  bool isSelected;

  AllProjectRowModel({
    required this.id,
    required this.projectName,
    required this.buildingCount,
    required this.startDate,
    required this.stage,
    required this.progress,
    required this.status,
    required this.statusType,
    this.isSelected = false,
  });
}
