import 'dart:async';
import 'package:get/get.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../freight_carriers/repository/freight_carriers_repository.dart';
import '../model/delivery_details_model.dart';
import '../repository/delivery_details_repository.dart';

class DeliveryDetailsController extends GetxController {
  final DeliveryDetailsRepository repository;
  final FreightCarriersRepository carriersRepository;
  DeliveryDetailsController({
    required this.repository,
    required this.carriersRepository,
  });
  final RxBool isLoading = true.obs;
  final RxBool hasNoDeliveries = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString rawDeliveryId = ''.obs;
  final RxList<Map<String, dynamic>> carrierOptions =
      <Map<String, dynamic>>[].obs;
  final RxSet<String> selectedCarrierIds = <String>{}.obs;

  late DeliveryDetailsModel delivery;
  final RxList<StatusHistoryItem> statusHistory = <StatusHistoryItem>[].obs;
  final RxList<NotificationHistoryItem> notificationHistory =
      <NotificationHistoryItem>[].obs;
  StreamSubscription<PlantSocketEvent>? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor({
        'freight_bid_submitted',
        'all_freight_bids_submitted',
      }, (_) => loadDeliveryDetails());
    }
    loadDeliveryDetails();
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadDeliveryDetails() async {
    isLoading.value = true;
    hasNoDeliveries.value = false;
    errorMessage.value = '';
    try {
      final routeId = Get.parameters['id'] ?? Get.parameters['deliveryId'] ?? '';
      if (routeId.isEmpty) throw Exception('Project id is missing.');
      Map<String, dynamic> first = {};
      var deliveryId = Get.parameters['deliveryId'] ?? rawDeliveryId.value;
      if (deliveryId.isEmpty) {
        final projectData = await repository.fetchProjectDeliveries(routeId);
        final deliveries = projectData['requests'] as List? ?? projectData['deliveries'] as List? ?? [];
        if (deliveries.isEmpty) { hasNoDeliveries.value = true; return; }
        first = Map<String, dynamic>.from(deliveries.first as Map);
        deliveryId = (first['_id'] ?? first['deliveryId'] ?? '').toString();
      }
      if (deliveryId.isEmpty) throw StateError('Delivery ID is missing.');
      rawDeliveryId.value = deliveryId;
      final detailData = await repository.fetchDetail(deliveryId);
      final raw = detailData['delivery'] is Map
          ? Map<String, dynamic>.from(detailData['delivery'] as Map)
          : first;
      final project = detailData['project'] is Map
          ? Map<String, dynamic>.from(detailData['project'] as Map)
          : <String, dynamic>{};
      final customer = detailData['customer'] is Map
          ? Map<String, dynamic>.from(detailData['customer'] as Map)
          : <String, dynamic>{};
      final carrier = detailData['carrier'] is Map
          ? Map<String, dynamic>.from(detailData['carrier'] as Map)
          : <String, dynamic>{};
      delivery = DeliveryDetailsModel(
        deliveryId: (raw['deliveryNumber'] ?? raw['_id'] ?? 'N/A').toString(),
        title: (raw['title'] ?? raw['description'] ?? 'Material Delivery')
            .toString(),
        status: _status(raw['status']),
        projectName: (project['projectName'] ?? raw['projectName'] ?? 'N/A')
            .toString(),
        customer: (customer['name'] ?? customer['firstName'] ?? 'N/A')
            .toString(),
        deliveryDate: _text(raw['deliveryDate']),
        timeWindow: (raw['timeWindow'] ?? 'N/A').toString(),
        siteAddress: (raw['deliveryLocation'] ?? raw['siteAddress'] ?? 'N/A')
            .toString(),
        description: (raw['description'] ?? 'N/A').toString(),
        materialCategory: (raw['materialCategory'] ?? '—').toString(),
        pickupDate: _text(raw['pickupDate']),
        vendorName: (raw['vendorName'] ?? 'N/A').toString(),
        vendorContact: (raw['vendorContact'] ?? 'N/A').toString(),
        vendorPhone: (raw['vendorPhone'] ?? 'N/A').toString(),
        vendorEmail: (raw['vendorEmail'] ?? 'N/A').toString(),
        deliveryCompany: (carrier['companyName'] ?? carrier['name'] ?? 'N/A')
            .toString(),
        carrierContact: (carrier['contactName'] ?? 'N/A').toString(),
        carrierPhone: (carrier['phone'] ?? 'N/A').toString(),
        internalOwner: (raw['internalOwner'] ?? 'N/A').toString(),
        internalContact: (raw['internalContact'] ?? 'N/A').toString(),
        priority: _status(raw['priority']),
        deliveryType: (raw['deliveryType'] ?? '—').toString(),
        quantity: (raw['packageCount'] ?? raw['quantity'] ?? 'N/A').toString(),
        siteInstructions: (raw['siteInstructions'] ?? 'N/A').toString(),
        requiredEquipment: (raw['requiredEquipment'] ?? 'N/A').toString(),
        equipmentStatus: _status(raw['equipmentStatus']),
        specialNotes: (raw['specialNotes'] ?? 'N/A').toString(),
        freightLoadId: (raw['freightLoadId'] ?? 'N/A').toString(),
        awardedCarrier: (carrier['name'] ?? 'N/A').toString(),
        price: raw['price'] == null ? '—' : '\$${raw['price']}',
        receivingName: (raw['receivingName'] ?? customer['firstName'] ?? 'N/A')
            .toString(),
        receivingPhone: (raw['receivingPhone'] ?? customer['phone'] ?? 'N/A')
            .toString(),
        receivingEmail: (raw['receivingEmail'] ?? customer['email'] ?? 'N/A')
            .toString(),
      );

      statusHistory.assignAll((raw['statusHistory'] as List? ?? []).whereType<Map>().map((row) => StatusHistoryItem(
        title: _status(row['status']), timestamp: _text(row['changedAt']),
        description: _text(row['note'] ?? row['reason']), isCurrent: row['status'] == raw['status'],
      )));
      notificationHistory.assignAll((detailData['notifications'] as List? ?? raw['notifications'] as List? ?? []).whereType<Map>().map((row) => NotificationHistoryItem(
        title: _text(row['title'] ?? row['type']), subtitle: _text(row['recipient']),
        timestamp: _text(row['sentAt'] ?? row['createdAt']), status: _text(row['status']),
      )));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  final isSaving = false.obs;
  final saveError = ''.obs;
  Future<bool> saveDetails(Map<String, dynamic> body, {bool reschedule = false}) async {
    if (isSaving.value || rawDeliveryId.isEmpty) return false;
    isSaving.value = true;
    saveError.value = '';
    try {
      if (reschedule) { await repository.reschedule(rawDeliveryId.value, body); }
      else { await repository.update(rawDeliveryId.value, body); }
      await loadDeliveryDetails();
      return true;
    } catch (error) { saveError.value = error.toString(); return false; }
    finally { isSaving.value = false; }
  }

  String _status(dynamic value) {
    final text = (value ?? 'N/A').toString().replaceAll('_', ' ');
    return text
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _text(dynamic value) => value == null ? 'N/A' : value.toString();

  Future<void> loadCarrierOptions() async {
    final data = await carriersRepository.list(status: 'active');
    final raw = data['carriers'];
    carrierOptions.assignAll(
      raw is List
          ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e))
          : <Map<String, dynamic>>[],
    );
  }

  Future<void> sendBids() async {
    if (rawDeliveryId.value.isEmpty || selectedCarrierIds.isEmpty) {
      CommonSnackbar.showWarning(title: 'Select carriers', message: 'Choose at least one freight carrier.');
      return;
    }
    isLoading.value = true;
    try {
      final data = await repository.sendBids(
        rawDeliveryId.value,
        carrierIds: selectedCarrierIds.toList(),
        bidDeadline: DateTime.now().add(const Duration(days: 3)),
      );
      Get.back();
      CommonSnackbar.showSuccess(
        title: 'Bids sent',
        message: 'Sent to ${data['sentTo'] ?? selectedCarrierIds.length} carriers.',
      );
    } catch (error) {
      CommonSnackbar.showError(title: 'Unable to send bids', message: error.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
