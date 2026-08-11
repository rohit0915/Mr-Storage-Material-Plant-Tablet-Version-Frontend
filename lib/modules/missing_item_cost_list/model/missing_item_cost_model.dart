class MissingItemCostModel {
  final String id;
  final String partName;
  final String partColor;
  final String costUnit;
  final String costStatus;
  final double? currentMarketCost;
  final String description;
  bool isSelected;

  MissingItemCostModel({
    required this.id,
    required this.partName,
    required this.partColor,
    required this.costUnit,
    this.costStatus = 'Missing',
    this.currentMarketCost,
    required this.description,
    this.isSelected = false,
  });
}
