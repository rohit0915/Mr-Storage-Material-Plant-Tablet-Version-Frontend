
class DeliveryCalendarItemModel {
  final String id;
  final String title;
  final String project;
  final String customer;
  final String timeWindow;
  final String receivingContact;
  final String vendor;
  final String siteLocation;
  final String requiredEquipment;
  final String internalOwner;
  final String carrier;
  final String freightLoadId;
  final String status;
  final bool isCriticalPath;
  final bool isEquipmentConflict;
  final DateTime date;

  DeliveryCalendarItemModel({
    required this.id,
    required this.title,
    required this.project,
    required this.customer,
    required this.timeWindow,
    required this.receivingContact,
    required this.vendor,
    required this.siteLocation,
    required this.requiredEquipment,
    required this.internalOwner,
    required this.carrier,
    required this.freightLoadId,
    required this.status,
    this.isCriticalPath = false,
    this.isEquipmentConflict = false,
    required this.date,
  });
}
