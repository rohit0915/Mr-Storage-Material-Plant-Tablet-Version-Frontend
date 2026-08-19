class ComparisonResultItemModel {
  final String partNumber;
  final String description;
  final String orderedQty;
  final String shippedQty;
  final String difference;
  final String reason;
  final String category; // 'matched', 'part_missing', 'not_match', 'extra_items'

  ComparisonResultItemModel({
    required this.partNumber,
    required this.description,
    required this.orderedQty,
    required this.shippedQty,
    required this.difference,
    this.reason = '',
    this.category = 'extra_items',
  });

  String get statusDisplay {
    switch (category) {
      case 'matched':
        return 'Matched';
      case 'part_missing':
        return 'Part Missing';
      case 'not_match':
        return 'Not Match';
      case 'extra_items':
      default:
        return 'Extra Item';
    }
  }
}
