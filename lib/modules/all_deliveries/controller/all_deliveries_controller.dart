import 'package:get/get.dart';
import '../../../app/services/file_export_service.dart';

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

  final stats = <String, int>{}.obs;

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
      final data = await repository.allDeliveries(limit: 100);
      final rawStats = _map(data['stats']);
      stats.assignAll({
        'Draft': _int(rawStats['draft']), 'Total': _int(rawStats['total'] ?? data['total']),
        'Scheduled': _int(rawStats['scheduled']), 'Confirmed': _int(rawStats['confirmed']),
        'In Transit': _int(rawStats['inTransit']), 'Delivered': _int(rawStats['delivered']),
        'Delayed': _int(rawStats['delayed']), 'Cancelled': _int(rawStats['cancelled']),
      });
      final all = <dynamic>[...?data['deliveries'] as List?];
      var page = 1;
      while (all.length < _int(data['total'])) {
        final next = await repository.allDeliveries(page: ++page, limit: 100);
        final rows = next['deliveries'] as List? ?? [];
        if (rows.isEmpty) break;
        all.addAll(rows);
      }
      final raw = all;
      if (raw.isNotEmpty) {
        deliveries.assignAll(
          raw.whereType<Map>().map((entry) {
            final item = Map<String, dynamic>.from(entry);
            final project = _map(item['leadId'] ?? item['project'] ?? item['lead']);
            final customer = _map(project['customerId'] ?? item['customer']);
            final carrier = _map(_map(item['selectedCarrierBidId'])['carrierId'] ?? item['carrier']);
            return AllDeliveryModel(
              id: _text(item['_id']),
              deliveryNumber: _text(item['deliveryNumber']),
              timeWindow: _text(item['timings']),
              internalOwner: _text(item['internalOwnerName']),
              category: _text(item['materialType']),
              priority: _text(item['priority']),
              status: _status(item['status']),
              items: _text(item['description'] ?? item['itemsDescription']),
              project: _text(item['projectName'] ?? project['projectName']),
              customer: _text(
                item['customerName'] ?? customer['name'] ?? customer['firstName'],
              ),
              vendor: _text(item['vendorName']),
              carrier: _text(
                item['carrierName'] ?? carrier['carrierName'] ?? carrier['companyName'] ?? carrier['name'],
              ),
              pocName: _text(
                item['receivingPoc'] ?? item['receivingName'] ??
                    item['pocName'] ??
                    item['internalOwnerName'],
              ),
              pocPhone: _text(item['pocPhone'] ?? item['pickupContactPhone']),
              pocEmail: _text(item['receivingPocEmail'] ?? item['pocEmail']),
              deliveryDate: _date(item['deliveryDate']),
              equipment: _text(item['requiredEquipment'] ?? (item['loadingEquipment'] is List ? (item['loadingEquipment'] as List).join(', ') : null)),
              site: _text(item['deliveryLocation'] ?? item['siteLocation']),
            );
          }),
        );
      } else {
        deliveries.clear();
      }
    } catch (error) {
      deliveries.clear();
      stats.clear();
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
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

  Future<void> exportCSV() async {
    try {
      await FileExportService.saveCsv(fileName: 'all_deliveries', rows: [
        ['ID','Priority','Status','Date','Items','Project','Customer','Vendor','Carrier','POC'],
        ...filteredDeliveries.map((item) => [item.deliveryNumber,item.priority,item.status,item.deliveryDate,item.items,item.project,item.customer,item.vendor,item.carrier,item.pocName]),
      ]);
      CommonSnackbar.showSuccess(title: 'Export CSV', message: 'Deliveries file saved.');
    } catch (error) {
      CommonSnackbar.showError(title: 'Export failed', message: error.toString());
    }
  }

  List<String> options(String all, String Function(AllDeliveryModel) field) =>
      [all, ...deliveries.map(field).where((value) => value.isNotEmpty && value != '-').toSet().toList()..sort()];

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  String _text(dynamic value) => (value ?? '-').toString();
  String _date(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString())?.toLocal();
    return date == null ? '—' : '${date.day}/${date.month}/${date.year}';
  }

  String _status(dynamic value) => (value ?? '—')
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

