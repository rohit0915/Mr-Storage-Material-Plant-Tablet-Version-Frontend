class DeliveryDetailsModel {
  final String deliveryId;
  final String title;
  final String status;
  final String projectName;
  final String customer;
  final String deliveryDate;
  final String timeWindow;
  final String siteAddress;
  final String description;
  final String materialCategory;
  final String pickupDate;
  final String vendorName;
  final String vendorContact;
  final String vendorPhone;
  final String vendorEmail;
  final String deliveryCompany;
  final String carrierContact;
  final String carrierPhone;
  final String internalOwner;
  final String internalContact;
  final String priority;
  final String deliveryType;
  final String quantity;
  final String siteInstructions;
  final String requiredEquipment;
  final String equipmentStatus;
  final String specialNotes;
  final String freightLoadId;
  final String awardedCarrier;
  final String price;
  final String receivingName;
  final String receivingPhone;
  final String receivingEmail;

  DeliveryDetailsModel({
    required this.deliveryId,
    required this.title,
    required this.status,
    required this.projectName,
    required this.customer,
    required this.deliveryDate,
    required this.timeWindow,
    required this.siteAddress,
    required this.description,
    required this.materialCategory,
    required this.pickupDate,
    required this.vendorName,
    required this.vendorContact,
    required this.vendorPhone,
    required this.vendorEmail,
    required this.deliveryCompany,
    required this.carrierContact,
    required this.carrierPhone,
    required this.internalOwner,
    required this.internalContact,
    required this.priority,
    required this.deliveryType,
    required this.quantity,
    required this.siteInstructions,
    required this.requiredEquipment,
    required this.equipmentStatus,
    required this.specialNotes,
    required this.freightLoadId,
    required this.awardedCarrier,
    required this.price,
    required this.receivingName,
    required this.receivingPhone,
    required this.receivingEmail,
  });
}

class StatusHistoryItem {
  final String title;
  final String timestamp;
  final String description;
  final bool isCurrent;

  StatusHistoryItem({
    required this.title,
    required this.timestamp,
    required this.description,
    this.isCurrent = false,
  });
}

class NotificationHistoryItem {
  final String title;
  final String subtitle;
  final String timestamp;
  final String status;

  NotificationHistoryItem({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.status,
  });
}
