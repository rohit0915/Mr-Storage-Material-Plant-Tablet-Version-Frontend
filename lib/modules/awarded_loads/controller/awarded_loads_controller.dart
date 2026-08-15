import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../freight_loads/model/freight_loads_model.dart';
import '../../freight_loads/repository/delivery_repository.dart';
import '../model/awarded_loads_model.dart';
import '../widgets/freight_filter_dialog.dart';

class AwardedLoadsController extends GetxController {
  final DeliveryRepository repository;
  AwardedLoadsController({required this.repository});

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<FreightLoadSummaryStatModel> summaryStats =
      <FreightLoadSummaryStatModel>[].obs;
  final RxList<AwardedLoadItemModel> awardedLoadsList =
      <AwardedLoadItemModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = ''.obs;

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
        repository.awardedStats(),
        repository.awardedLoads(
          search: searchQuery.value,
          status: selectedStatus.value,
        ),
      ]);
      final stats = results[0];
      summaryStats.assignAll([
        _stat(
          'Total Awarded',
          stats['total'],
          const Color(0xFF16A34A),
          Icons.workspace_premium_outlined,
        ),
        _stat(
          'In Transit',
          stats['inTransit'],
          const Color(0xFFEA580C),
          Icons.local_shipping_outlined,
        ),
        _stat(
          'Delivered',
          stats['delivered'],
          const Color(0xFF16A34A),
          Icons.check_circle_outline,
        ),
        _stat(
          'Total Spent',
          _money(stats['totalSpent']),
          const Color(0xFF2563EB),
          Icons.attach_money,
        ),
      ]);
      _mapLoads(results[1]);
    } catch (error) {
      errorMessage.value = error.toString();
      summaryStats.clear();
      awardedLoadsList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _mapLoads(Map<String, dynamic> data) {
    final raw = data['deliveries'] is List
        ? data['deliveries'] as List
        : const [];
    awardedLoadsList.assignAll(
      raw.whereType<Map>().map((entry) {
        final item = Map<String, dynamic>.from(entry);
        final project = _map(item['project'] ?? item['lead']);
        final carrier = _map(item['carrier'] ?? item['awardedCarrier']);
        return AwardedLoadItemModel(
          requestId: _text(
            item['deliveryNumber'] ?? item['requestId'] ?? item['_id'],
          ),
          requestedDate: _date(item['requestedAt'] ?? item['createdAt']),
          subStatus: _status(item['status']),
          project: _text(item['projectName'] ?? project['projectName']),
          description: _text(item['description'] ?? item['itemDescription']),
          pickupLocation: _text(item['pickupLocation']),
          deliveryLocation: _text(
            item['deliveryLocation'] ?? item['siteLocation'],
          ),
          pickupDate: _date(item['pickupDate']),
          deliveryDate: _date(item['deliveryDate']),
          carrierName: _text(
            item['carrierName'] ?? carrier['companyName'] ?? carrier['name'],
          ),
          carrierPhone: _text(item['carrierPhone'] ?? carrier['phone']),
          budget: _money(item['budget'] ?? item['price']),
          awardedAmount: _money(item['awardedAmount'] ?? item['price']),
          bidsCount: _int(item['bidCount'] ?? item['bidsCount']),
          status: _status(item['status']),
        );
      }),
    );
  }

  List<AwardedLoadItemModel> get filteredAwardedLoads {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return awardedLoadsList;
    return awardedLoadsList
        .where(
          (item) =>
              item.requestId.toLowerCase().contains(query) ||
              item.project.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query) ||
              item.carrierName.toLowerCase().contains(query),
        )
        .toList();
  }

  void openFreightRequestDetails(AwardedLoadItemModel item) => Get.toNamed(
    AppRoutes.freightRequestDetails,
    parameters: {'id': item.requestId},
  );

  void showFilterDialog() => Get.dialog(
    FreightFilterDialog(
      onApplyStatus: (status) {
        selectedStatus.value = status ?? '';
        loadData();
      },
    ),
  );

  FreightLoadSummaryStatModel _stat(
    String label,
    dynamic value,
    Color color,
    IconData icon,
  ) => FreightLoadSummaryStatModel(
    label: label,
    value: value?.toString() ?? '0',
    themeColor: color,
    icon: icon,
  );
  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  String _text(dynamic value) => (value ?? '-').toString();
  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  String _money(dynamic value) {
    final amount = value is num ? value : num.tryParse('$value');
    return amount == null ? '-' : '\$${amount.toStringAsFixed(0)}';
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString())?.toLocal();
    return date == null
        ? '-'
        : '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
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
