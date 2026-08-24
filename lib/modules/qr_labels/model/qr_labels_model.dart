class ProjectQrLabelsSummaryModel {
  final String id;
  final String displayProjectId;
  final String projectName;
  final String qrGeneratedDate;
  final int totalQrLabels;
  bool isSelected;

  ProjectQrLabelsSummaryModel({
    required this.id,
    required this.displayProjectId,
    required this.projectName,
    required this.qrGeneratedDate,
    required this.totalQrLabels,
    this.isSelected = false,
  });
}

class BundleItemDetailModel {
  final String partNumber;
  final String description;
  final int quantity;
  final String length;
  final String weight;
  final String status;

  BundleItemDetailModel({
    required this.partNumber,
    required this.description,
    required this.quantity,
    required this.length,
    required this.weight,
    required this.status,
  });
}

class BundleQrLabelItemModel {
  final String bundleId;
  final String loadId;
  final String parts;
  final String weight;
  final String length;
  final String status;
  final String shipper;
  final int totalQty;
  final List<BundleItemDetailModel> items;
  bool isSelected;

  BundleQrLabelItemModel({
    required this.bundleId,
    required this.loadId,
    required this.parts,
    required this.weight,
    required this.length,
    required this.status,
    this.shipper = 'SHP-1044',
    this.totalQty = 0,
    this.items = const [],
    this.isSelected = false,
  });
}

class PackingListQrItemModel {
  final String packingId; // PL-001
  final String loadId; // PLP-0006
  final String truck; // 53 ft Semi
  final int bundlesCount; // 18
  final int totalItemsCount; // 36
  final String weight; // 44,651.8 LBS
  final String status; // confirmed
  final String shipper; // PLP-0006
  final String qrUrl;
  final List<BundleQrLabelItemModel> bundles;
  bool isSelected;

  PackingListQrItemModel({
    required this.packingId,
    required this.loadId,
    required this.truck,
    required this.bundlesCount,
    this.totalItemsCount = 0,
    required this.weight,
    required this.status,
    this.shipper = 'PLP-0006',
    this.qrUrl = '',
    this.bundles = const [],
    this.isSelected = false,
  });
}
