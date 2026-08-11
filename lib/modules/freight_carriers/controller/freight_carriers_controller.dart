import 'package:get/get.dart';
import '../model/freight_carrier_master_model.dart';

class FreightCarriersController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  final RxList<FreightCarrierMasterModel> carriers = <FreightCarrierMasterModel>[].obs;
  final RxList<FreightCarrierMasterModel> filteredCarriers = <FreightCarrierMasterModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialCarriers();
  }

  void _loadInitialCarriers() {
    isLoading.value = true;
    final list = [
      FreightCarrierMasterModel(
        id: '1',
        name: 'IronHaul Logistics',
        carrierId: 'CAR-001',
        contact: 'James Wilson',
        email: 'james@expressfreight.com',
        phone: '(555) 777-8888',
        activeBids: 4,
        totalBids: 89,
        awardedCount: 67,
        winRate: '75% win rate',
        avgBid: '\$2,850',
        respondsTime: 'Responds within 45 min',
        status: 'Active',
        serviceType: 'Freight Transport',
        serviceArea: 'Texas, Oklahoma',
        equipmentType: 'Flatbed, Dry Van',
      ),
      FreightCarrierMasterModel(
        id: '2',
        name: 'Nationwide Logistics',
        carrierId: 'CAR-002',
        contact: 'Patricia Davis',
        email: 'patricia@nationwidelogistics.com',
        phone: '(555) 888-9999',
        activeBids: 6,
        totalBids: 134,
        awardedCount: 102,
        winRate: '76% win rate',
        avgBid: '\$3,200',
        respondsTime: 'Responds within 45 min',
        status: 'Active',
        serviceType: 'Heavy Material Transport',
        serviceArea: 'Texas, Louisiana',
        equipmentType: 'Flatbed',
      ),
      FreightCarrierMasterModel(
        id: '3',
        name: 'Regional Transport Co.',
        carrierId: 'CAR-003',
        contact: 'Carlos Rodriguez',
        email: 'carlos@regionaltransport.com',
        phone: '(555) 999-0000',
        activeBids: 3,
        totalBids: 56,
        awardedCount: 42,
        winRate: '75% win rate',
        avgBid: '\$1,950',
        respondsTime: 'Responds within 45 min',
        status: 'Active',
        serviceType: 'Construction Freight',
        serviceArea: 'Texas, New Mexico',
        equipmentType: 'Dry Van',
      ),
      FreightCarrierMasterModel(
        id: '4',
        name: 'Metro Hauling Services',
        carrierId: 'CAR-004',
        contact: 'Susan Lee',
        email: 'susan@metrohauling.com',
        phone: '(555) 000-1111',
        activeBids: 2,
        totalBids: 45,
        awardedCount: 34,
        winRate: '76% win rate',
        avgBid: '\$4,100',
        respondsTime: 'Responds within 45 min',
        status: 'Active',
        serviceType: 'Steel & Equipment Transport',
        serviceArea: 'Multi-State',
        equipmentType: 'Flatbed, Heavy Haul',
      ),
      FreightCarrierMasterModel(
        id: '5',
        name: 'Budget Carriers Inc.',
        carrierId: 'CAR-005',
        contact: 'Mark Thompson',
        email: 'mark@budgetcarriers.com',
        phone: '(555) 111-2222',
        activeBids: 0,
        totalBids: 28,
        awardedCount: 8,
        winRate: '29% win rate',
        avgBid: '\$1,500',
        respondsTime: 'Responds within 45 min',
        status: 'Inactive',
        serviceType: 'Long Distance Freight',
        serviceArea: 'Multi-State',
        equipmentType: 'Flatbed, Heavy Haul',
      ),
    ];

    carriers.assignAll(list);
    filteredCarriers.assignAll(list);
    isLoading.value = false;
  }

  void filterCarriers(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      filteredCarriers.assignAll(carriers);
    } else {
      final q = query.toLowerCase();
      filteredCarriers.assignAll(
        carriers.where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.carrierId.toLowerCase().contains(q) ||
            item.contact.toLowerCase().contains(q) ||
            item.email.toLowerCase().contains(q) ||
            item.phone.toLowerCase().contains(q) ||
            item.serviceType.toLowerCase().contains(q) ||
            item.serviceArea.toLowerCase().contains(q) ||
            item.equipmentType.toLowerCase().contains(q) ||
            item.status.toLowerCase().contains(q)),
      );
    }
  }
}
