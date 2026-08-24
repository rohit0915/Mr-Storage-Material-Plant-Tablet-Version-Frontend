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
  final double laborCost;
  final double additionalCost;
  final double materialCost;
  final String description;
  final String isFrameType;
  final String status;
  bool isSelected;

  ItemCostModel({
    required this.id,
    required this.partName,
    required this.partColor,
    required this.costUnit,
    this.mbsCost,
    this.currentMarketCost,
    this.laborCost = 0.0,
    this.additionalCost = 0.0,
    this.materialCost = 0.0,
    required this.description,
    this.isFrameType = 'Standard',
    this.status = 'Active',
    this.isSelected = false,
  });

  ItemCostModel copyWith({
    String? id,
    String? partName,
    String? partColor,
    String? costUnit,
    double? mbsCost,
    double? currentMarketCost,
    double? laborCost,
    double? additionalCost,
    double? materialCost,
    String? description,
    String? isFrameType,
    String? status,
    bool? isSelected,
  }) {
    return ItemCostModel(
      id: id ?? this.id,
      partName: partName ?? this.partName,
      partColor: partColor ?? this.partColor,
      costUnit: costUnit ?? this.costUnit,
      mbsCost: mbsCost ?? this.mbsCost,
      currentMarketCost: currentMarketCost ?? this.currentMarketCost,
      laborCost: laborCost ?? this.laborCost,
      additionalCost: additionalCost ?? this.additionalCost,
      materialCost: materialCost ?? this.materialCost,
      description: description ?? this.description,
      isFrameType: isFrameType ?? this.isFrameType,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
