import 'package:get/get.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../model/freight_carrier_master_model.dart';
import '../repository/freight_carriers_repository.dart';

class FreightCarriersController extends GetxController {
  final FreightCarriersRepository repository;
  FreightCarriersController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = ''.obs;
  final RxList<FreightCarrierMasterModel> carriers =
      <FreightCarrierMasterModel>[].obs;
  final RxList<FreightCarrierMasterModel> filteredCarriers =
      <FreightCarrierMasterModel>[].obs;
  final Rx<FreightCarrierMasterModel?> selectedCarrier =
      Rx<FreightCarrierMasterModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCarriers();
  }

  Future<void> loadCarriers() async {
    isLoading.value = true;
    try {
      final data = await repository.list(
        status: statusFilter.value.isEmpty
            ? null
            : statusFilter.value.toLowerCase(),
      );
      final raw = data['carriers'];
      carriers.assignAll(
        raw is List
            ? raw.whereType<Map>().map(_mapCarrier).toList()
            : <FreightCarrierMasterModel>[],
      );
      _applyFilter();
    } catch (error) {
      carriers.clear();
      filteredCarriers.clear();
      CommonSnackbar.showError(title: 'Unable to load freight carriers', message: error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  FreightCarrierMasterModel _mapCarrier(Map item) {
    final stats = _map(item['stats']);
    final fleet = _map(item['fleetCapacity']);
    final totalBids = _int(item['totalBids'] ?? stats['totalBids']);
    final awarded = _int(item['awardedCount'] ?? stats['awardedBids']);
    final winRate =
        item['winRate'] ??
        stats['winRate'] ??
        (totalBids == 0 ? 0 : (awarded * 100 / totalBids));
    final equipment = item['equipmentTypes'] ?? item['equipmentType'];
    return FreightCarrierMasterModel(
      id: (item['_id'] ?? item['id'] ?? '').toString(),
      name:
          (item['carrierName'] ??
                  item['companyName'] ??
                  item['name'] ??
                  'Carrier')
              .toString(),
      carrierId:
          (item['carrierCode'] ?? item['code'] ?? item['carrierId'] ?? '')
              .toString(),
      contact: (item['contactName'] ?? item['primaryContact'] ?? '').toString(),
      email: (item['email'] ?? '').toString(),
      phone: (item['phone'] ?? item['phoneNumber'] ?? '').toString(),
      activeBids: _int(item['activeBids'] ?? stats['activeBids']),
      totalBids: totalBids,
      awardedCount: awarded,
      winRate: '${_number(winRate)}% win rate',
      avgBid: _money(item['avgBid'] ?? stats['averageBid'] ?? stats['avgBid']),
      respondsTime: (item['responseTime'] ?? stats['responseTime'] ?? '')
          .toString(),
      status: _title(item['status'] ?? 'active'),
      serviceType: (item['serviceType'] ?? '').toString(),
      serviceArea: _listText(item['serviceArea']),
      equipmentType: equipment is List
          ? equipment.map((e) => e.toString()).join(', ')
          : (equipment ?? fleet['equipmentType'] ?? '').toString(),
    );
  }

  void filterCarriers(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    loadCarriers();
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    filteredCarriers.assignAll(
      q.isEmpty
          ? carriers
          : carriers.where(
              (item) =>
                  item.name.toLowerCase().contains(q) ||
                  item.carrierId.toLowerCase().contains(q) ||
                  item.contact.toLowerCase().contains(q) ||
                  item.email.toLowerCase().contains(q) ||
                  item.phone.toLowerCase().contains(q) ||
                  item.serviceType.toLowerCase().contains(q) ||
                  item.serviceArea.toLowerCase().contains(q) ||
                  item.equipmentType.toLowerCase().contains(q) ||
                  item.status.toLowerCase().contains(q),
            ),
    );
  }

  Future<void> saveCarrier({
    String? id,
    required String name,
    required String email,
    required String phone,
    required String contactName,
    required String serviceType,
    required String serviceArea,
    required int totalVehicles,
    required num maximumLoadCapacity,
    List<String> equipmentTypes = const [],
  }) async {
    final payload = <String, dynamic>{
      'carrierName': name,
      'email': email,
      'phone': phone,
      'contactName': contactName,
      'serviceType': serviceType,
      'serviceArea': serviceArea,
      'equipmentTypes': equipmentTypes,
      'fleetCapacity': {
        'totalVehicleCount': totalVehicles,
        'maximumLoadCapacity': maximumLoadCapacity,
      },
    };
    isLoading.value = true;
    try {
      if (id != null && id.isNotEmpty) {
        await repository.update(id, payload);
      } else {
        await repository.create(payload);
      }
      await loadCarriers();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStatus(FreightCarrierMasterModel carrier) async {
    try {
      await repository.toggleStatus(carrier.id);
      await loadCarriers();
    } catch (error) {
      CommonSnackbar.showError(title: 'Unable to update status', message: error.toString());
    }
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  int _int(dynamic value) => int.tryParse((value ?? 0).toString()) ?? 0;
  String _number(dynamic value) {
    final number = double.tryParse((value ?? 0).toString()) ?? 0;
    return number == number.roundToDouble()
        ? number.toInt().toString()
        : number.toStringAsFixed(1);
  }

  String _money(dynamic value) {
    final number = double.tryParse((value ?? 0).toString()) ?? 0;
    return '\$${number.toStringAsFixed(0)}';
  }

  String _title(dynamic value) => (value ?? '')
      .toString()
      .replaceAll('_', ' ')
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
  String _listText(dynamic value) => value is List
      ? value.map((e) => e.toString()).join(', ')
      : (value ?? '').toString();
}
