import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/services/plant_socket_service.dart';
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

  final RxInt currentPage = 1.obs;
  final RxInt totalResults = 0.obs;
  static const int pageSize = 20;

  Worker? _searchWorker;
  StreamSubscription<PlantSocketEvent>? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    _searchWorker = debounce<String>(searchQuery, (_) {
      currentPage.value = 1;
      loadData();
    }, time: const Duration(milliseconds: 450));

    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor({
        'freight_bid_submitted',
        'all_freight_bids_submitted',
        'freight_bid_awarded',
        'delivery_status_updated',
      }, (_) {
        loadData();
      });
    }
    loadData();
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    _socketSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        repository.awardedStats().catchError((_) => <String, dynamic>{}),
        repository.awardedLoads(
          page: currentPage.value,
          limit: pageSize,
          search: searchQuery.value,
          status: selectedStatus.value,
        ),
      ]);

      final stats = results[0];
      _mapLoads(results[1]);

      final totalAwardedCount = stats['totalAwarded'] ??
          stats['total'] ??
          totalResults.value;
      final inTransitCount = stats['inTransit'] ??
          awardedLoadsList.where((i) {
            final s = '${i.status} ${i.subStatus}'.toLowerCase();
            return s.contains('transit') || s.contains('loaded');
          }).length;
      final deliveredCount = stats['delivered'] ??
          awardedLoadsList.where((i) {
            final s = '${i.status} ${i.subStatus}'.toLowerCase();
            return s.contains('delivered');
          }).length;

      dynamic totalSpentVal = stats['totalSpent'];
      if (totalSpentVal == null) {
        double sum = 0;
        for (final item in awardedLoadsList) {
          final amt = double.tryParse(
            item.awardedAmount.replaceAll(RegExp(r'[^0-9.]'), ''),
          );
          if (amt != null && amt > 0) {
            sum += amt;
          }
        }
        if (sum > 0) totalSpentVal = sum;
      }

      summaryStats.assignAll([
        _stat(
          'Total Awarded',
          totalAwardedCount,
          const Color(0xFF16A34A),
          Icons.workspace_premium_outlined,
        ),
        _stat(
          'In Transit',
          inTransitCount,
          const Color(0xFFEA580C),
          Icons.local_shipping_outlined,
        ),
        _stat(
          'Delivered',
          deliveredCount,
          const Color(0xFF16A34A),
          Icons.check_circle_outline,
        ),
        _stat(
          'Total Spent',
          _money(totalSpentVal),
          const Color(0xFF2563EB),
          Icons.attach_money,
        ),
      ]);
    } catch (error) {
      errorMessage.value = error.toString();
      summaryStats.clear();
      awardedLoadsList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _mapLoads(Map<String, dynamic> data) {
    final raw = data['requests'] is List
        ? data['requests'] as List
        : data['deliveries'] is List
        ? data['deliveries'] as List
        : data['data'] is List
        ? data['data'] as List
        : const [];

    totalResults.value = _integer(data['total'], fallback: raw.length);

    awardedLoadsList.assignAll(
      raw.whereType<Map>().map((entry) {
        final item = Map<String, dynamic>.from(entry);
        final project = _map(item['project'] ?? item['lead'] ?? item['leadId']);
        final customer = _map(project['customerId'] ?? item['customer']);
        final carrier = _map(item['carrier'] ??
            item['awardedCarrier'] ??
            _map(item['selectedCarrierBidId'])['carrierId'] ??
            item['selectedCarrier']);
        final route = _map(item['route']);
        final loadSize = _map(item['loadSize']);

        final weightVal =
            item['loadWeight'] ?? item['weight'] ?? loadSize['weight'];
        final pkgCountVal = item['packageCount'] ??
            item['palletCount'] ??
            loadSize['packageCount'];

        final ownerVal = _firstNonEmpty([
          item['internalOwnerName'],
          item['internalOwner'],
          item['owner'],
          customer['name'],
          customer['companyName'],
          customer['firstName'],
          project['customerName'],
          project['projectManager'],
          project['internalOwner'],
          item['createdBy'] is Map
              ? item['createdBy']['name']
              : item['createdBy'],
          item['creatorName'],
          item['assignedTo'],
          item['customerName'],
          item['receivingPoc'],
          item['pocName'],
        ]);

        final statusVal = _status(
          item['deliveryStatus'] ?? item['status'] ?? 'Confirmed',
        );
        final subStatusVal = _status(
          item['subStatus'] ??
              item['deliveryStatus'] ??
              item['status'] ??
              'Confirmed',
        );

        final budgetVal = item['budget'] ??
            item['targetAmount'] ??
            item['price'] ??
            item['awardedBidAmount'] ??
            item['awardedAmount'];
        final awardedVal = item['awardedBidAmount'] ??
            item['awardedAmount'] ??
            item['winningBidAmount'] ??
            item['price'] ??
            item['budget'];

        return AwardedLoadItemModel(
          id: _text(
            item['_id'] ?? item['id'] ?? item['deliveryId'] ?? item['requestId'],
          ),
          requestId: _text(
            item['deliveryNumber'] ?? item['requestId'] ?? item['_id'],
          ),
          requestedDate: _date(
            item['requestedAt'] ?? item['createdAt'] ?? item['requestDate'],
          ),
          subStatus: subStatusVal,
          project: _text(
            item['projectName'] ??
                project['projectName'] ??
                project['name'] ??
                project['title'],
          ),
          description: _text(
            item['description'] ??
                item['itemDescription'] ??
                item['loadDescription'] ??
                item['itemsDescription'],
          ),
          pickupLocation: _text(
            item['pickupLocation'] ??
                route['from'] ??
                route['pickupLocation'] ??
                item['vendorAddress'],
          ),
          deliveryLocation: _text(
            item['deliveryLocation'] ??
                item['siteLocation'] ??
                route['to'] ??
                route['deliveryLocation'] ??
                item['siteAddress'],
          ),
          pickupDate: _date(
            item['pickupDate'] ?? item['pickup'] ?? item['shipDate'],
          ),
          deliveryDate: _date(
            item['deliveryDate'] ?? item['delivery'] ?? item['dropoffDate'],
          ),
          carrierName: _text(
            item['carrierName'] ??
                carrier['companyName'] ??
                carrier['name'] ??
                carrier['carrierName'],
          ),
          carrierPhone: _text(
            item['carrierPhone'] ??
                carrier['phone'] ??
                carrier['phoneNumber'] ??
                carrier['contactPhone'],
          ),
          budget: _money(budgetVal),
          awardedAmount: _money(awardedVal),
          bidsCount:
              _int(item['bidCount'] ?? item['bidsCount'] ?? item['bids']?.length),
          status: statusVal,
          loadWeight: _formatWeight(weightVal),
          packageCount: pkgCountVal != null &&
                  '$pkgCountVal'.trim().isNotEmpty &&
                  '$pkgCountVal' != '0'
              ? '${_number(pkgCountVal)} packages'
              : '',
          internalOwner: ownerVal.isNotEmpty ? ownerVal : '—',
        );
      }),
    );
  }

  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value * pageSize < totalResults.value;

  Future<void> previousPage() async {
    if (!hasPreviousPage) return;
    currentPage.value--;
    await loadData();
  }

  Future<void> nextPage() async {
    if (!hasNextPage) return;
    currentPage.value++;
    await loadData();
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
              item.carrierName.toLowerCase().contains(query) ||
              item.pickupLocation.toLowerCase().contains(query) ||
              item.deliveryLocation.toLowerCase().contains(query) ||
              item.internalOwner.toLowerCase().contains(query) ||
              item.status.toLowerCase().contains(query) ||
              item.subStatus.toLowerCase().contains(query),
        )
        .toList();
  }

  void openFreightRequestDetails(AwardedLoadItemModel item) {
    final targetId = item.id.isNotEmpty ? item.id : item.requestId;
    Get.toNamed(
      AppRoutes.freightRequestDetails,
      parameters: {'id': targetId},
    );
  }

  void showFilterDialog() => Get.dialog(
    FreightFilterDialog(
      statuses: awardedLoadsList.map((item) => item.status).toSet().toList(),
      onApplyStatus: (status) {
        selectedStatus.value = status ?? '';
        currentPage.value = 1;
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

  String _text(dynamic value) {
    if (value == null) return '-';
    final str = value.toString().trim();
    return str.isEmpty || str == 'null' ? '-' : str;
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  int _integer(dynamic value, {required int fallback}) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

  String _firstNonEmpty(List<dynamic> list) {
    for (final v in list) {
      if (v != null) {
        final str = v.toString().trim();
        if (str.isNotEmpty && str != 'null' && str != '-' && str != '—') {
          return str;
        }
      }
    }
    return '';
  }

  String _number(dynamic value) {
    if (value == null) return '';
    final numVal =
        value is num ? value : num.tryParse('$value'.replaceAll(',', ''));
    if (numVal == null) return value.toString();
    if (numVal is int || numVal == numVal.toInt()) {
      return numVal.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return numVal.toString();
  }

  String _formatWeight(dynamic value) {
    if (value == null) return '-';
    final numVal = value is num
        ? value.toDouble()
        : double.tryParse('$value'.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (numVal == null || numVal == 0) return '-';
    final isInt = numVal == numVal.truncateToDouble();
    final parts =
        (isInt ? numVal.toInt().toString() : numVal.toStringAsFixed(1))
            .split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final formatted = parts.length > 1 ? '$whole.${parts[1]}' : whole;
    return '$formatted lbs';
  }

  String _money(dynamic value) {
    if (value == null) return '-';
    final amount = value is num
        ? value
        : num.tryParse('$value'.replaceAll(RegExp(r'[\$,]'), ''));
    if (amount == null) return '-';
    final isInt = amount == amount.toInt();
    final whole =
        (isInt ? amount.toInt().toString() : amount.toStringAsFixed(0))
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
    return '\$$whole';
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString())?.toLocal();
    return date == null
        ? '-'
        : '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  String _status(dynamic value) => (value ?? 'Confirmed')
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
