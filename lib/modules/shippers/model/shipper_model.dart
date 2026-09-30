class ShipperModel {
  final String id;
  final String vendorCode;
  final String name;
  final String contactName;
  final String email;
  final String phone;
  final List<String> materialTypes;
  final int activeOrders;
  final int totalOrders;

  ShipperModel({
    required this.id,
    required this.vendorCode,
    required this.name,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.materialTypes,
    required this.activeOrders,
    required this.totalOrders,
  });
}

class VendorDetailsModel {
  final String vendorCode;
  final double rating;
  final String companyName;
  final String status;
  final String address;
  final String email;
  final String phone;
  final String vendorType;
  final String serviceCategory;
  final String yearsWorking;
  final int totalOrders;
  final int completedDeliveries;
  final int activeOrders;
  final String avgDeliveryTime;
  final String onTimeRate;
  final String notes;

  VendorDetailsModel({
    required this.vendorCode,
    required this.rating,
    required this.companyName,
    required this.status,
    required this.address,
    required this.email,
    required this.phone,
    required this.vendorType,
    required this.serviceCategory,
    required this.yearsWorking,
    required this.totalOrders,
    required this.completedDeliveries,
    required this.activeOrders,
    required this.avgDeliveryTime,
    required this.onTimeRate,
    this.notes = '',
  });
}

class VendorContactRoleModel {
  final String roleName;
  final String name;
  final String phone;

  VendorContactRoleModel({
    required this.roleName,
    required this.name,
    required this.phone,
  });
}

class VendorOrderHistoryModel {
  final String orderId;
  final String project;
  final String material;
  final String quantity;
  final String orderValue;
  final String status; // 'Delivered' or 'In Transit'

  VendorOrderHistoryModel({
    required this.orderId,
    this.project = '-',
    this.material = '-',
    this.quantity = '-',
    required this.orderValue,
    required this.status,
  });
}

class ComplianceCertificateModel {
  final String name;
  final String size;
  final String type;
  final String expiryDate;

  ComplianceCertificateModel({
    required this.name,
    required this.size,
    required this.type,
    required this.expiryDate,
  });
}
