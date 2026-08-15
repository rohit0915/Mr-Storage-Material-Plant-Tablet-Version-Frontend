import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/services/file_export_service.dart';
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

  @override
  void onInit() {
    super.onInit();
    selectedLoadId.value = Get.parameters['id'] ?? '';
    loadData();
    if (selectedLoadId.value.isNotEmpty) {
      loadCarrierBidsData(selectedLoadId.value);
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        repository.freightStats(),
        repository.freightLoads(
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
        stats['total'],
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
        stats['requested'] ?? stats['total'],
        const Color(0xFFEC4899),
        Icons.local_shipping_outlined,
      ),
      _stat(
        'Bids Pending',
        stats['pending'],
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
    final raw = data['deliveries'] is List
        ? data['deliveries'] as List
        : const [];
    freightLoadsList.assignAll(
      raw.whereType<Map>().map((entry) {
        final item = Map<String, dynamic>.from(entry);
        final project = _map(item['project'] ?? item['lead']);
        final route = _map(item['route']);
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
          bids: item['bidCount'] == null
              ? _money(item['awardedAmount'] ?? item['price'])
              : '${item['bidCount']}',
          status: _status(item['status']),
        );
      }),
    );
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
                CommonSnackbar.showError(title: 'Award failed', message: error.toString());
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
                CommonSnackbar.showError(title: 'Revision request failed', message: error.toString());
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
