class ItemCostSummaryModel {
  final double totalItemCost;
  final int totalItems;
  final int newAdded;

  ItemCostSummaryModel({
    required this.totalItemCost,
    required this.totalItems,
    required this.newAdded,
  });
}

class ItemCostModel {
  final String id;
  final String partName;
  final String partColor;
  final String costUnit;
  final double? mbsCost;
  final double? currentMarketCost;
  final String description;
  bool isSelected;

  ItemCostModel({
    required this.id,
    required this.partName,
    required this.partColor,
    required this.costUnit,
    this.mbsCost,
    this.currentMarketCost,
    required this.description,
    this.isSelected = false,
  });

  ItemCostModel copyWith({
    String? id,
    String? partName,
    String? partColor,
    String? costUnit,
    double? mbsCost,
    double? currentMarketCost,
    String? description,
    bool? isSelected,
  }) {
    return ItemCostModel(
      id: id ?? this.id,
      partName: partName ?? this.partName,
      partColor: partColor ?? this.partColor,
      costUnit: costUnit ?? this.costUnit,
      mbsCost: mbsCost ?? this.mbsCost,
      currentMarketCost: currentMarketCost ?? this.currentMarketCost,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
