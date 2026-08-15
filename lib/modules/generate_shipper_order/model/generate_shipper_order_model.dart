class ShipperCardModel {
  final String id;
  final String name;
  final double rating;
  final String serviceArea;
  final bool isSent;
  final String sentAt;
  bool isSelected;

  ShipperCardModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.serviceArea,
    this.isSent = false,
    this.sentAt = '',
    this.isSelected = false,
  });
}
