class BundleDataModel {
  String bundleId;
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
    required this.profile,
    this.itemsCount = 1,
    required this.length,
    required this.unitWeight,
    this.status = 'Draft',
    this.partNumber = 'Z82516',
    this.qty = 72,
    this.description = 'Roof Purlin',
    this.unitWeightSingle = 68.62,
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
