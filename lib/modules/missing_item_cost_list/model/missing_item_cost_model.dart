class MissingItemCostModel {
  final String id;
  final String category;
  final String partName;
  final String partColor;
  final String costUnit;
  final String costStatus;
  final double? currentMarketCost;
  final String description;
  bool isSelected;

  MissingItemCostModel({
    required this.id,
    this.category = '',
    required this.partName,
    required this.partColor,
    required this.costUnit,
    this.costStatus = 'Missing',
    this.currentMarketCost,
    required this.description,
    this.isSelected = false,
  });
}
