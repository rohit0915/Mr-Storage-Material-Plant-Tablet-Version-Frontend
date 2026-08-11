class FreightCarrierMasterModel {
  final String id;
  final String name;
  final String carrierId;
  final String contact;
  final String email;
  final String phone;
  final int activeBids;
  final int totalBids;
  final int awardedCount;
  final String winRate;
  final String avgBid;
  final String respondsTime;
  final String status;
  final String serviceType;
  final String serviceArea;
  final String equipmentType;

  FreightCarrierMasterModel({
    required this.id,
    required this.name,
    required this.carrierId,
    required this.contact,
    required this.email,
    required this.phone,
    required this.activeBids,
    required this.totalBids,
    required this.awardedCount,
    required this.winRate,
    required this.avgBid,
    required this.respondsTime,
    required this.status,
    required this.serviceType,
    required this.serviceArea,
    required this.equipmentType,
  });
}
