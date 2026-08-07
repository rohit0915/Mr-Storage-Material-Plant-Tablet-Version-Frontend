class ComparisonResultItemModel {
  final String partNumber;
  final String description;
  final String orderedQty;
  final String shippedQty;
  final String difference;
  final String reason;

  ComparisonResultItemModel({
    required this.partNumber,
    required this.description,
    required this.orderedQty,
    required this.shippedQty,
    required this.difference,
    this.reason = '',
  });
}
