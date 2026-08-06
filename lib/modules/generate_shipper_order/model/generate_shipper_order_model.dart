class ShipperCardModel {
  final String id;
  final String name;
  final double rating;
  final String serviceArea;
  bool isSelected;

  ShipperCardModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.serviceArea,
    this.isSelected = false,
  });
}
