class AllDeliveryModel {
  final String id;
  final String status;
  final String items;
  final String project;
  final String customer;
  final String vendor;
  final String carrier;
  final String poc;
  final String deliveryDate;
  final String equipment;
  final String site;

  const AllDeliveryModel({
    required this.id,
    required this.status,
    required this.items,
    required this.project,
    required this.customer,
    required this.vendor,
    required this.carrier,
    required this.poc,
    required this.deliveryDate,
    required this.equipment,
    required this.site,
  });
}
