import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/widgets/common_snackbar.dart';
import '../../freight_loads/repository/delivery_repository.dart';
import '../model/all_delivery_model.dart';

class AllDeliveriesController extends GetxController {
  final DeliveryRepository repository;
  AllDeliveriesController({required this.repository});

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final selectedStatus = 'All Status'.obs;
  
  // Advanced Filter Toggle & Fields
  final isAdvancedFilterOpen = false.obs;
  final dateFrom = Rxn<DateTime>();
  final dateTo = Rxn<DateTime>();
  final selectedProject = 'All Project'.obs;
  final selectedCustomer = 'All Customer'.obs;
  final selectedVendor = 'All Vendor'.obs;
  final selectedCarrier = 'All Carriers'.obs;
  final selectedCategory = 'All Categories'.obs;
  final selectedEquipment = 'All Equipment'.obs;
  final selectedOwner = 'All Internal Owner'.obs;

  // Column Visibility Toggles
  final visibleColumns = <String, bool>{
    'Project': true,
    'Customer': true,
    'Vendor': true,
    'Carrier': true,
    'POC': true,
    'Date': true,
  }.obs;

  // Pagination State
  final currentPage = 1.obs;
  final itemsPerPage = 10.obs;

  final stats = <String, int>{
    'Draft': 1,
    'Total': 12,
    'Scheduled': 4,
    'Confirmed': 3,
    'In Transit': 3,
    'Delivered': 2,
    'Delayed': 1,
    'Cancelled': 1,
  }.obs;

  final deliveries = <AllDeliveryModel>[].obs;

  final statuses = const [
    'All Status',
    'Draft',
    'Scheduled',
    'Confirmed',
    'In Transit',
    'Delivered',
    'Delayed',
    'Cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void toggleAdvancedFilters() {
    isAdvancedFilterOpen.value = !isAdvancedFilterOpen.value;
  }

  void toggleColumn(String columnKey) {
    visibleColumns[columnKey] = !(visibleColumns[columnKey] ?? true);
  }

  void clearAllFilters() {
    searchQuery.value = '';
    selectedStatus.value = 'All Status';
    dateFrom.value = null;
    dateTo.value = null;
    selectedProject.value = 'All Project';
    selectedCustomer.value = 'All Customer';
    selectedVendor.value = 'All Vendor';
    selectedCarrier.value = 'All Carriers';
    selectedCategory.value = 'All Categories';
    selectedEquipment.value = 'All Equipment';
    selectedOwner.value = 'All Internal Owner';
    currentPage.value = 1;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        repository.allStats(),
        repository.allDeliveries(limit: 100),
      ]);

      final rawStats = results[0];
      if (rawStats.isNotEmpty) {
        stats.assignAll({
          'Draft': _int(rawStats['draft'] ?? 1),
          'Total': _int(
            results[1]['total'] ??
                rawStats.values.fold<num>(
                  0,
                  (sum, value) => sum + (value is num ? value : 0),
                ),
          ),
          'Scheduled': _int(rawStats['scheduled'] ?? 4),
          'Confirmed': _int(rawStats['confirmed'] ?? 3),
          'In Transit': _int(rawStats['inTransit'] ?? 3),
          'Delivered': _int(rawStats['delivered'] ?? 2),
          'Delayed': _int(rawStats['delayed'] ?? 1),
          'Cancelled': _int(rawStats['cancelled'] ?? 1),
        });
      }

      final raw = results[1]['deliveries'] is List
          ? results[1]['deliveries'] as List
          : const [];

      if (raw.isNotEmpty) {
        deliveries.assignAll(
          raw.whereType<Map>().map((entry) {
            final item = Map<String, dynamic>.from(entry);
            final project = _map(item['project'] ?? item['lead']);
            final customer = _map(item['customer']);
            final carrier = _map(item['carrier']);
            return AllDeliveryModel(
              id: _text(item['deliveryNumber'] ?? item['_id']),
              priority: _text(item['priority'] ?? 'Normal'),
              status: _status(item['status']),
              items: _text(item['description'] ?? item['itemsDescription'] ?? 'Steel Frame - Primary frame set'),
              project: _text(item['projectName'] ?? project['projectName'] ?? 'ABC Logistics Warehouse'),
              customer: _text(
                item['customerName'] ?? customer['name'] ?? customer['firstName'] ?? 'Austin McClume',
              ),
              vendor: _text(item['vendorName'] ?? 'Roof Masters Ltd.'),
              carrier: _text(
                item['carrierName'] ?? carrier['companyName'] ?? carrier['name'] ?? 'Rapid Delivery Services',
              ),
              pocName: _text(
                item['receivingName'] ??
                    item['pocName'] ??
                    item['internalOwnerName'] ??
                    'John Smith',
              ),
              pocPhone: _text(item['pocPhone'] ?? '0267554321'),
              pocEmail: _text(item['pocEmail'] ?? '0267554321'),
              deliveryDate: _date(item['deliveryDate']),
              equipment: _text(item['requiredEquipment'] ?? 'Flatbed'),
              site: _text(item['deliveryLocation'] ?? item['siteLocation'] ?? 'Warehouse Phase 2'),
            );
          }),
        );
      } else {
        _loadFallbackMockData();
      }
    } catch (error) {
      _loadFallbackMockData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadFallbackMockData() {
    deliveries.assignAll(const [
      AllDeliveryModel(
        id: 'DEL - 1812',
        priority: 'Normal',
        status: 'Delayed',
        deliveryDate: 'Apr 1, 2026',
        timeWindow: '07:30 - 11:30',
        items: 'Steel Frame - Primary frame set',
        project: 'ABC Logistics Warehouse',
        customer: 'Austin McClume',
        vendor: 'Roof Masters Ltd.',
        carrier: 'Rapid Delivery Services',
        pocName: 'POC John Smith',
        pocPhone: '0267554321',
        pocEmail: '0267554321',
        equipment: 'Flatbed',
        site: 'ABC Warehouse',
      ),
      AllDeliveryModel(
        id: 'DEL - 1810',
        priority: 'High',
        status: 'Delayed',
        deliveryDate: 'Mar 31, 2026',
        timeWindow: '11:00 - 15:00',
        items: 'Doors - Roll-up doors',
        project: 'Metro Cast Factory',
        customer: 'Sarah Williams',
        vendor: 'Climate Control Inc.',
        carrier: 'FastFreight Logistics',
        pocName: 'POC John Smith',
        pocPhone: '0267554321',
        pocEmail: '0267554321',
        equipment: 'Box Truck',
        site: 'Metro Site A',
      ),
      AllDeliveryModel(
        id: 'DEL - 1008',
        priority: 'Critical',
        status: 'Delivered',
        deliveryDate: 'Mar 30, 2026',
        timeWindow: '10:00 - 14:00',
        items: 'Steel Frame - Primary frame set',
        project: 'Warehouse Phase 2',
        customer: 'David Martinez',
        vendor: 'Panel Systems Inc.',
        carrier: 'Premier Transport Co.',
        pocName: 'POC John Smith',
        pocPhone: '0267554321',
        pocEmail: '0267554321',
        equipment: 'Flatbed Trailer',
        site: 'Phase 2 Site',
      ),
      AllDeliveryModel(
        id: 'DEL - 1007',
        priority: 'Normal',
        status: 'Delayed',
        deliveryDate: 'Mar 29, 2026',
        timeWindow: '08:00 - 12:00',
        items: 'Doors - Roll-up doors',
        project: 'Storage Facility B',
        customer: 'Patricia Davis',
        vendor: 'Fastener Wholesale',
        carrier: 'FastFreight Logistics',
        pocName: 'POC John Smith',
        pocPhone: '0267554321',
        pocEmail: '0267554321',
        equipment: 'Crane Truck',
        site: 'Storage B',
      ),
      AllDeliveryModel(
        id: 'DEL - 1004',
        priority: 'High',
        status: 'Draft',
        deliveryDate: 'Mar 28, 2026',
        timeWindow: '09:00 - 13:00',
        items: 'Steel Frame - Primary frame set',
        project: 'Industrial Park A',
        customer: 'Jennifer Lee',
        vendor: 'Steel Shippers Inc.',
        carrier: 'FastFreight Logistics',
        pocName: 'POC John Smith',
        pocPhone: '0267554321',
        pocEmail: '0267554321',
        equipment: 'Flatbed',
        site: 'Industrial Site A',
      ),
      AllDeliveryModel(
        id: 'DEL - 1003',
        priority: 'Critical',
        status: 'Cancelled',
        deliveryDate: 'Mar 27, 2026',
        timeWindow: '07:00 - 11:00',
        items: 'Doors - Roll-up doors',
        project: 'Warehouse Phase 2',
        customer: 'David Martinez',
        vendor: 'Insul-Pro Systems',
        carrier: 'Rapid Delivery Services',
        pocName: 'POC John Smith',
        pocPhone: '0267554321',
        pocEmail: '0267554321',
        equipment: 'Box Truck',
        site: 'Phase 2 Site',
      ),
      AllDeliveryModel(
        id: 'DEL - 1002',
        priority: 'Normal',
        status: 'Delivered',
        deliveryDate: 'Mar 26, 2026',
        timeWindow: '13:00 - 17:00',
        items: 'Steel Frame - Primary frame set',
        project: 'Metro Cast Factory',
        customer: 'Sarah Williams',
        vendor: 'Door Solutions Ltd.',
        carrier: 'Premier Transport Co.',
        pocName: 'POC John Smith',
        pocPhone: '0357554325',
        pocEmail: '0357554325',
        equipment: 'Flatbed',
        site: 'Metro Site',
      ),
      AllDeliveryModel(
        id: 'DEL - 1001',
        priority: 'High',
        status: 'Delayed',
        deliveryDate: 'Mar 25, 2026',
        timeWindow: '08:00 - 12:00',
        items: 'Doors - Roll-up doors',
        project: 'ABC Logistics Warehouse',
        customer: 'Austin McClume',
        vendor: 'Steel Shippers Inc.',
        carrier: 'FastFreight Logistics',
        pocName: 'POC John Smith',
        pocPhone: '0357554325',
        pocEmail: '0357554325',
        equipment: 'Box Truck',
        site: 'Warehouse Site',
      ),
      AllDeliveryModel(
        id: 'DEL - 1006',
        priority: 'Critical',
        status: 'Delivered',
        deliveryDate: 'Mar 25, 2026',
        timeWindow: '14:00 - 18:00',
        items: 'Steel Frame - Primary frame set',
        project: 'Factory Expansion',
        customer: 'Robert Chen',
        vendor: 'Entry Systems Corp',
        carrier: 'Rapid Delivery Services',
        pocName: 'POC John Smith',
        pocPhone: '0357554325',
        pocEmail: '0357554325',
        equipment: 'Flatbed',
        site: 'Factory Site',
      ),
      AllDeliveryModel(
        id: 'DEL - 1009',
        priority: 'Normal',
        status: 'Delivered',
        deliveryDate: 'Mar 24, 2026',
        timeWindow: '08:00 - 10:00',
        items: 'Doors - Roll-up doors',
        project: 'Construction Site C',
        customer: 'Michael Brown',
        vendor: 'Concrete Works Ltd.',
        carrier: 'Rapid Delivery Services',
        pocName: 'POC John Smith',
        pocPhone: '0357554325',
        pocEmail: '0357554325',
        equipment: 'Flatbed',
        site: 'Site C',
      ),
      AllDeliveryModel(
        id: 'DEL - 1011',
        priority: 'Normal',
        status: 'Scheduled',
        deliveryDate: 'Mar 23, 2026',
        timeWindow: '09:00 - 11:00',
        items: 'Wall Panels',
        project: 'Industrial Park A',
        customer: 'Jennifer Lee',
        vendor: 'Roof Masters Ltd.',
        carrier: 'FastFreight Logistics',
        pocName: 'POC John Smith',
        pocPhone: '0357554325',
        pocEmail: '0357554325',
        equipment: 'Box Truck',
        site: 'Industrial Site',
      ),
      AllDeliveryModel(
        id: 'DEL - 1012',
        priority: 'Normal',
        status: 'In Transit',
        deliveryDate: 'Mar 22, 2026',
        timeWindow: '10:00 - 12:00',
        items: 'Roofing Sheets',
        project: 'Storage Facility B',
        customer: 'Patricia Davis',
        vendor: 'Panel Systems Inc.',
        carrier: 'Rapid Delivery Services',
        pocName: 'POC John Smith',
        pocPhone: '0357554325',
        pocEmail: '0357554325',
        equipment: 'Flatbed',
        site: 'Storage B Site',
      ),
    ]);
  }

  List<AllDeliveryModel> get filteredDeliveries {
    final query = searchQuery.value.trim().toLowerCase();

    return deliveries.where((item) {
      final matchesQuery = query.isEmpty ||
          item.id.toLowerCase().contains(query) ||
          item.project.toLowerCase().contains(query) ||
          item.customer.toLowerCase().contains(query) ||
          item.items.toLowerCase().contains(query) ||
          item.vendor.toLowerCase().contains(query) ||
          item.carrier.toLowerCase().contains(query);

      final matchesStatus = selectedStatus.value == 'All Status' ||
          item.status.toLowerCase() == selectedStatus.value.toLowerCase();

      final matchesProject = selectedProject.value == 'All Project' ||
          item.project == selectedProject.value;

      final matchesCustomer = selectedCustomer.value == 'All Customer' ||
          item.customer == selectedCustomer.value;

      final matchesVendor = selectedVendor.value == 'All Vendor' ||
          item.vendor == selectedVendor.value;

      final matchesCarrier = selectedCarrier.value == 'All Carriers' ||
          item.carrier == selectedCarrier.value;

      final matchesEquipment = selectedEquipment.value == 'All Equipment' ||
          item.equipment == selectedEquipment.value;

      return matchesQuery &&
          matchesStatus &&
          matchesProject &&
          matchesCustomer &&
          matchesVendor &&
          matchesCarrier &&
          matchesEquipment;
    }).toList();
  }

  List<AllDeliveryModel> get paginatedDeliveries {
    final list = filteredDeliveries;
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    if (startIndex >= list.length) {
      return [];
    }
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
  }

  int get totalPages {
    final count = filteredDeliveries.length;
    if (count == 0) return 1;
    return (count / itemsPerPage.value).ceil();
  }

  void exportCSV() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Priority,Status,Delivery Date,Items,Project,Customer,Vendor,Carrier,POC');
    for (final item in filteredDeliveries) {
      buffer.writeln(
        '"${item.id}","${item.priority}","${item.status}","${item.deliveryDate}","${item.items}","${item.project}","${item.customer}","${item.vendor}","${item.carrier}","${item.pocName}"',
      );
    }

    // ignore: deprecated_member_use
    Share.share(
      buffer.toString(),
      subject: 'All_Deliveries_Export_${DateTime.now().millisecondsSinceEpoch}.csv',
    );

    CommonSnackbar.showSuccess(
      title: 'Export CSV',
      message: 'Deliveries data exported successfully!',
    );
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  String _text(dynamic value) => (value ?? '-').toString();
  String _date(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString())?.toLocal();
    return date == null ? 'Apr 1, 2026' : '${date.day}/${date.month}/${date.year}';
  }

  String _status(dynamic value) => (value ?? 'Scheduled')
      .toString()
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

