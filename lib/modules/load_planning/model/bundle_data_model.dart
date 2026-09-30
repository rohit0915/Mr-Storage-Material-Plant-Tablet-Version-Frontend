class BundleDataModel {
  String bundleId;
  final String recordId;
  final List<Map<String, dynamic>> items;
  String profile;
  int itemsCount;
  String length;
  double unitWeight;
  String status;
  String partNumber;
  int qty;
  String description;
  double unitWeightSingle;
  String handlingInstructions;
  String notes;
  bool isSelected;

  BundleDataModel({
    required this.bundleId,
    this.recordId = '',
    this.items = const [],
    required this.profile,
    this.itemsCount = 1,
    required this.length,
    required this.unitWeight,
    this.status = 'Draft',
    this.partNumber = '',
    this.qty = 0,
    this.description = '',
    this.unitWeightSingle = 0,
    this.handlingInstructions = '',
    this.notes = '',
    this.isSelected = true,
  });

  double get totalWeight => unitWeight;
}

class TruckLoadDataModel {
  String loadId;
  int bundlesCount;
  double totalWeight;
  int utilizationPercentage;
  String status;

  TruckLoadDataModel({
    required this.loadId,
    required this.bundlesCount,
    required this.totalWeight,
    required this.utilizationPercentage,
    this.status = 'Draft',
  });
}
