class ProjectPackingListSummaryModel {
  final String id;
  final String displayProjectId;
  final String projectName;
  final String listGeneratedDate;
  final int totalPackingList;
  bool isSelected;

  ProjectPackingListSummaryModel({
    required this.id,
    required this.displayProjectId,
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
  final int totalItems;
  final List<BundleListItemModel> bundleList;
  final Map<String, dynamic> rawData;
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
    this.totalItems = 0,
    this.bundleList = const [],
    this.rawData = const {},
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
  final String partNumber;
  final String items;
  final int quantity;
  final String length;
  final String unitWeight;
  final String status;

  BundleListItemModel({
    required this.id,
    required this.bundleId,
    required this.profile,
    required this.partNumber,
    required this.items,
    required this.quantity,
    required this.length,
    required this.unitWeight,
    required this.status,
  });
}
