class AwardedLoadItemModel {
  final String id;
  final String requestId;
  final String requestedDate;
  final String subStatus; // 'Confirmed', 'Delivered', 'Loaded'
  final String project;
  final String description;
  final String pickupLocation;
  final String deliveryLocation;
  final String pickupDate;
  final String deliveryDate;
  final String carrierName;
  final String carrierPhone;
  final String budget;
  final String awardedAmount;
  final int bidsCount;
  final String status; // 'Confirmed', 'Delivered', 'Loaded', 'Awarded'
  final String loadWeight;
  final String packageCount;
  final String internalOwner;
  bool isSelected;

  AwardedLoadItemModel({
    required this.id,
    required this.requestId,
    required this.requestedDate,
    required this.subStatus,
    required this.project,
    required this.description,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDate,
    required this.deliveryDate,
    required this.carrierName,
    required this.carrierPhone,
    required this.budget,
    required this.awardedAmount,
    required this.bidsCount,
    this.status = 'Confirmed',
    this.loadWeight = '-',
    this.packageCount = '',
    this.internalOwner = '—',
    this.isSelected = false,
  });
}
