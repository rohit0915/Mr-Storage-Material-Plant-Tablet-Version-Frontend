class ProjectPackingListSummaryModel {
  final String id;
  final String projectName;
  final String listGeneratedDate;
  final int totalPackingList;
  bool isSelected;

  ProjectPackingListSummaryModel({
    required this.id,
    required this.projectName,
    required this.listGeneratedDate,
    required this.totalPackingList,
    this.isSelected = false,
  });
}

class PackingListItemModel {
  final String packingId;
  final String loadId;
  final String truck;
  final int bundles;
  final String weight;
  final String destination;
  final String date;
  final String status;
  bool isSelected;

  PackingListItemModel({
    required this.packingId,
    required this.loadId,
    required this.truck,
    required this.bundles,
    required this.weight,
    required this.destination,
    required this.date,
    required this.status,
    this.isSelected = false,
  });
}

class PackingListTableItemModel {
  final int id;
  final String loadId;
  final String truck;
  final int bundles;
  final String weight;
  final String destination;
  final String status;

  PackingListTableItemModel({
    required this.id,
    required this.loadId,
    required this.truck,
    required this.bundles,
    required this.weight,
    required this.destination,
    required this.status,
  });
}

class BundleListItemModel {
  final int id;
  final String bundleId;
  final String profile;
  final String items;
  final String length;
  final String unitWeight;

  BundleListItemModel({
    required this.id,
    required this.bundleId,
    required this.profile,
    required this.items,
    required this.length,
    required this.unitWeight,
  });
}
