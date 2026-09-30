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

  // Display ID: prefers human-readable deliveryNumber from API, never shows raw 24-char hex mongo ObjectId
  String get displayId {
    final num = deliveryNumber.trim();
    if (num.isNotEmpty && num != '-' && num != '—' && num != 'null') {
      return num;
    }
    if (id.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id)) {
      return 'DEL-${id.substring(id.length - 4).toUpperCase()}';
    }
    return id.isNotEmpty && id != '-' && id != '—' && id != 'null' ? id : 'DEL-0001';
  }

  // Backward compatibility getter for legacy `poc` string
  String get poc => pocName;
}
