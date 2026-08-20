import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../awarded_loads/widgets/freight_filter_dialog.dart';
import '../model/freight_loads_model.dart';
import '../repository/delivery_repository.dart';
import '../widgets/award_load_dialog.dart';
import '../widgets/request_revision_dialog.dart';

class FreightLoadsController extends GetxController {
  final DeliveryRepository repository;
  FreightLoadsController({required this.repository});

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<FreightLoadSummaryStatModel> summaryStats =
      <FreightLoadSummaryStatModel>[].obs;
  final RxList<FreightLoadItemModel> freightLoadsList =
      <FreightLoadItemModel>[].obs;
  final RxList<CarrierBidModel> carrierBidsList = <CarrierBidModel>[].obs;
  final RxInt selectedDetailsTabIndex = 1.obs;
  final RxString selectedLoadId = ''.obs;
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
    selectedLoadId.value = Get.parameters['id'] ?? '';
    _searchWorker = debounce<String>(searchQuery, (_) {
      currentPage.value = 1;
      loadData();
    }, time: const Duration(milliseconds: 450));
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor({
        'freight_bid_submitted',
        'all_freight_bids_submitted',
      }, (_) => loadData());
    }
    loadData();
    if (selectedLoadId.value.isNotEmpty) {
      loadCarrierBidsData(selectedLoadId.value);
    }
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
        repository.freightStats(),
        repository.freightLoads(
          page: currentPage.value,
          limit: pageSize,
          search: searchQuery.value,
          status: selectedStatus.value,
        ),
      ]);
      _mapStats(results[0]);
      _mapLoads(results[1]);
    } catch (error) {
      errorMessage.value = error.toString();
      summaryStats.clear();
      freightLoadsList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void showFilterDialog() => Get.dialog(
    FreightFilterDialog(
      onApplyStatus: (status) {
        selectedStatus.value = status ?? '';
        currentPage.value = 1;
        loadData();
      },
    ),
  );

  Future<void> exportLoads() async {
    try {
      await FileExportService.saveCsv(
        fileName: 'freight_loads',
        rows: [
          const [
            'Request ID',
            'Project',
            'Description',
            'From',
            'To',
            'Pickup Date',
            'Delivery Date',
            'Bids',
            'Status',
          ],
          ...filteredFreightLoads.map(
            (item) => [
              item.requestId,
              item.project,
              item.description,
              item.routeFrom,
              item.routeTo,
              item.pickupDate,
              item.deliveryDate,
              item.bids,
              item.status,
            ],
          ),
        ],
      );
      CommonSnackbar.showSuccess(
        title: 'Export complete',
        message: 'freight_loads.csv was downloaded.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Export failed',
        message: error.toString(),
      );
    }
  }

  Future<void> exportCarrierBids() async {
    try {
      await FileExportService.saveCsv(
        fileName:
            'freight_request_${selectedLoadId.value.isEmpty ? 'export' : selectedLoadId.value}',
        rows: [
          const [
            'Carrier',
            'Rating',
            'Bid Amount',
            'Delivery Days',
            'Best Rate',
          ],
          ...carrierBidsList.map(
            (item) => [
              item.carrierName,
              item.rating,
              item.bidAmount,
              item.deliveryDays,
              item.isBestRate ? 'Yes' : 'No',
            ],
          ),
        ],
      );
      CommonSnackbar.showSuccess(
        title: 'Export complete',
        message: 'Freight request CSV was downloaded.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Export failed',
        message: error.toString(),
      );
    }
  }

  void _mapStats(Map<String, dynamic> stats) {
    summaryStats.assignAll([
      _stat(
        'Total Loads',
        stats['totalLoads'] ?? stats['total'],
        const Color(0xFF22C55E),
        Icons.local_shipping_outlined,
      ),
      _stat(
        'In Transit',
        stats['inTransit'],
        const Color(0xFFF97316),
        Icons.local_shipping_outlined,
      ),
      _stat(
        'Delivered',
        stats['delivered'],
        const Color(0xFF22C55E),
        Icons.check_circle_outline,
      ),
      _stat(
        'Total Spent',
        _money(stats['totalSpent']),
        const Color(0xFF2563EB),
        Icons.attach_money,
      ),
      _stat(
        'Requested Loads',
        stats['requestedLoads'] ?? stats['requested'] ?? stats['total'],
        const Color(0xFFEC4899),
        Icons.local_shipping_outlined,
      ),
      _stat(
        'Bids Pending',
        stats['bidsPending'] ?? stats['pending'],
        const Color(0xFF3B82F6),
        Icons.info_outline,
      ),
    ]);
  }

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

  void _mapLoads(Map<String, dynamic> data) {
    final raw = data['requests'] is List
        ? data['requests'] as List
        : data['deliveries'] is List
        ? data['deliveries'] as List
        : const [];
    totalResults.value = _integer(data['total'], fallback: raw.length);
    freightLoadsList.assignAll(
      raw.whereType<Map>().map((entry) {
        final item = Map<String, dynamic>.from(entry);
        final project = _map(item['project'] ?? item['lead']);
        final route = _map(item['route']);
        final loadSize = _map(item['loadSize']);
        return FreightLoadItemModel(
          id: _text(item['_id'] ?? item['id']),
          requestId: _text(
            item['deliveryNumber'] ?? item['requestId'] ?? item['_id'],
          ),
          requestedDate: _date(item['requestedAt'] ?? item['createdAt']),
          project: _text(item['projectName'] ?? project['projectName']),
          description: _text(item['description'] ?? item['itemDescription']),
          routeFrom: _text(item['pickupLocation'] ?? route['from']),
          routeTo: _text(
            item['deliveryLocation'] ?? item['siteLocation'] ?? route['to'],
          ),
          pickupDate: _date(item['pickupDate']),
          deliveryDate: _date(item['deliveryDate']),
          bids: item['awardedBidAmount'] == null
              ? item['bidCount'] == null
                    ? '-'
                    : '${item['bidCount']}'
              : _money(item['awardedBidAmount']),
          status: _status(item['status']),
          loadWeight: loadSize['weight'] == null
              ? '-'
              : '${_number(loadSize['weight'])} lbs',
          packageCount: loadSize['packageCount'] == null
              ? ''
              : '${loadSize['packageCount']} packages',
        );
      }),
    );
  }

  FreightLoadItemModel? get selectedLoadItem {
    if (selectedLoadId.value.isEmpty) return null;
    return freightLoadsList.firstWhereOrNull(
      (item) => item.id == selectedLoadId.value || item.requestId == selectedLoadId.value,
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

  List<FreightLoadItemModel> get filteredFreightLoads {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return freightLoadsList;
    return freightLoadsList
        .where(
          (item) =>
              item.requestId.toLowerCase().contains(query) ||
              item.project.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query) ||
              item.status.toLowerCase().contains(query),
        )
        .toList();
  }

  void openFreightRequestDetails(FreightLoadItemModel item) {
    selectedLoadId.value = item.id.isEmpty ? item.requestId : item.id;
    Get.toNamed(
      AppRoutes.freightRequestDetails,
      parameters: {'id': selectedLoadId.value},
    );
  }

  Future<void> loadCarrierBidsData(String deliveryId) async {
    try {
      final data = await repository.bids(deliveryId);
      final raw = data['bids'] is List ? data['bids'] as List : const [];
      carrierBidsList.assignAll(
        raw.whereType<Map>().map((entry) {
          final item = Map<String, dynamic>.from(entry);
          final carrier = _map(item['carrier']);
          final ratingValue = item['rating'] is num
              ? item['rating'] as num
              : num.tryParse('${item['rating']}') ?? 0;
          return CarrierBidModel(
            id: _text(item['_id'] ?? item['id']),
            carrierName: _text(
              item['carrierName'] ?? carrier['companyName'] ?? carrier['name'],
            ),
            rating: ratingValue.toDouble(),
            bidAmount: _money(item['amount'] ?? item['bidAmount']),
            isBestRate: item['isBestRate'] == true,
            deliveryDays: _text(item['deliveryDays'] ?? item['transitTime']),
          );
        }),
      );
    } catch (error) {
      errorMessage.value = error.toString();
      carrierBidsList.clear();
    }
  }

  void showAwardLoadDialog([CarrierBidModel? carrier]) => Get.dialog(
    AwardLoadDialog(
      carrierName: carrier?.carrierName ?? 'Carrier',
      awardAmount: carrier?.bidAmount ?? r'$0',
      onConfirm: carrier == null || carrier.id.isEmpty
          ? null
          : () async {
              try {
                await repository.selectBid(carrier.id);
                await loadCarrierBidsData(selectedLoadId.value);
                await loadData();
                return true;
              } catch (error) {
                CommonSnackbar.showError(
                  title: 'Award failed',
                  message: error.toString(),
                );
                return false;
              }
            },
    ),
  );

  void showRequestRevisionDialog([CarrierBidModel? carrier]) => Get.dialog(
    RequestRevisionDialog(
      carrierName: carrier?.carrierName ?? 'Carrier',
      currentBidAmount: carrier?.bidAmount ?? r'$0',
      onConfirm: carrier == null || carrier.id.isEmpty
          ? null
          : (targetAmount, message) async {
              try {
                await repository.requestBidResubmit(
                  carrier.id,
                  targetAmount: targetAmount,
                  message: message,
                );
                await loadCarrierBidsData(selectedLoadId.value);
                return true;
              } catch (error) {
                CommonSnackbar.showError(
                  title: 'Revision request failed',
                  message: error.toString(),
                );
                return false;
              }
            },
    ),
  );

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  String _text(dynamic value) => (value ?? '-').toString();
  String _money(dynamic value) {
    final amount = value is num ? value : num.tryParse('$value');
    return amount == null ? '-' : '\$${amount.toStringAsFixed(0)}';
  }

  int _integer(dynamic value, {required int fallback}) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

  String _number(dynamic value) {
    final number = value is num ? value : num.tryParse('$value');
    if (number == null) return '-';
    final parts = number.toStringAsFixed(number % 1 == 0 ? 0 : 1).split('.');
    final formatted = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return parts.length == 1 ? formatted : '$formatted.${parts.last}';
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
