class AllDeliveryModel {
  final String id;
  final String deliveryNumber;
  final String priority; // Normal, High, Critical
  final String status; // Draft, Scheduled, Confirmed, In Transit, Delivered, Delayed, Cancelled
  final String deliveryDate;
  final String timeWindow;
  final String items;
  final String project;
  final String customer;
  final String vendor;
  final String carrier;
  final String pocName;
  final String pocPhone;
  final String pocEmail;
  final String equipment;
  final String site;
  final String internalOwner;
  final String category;

  const AllDeliveryModel({
    required this.id,
    this.deliveryNumber = '',
    this.priority = '—',
    required this.status,
    required this.deliveryDate,
    this.timeWindow = '—',
    required this.items,
    required this.project,
    required this.customer,
    required this.vendor,
    required this.carrier,
    required this.pocName,
    this.pocPhone = '—',
    this.pocEmail = '—',
    required this.equipment,
    required this.site,
    this.internalOwner = '—',
    this.category = '—',
  });

  // Backward compatibility getter for legacy `poc` string
  String get poc => pocName;
}

