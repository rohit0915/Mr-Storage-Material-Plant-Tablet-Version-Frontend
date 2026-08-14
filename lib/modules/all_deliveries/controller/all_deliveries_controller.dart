import 'package:get/get.dart';

import '../../freight_loads/repository/delivery_repository.dart';
import '../model/all_delivery_model.dart';

class AllDeliveriesController extends GetxController {
  final DeliveryRepository repository;
  AllDeliveriesController({required this.repository});

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final selectedStatus = 'All Status'.obs;
  final stats = <String, int>{}.obs;
  final deliveries = <AllDeliveryModel>[].obs;
  final statuses = const [
    'All Status',
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

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        repository.allStats(),
        repository.allDeliveries(limit: 100),
      ]);
      final rawStats = results[0];
      stats.assignAll({
        'Total': _int(
          results[1]['total'] ??
              rawStats.values.fold<num>(
                0,
                (sum, value) => sum + (value is num ? value : 0),
              ),
        ),
        'Scheduled': _int(rawStats['scheduled']),
        'Confirmed': _int(rawStats['confirmed']),
        'In Transit': _int(rawStats['inTransit']),
        'Delivered': _int(rawStats['delivered']),
        'Delayed': _int(rawStats['delayed']),
        'Cancelled': _int(rawStats['cancelled']),
      });
      final raw = results[1]['deliveries'] is List
          ? results[1]['deliveries'] as List
          : const [];
      deliveries.assignAll(
        raw.whereType<Map>().map((entry) {
          final item = Map<String, dynamic>.from(entry);
          final project = _map(item['project'] ?? item['lead']);
          final customer = _map(item['customer']);
          final carrier = _map(item['carrier']);
          return AllDeliveryModel(
            id: _text(item['deliveryNumber'] ?? item['_id']),
            status: _status(item['status']),
            items: _text(item['description'] ?? item['itemsDescription']),
            project: _text(item['projectName'] ?? project['projectName']),
            customer: _text(
              item['customerName'] ?? customer['name'] ?? customer['firstName'],
            ),
            vendor: _text(item['vendorName']),
            carrier: _text(
              item['carrierName'] ?? carrier['companyName'] ?? carrier['name'],
            ),
            poc: _text(
              item['receivingName'] ??
                  item['pocName'] ??
                  item['internalOwnerName'],
            ),
            deliveryDate: _date(item['deliveryDate']),
            equipment: _text(item['requiredEquipment']),
            site: _text(item['deliveryLocation'] ?? item['siteLocation']),
          );
        }),
      );
    } catch (error) {
      errorMessage.value = error.toString();
      deliveries.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<AllDeliveryModel> get filteredDeliveries {
    final query = searchQuery.value.trim().toLowerCase();
    return deliveries
        .where(
          (item) =>
              (selectedStatus.value == 'All Status' ||
                  item.status == selectedStatus.value) &&
              (query.isEmpty ||
                  item.id.toLowerCase().contains(query) ||
                  item.project.toLowerCase().contains(query) ||
                  item.customer.toLowerCase().contains(query) ||
                  item.items.toLowerCase().contains(query)),
        )
        .toList();
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  String _text(dynamic value) => (value ?? '-').toString();
  String _date(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString())?.toLocal();
    return date == null ? '-' : '${date.day}/${date.month}/${date.year}';
  }

  String _status(dynamic value) => (value ?? 'Unknown')
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
