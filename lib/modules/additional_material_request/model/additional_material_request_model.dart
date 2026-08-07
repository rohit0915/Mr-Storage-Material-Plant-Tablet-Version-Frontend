class MaterialInventoryItemModel {
  final String id;
  final String material;
  final String category;
  final String qnt;
  final String updated;
  bool isApproved;

  MaterialInventoryItemModel({
    required this.id,
    required this.material,
    required this.category,
    required this.qnt,
    required this.updated,
    this.isApproved = false,
  });
}
