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
  });
}
