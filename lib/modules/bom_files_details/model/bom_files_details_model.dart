class BomSummaryModel {
  final int totalItems;
  final String totalWeight;
  final String totalPanelsArea;

  BomSummaryModel({
    required this.totalItems,
    required this.totalWeight,
    required this.totalPanelsArea,
  });
}

class MissingItemCostSummaryModel {
  final double totalAmount;
  final int missingItemQty;

  MissingItemCostSummaryModel({
    required this.totalAmount,
    required this.missingItemQty,
  });
}

class BomItemModel {
  final int qty;
  final String mark;
  final String description;
  final String part;
  final String color;
  final String angle;
  final String thick;
  final String length;
  final String weight;
  final String amount;
  final bool isMissing;

  BomItemModel({
    required this.qty,
    required this.mark,
    required this.description,
    required this.part,
    required this.color,
    required this.angle,
    required this.thick,
    required this.length,
    required this.weight,
    required this.amount,
    this.isMissing = false,
  });
}
