import 'package:get/get.dart';

import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../bom_files_details/model/bom_document_mapper.dart';
import '../../bom_files_details/model/bom_files_details_model.dart';
import '../../bom_files_details/repository/bom_files_details_repository.dart';
import '../model/generate_shipper_order_model.dart';

class GenerateShipperOrderController extends GetxController {
  final ApiClient apiClient;
  final BomFilesDetailsRepository bomRepository;

  GenerateShipperOrderController({
    required this.apiClient,
    required this.bomRepository,
  });

  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ShipperCardModel> shippers = <ShipperCardModel>[].obs;
  final RxList<String> newShipperEmails = <String>[].obs;
  final RxString searchQuery = ''.obs;

  final RxString projectId = ''.obs;
  final RxString projectName = ''.obs;
  final RxString bomId = ''.obs;
  final RxString date = ''.obs;
  final RxString jobId = ''.obs;
  final RxString customerName = ''.obs;
  final RxString totalCost = ''.obs;
  final RxString totalItems = '0'.obs;
  final RxString totalWeight = '0 lbs'.obs;
  final RxString totalPanelsArea = '0 sq ft'.obs;
  final RxList<BomItemModel> bomItems = <BomItemModel>[].obs;

  List<ShipperCardModel> get filteredShippers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return shippers;
    return shippers
        .where(
          (item) =>
              item.name.toLowerCase().contains(query) ||
              item.serviceArea.toLowerCase().contains(query),
        )
        .toList();
  }

  bool get canSend =>
      !isSending.value &&
      shippers.any((item) => item.isSelected && !item.isSent);

  @override
  void onInit() {
    super.onInit();
    projectId.value = Get.parameters['id'] ?? '';
    loadShipperOrderData();
  }

  Future<void> loadShipperOrderData() async {
    final id = projectId.value;
    if (id.isEmpty) {
      errorMessage.value = 'Project id is missing.';
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        bomRepository.fetch(id),
        apiClient.get(
          ApiEndpoints.plantVendors,
          queryParameters: const {'page': 1, 'limit': 100, 'status': 'active'},
        ),
      ]);
      final document = BomDocumentMapper.fromApi(
        projectId: id,
        response: results[0] as Map<String, dynamic>,
      );
      _applyDocument(document);
      _applyVendors((results[1] as dynamic).data, document.sentToVendors);
    } catch (error) {
      errorMessage.value = error.toString();
      shippers.clear();
      bomItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyDocument(BomDocumentModel document) {
    projectName.value = document.projectName;
    bomId.value = document.bomId;
    date.value = document.date;
    jobId.value = document.jobId;
    customerName.value = document.customerName;
    totalItems.value = '${document.summary.totalItems}';
    totalWeight.value = document.summary.totalWeight;
    totalPanelsArea.value = document.summary.totalPanelsArea;
    totalCost.value = document.summary.totalCost ?? '\$0.00';
    bomItems.assignAll(document.items);
  }

  void _applyVendors(dynamic response, List<Map<String, dynamic>> sent) {
    final body = response is Map
        ? Map<String, dynamic>.from(response)
        : <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    final rawVendors = data['vendors'] is List
        ? data['vendors'] as List
        : data['items'] is List
        ? data['items'] as List
        : const [];
    final sentById = <String, Map<String, dynamic>>{
      for (final item in sent)
        (item['vendorId'] is Map
                    ? item['vendorId']['_id']
                    : item['vendorId'] ?? item['_id'])
                .toString():
            item,
    };
    shippers.assignAll(
      rawVendors.whereType<Map>().map((raw) {
        final vendor = Map<String, dynamic>.from(raw);
        final id = (vendor['_id'] ?? vendor['id'] ?? '').toString();
        final address = vendor['address'] is Map
            ? Map<String, dynamic>.from(vendor['address'] as Map)
            : <String, dynamic>{};
        final sentRecord = sentById[id];
        final area = [
          address['city'],
          address['state'],
        ].where((value) => value != null && '$value'.isNotEmpty).join(', ');
        return ShipperCardModel(
          id: id,
          name:
              (vendor['vendorName'] ??
                      vendor['companyName'] ??
                      vendor['name'] ??
                      'Shipper')
                  .toString(),
          rating: _double(vendor['rating']),
          serviceArea:
              (vendor['pickupLocation'] ??
                      vendor['serviceArea'] ??
                      (area.isEmpty ? 'N/A' : area))
                  .toString(),
          isSent: sentRecord != null,
          sentAt: (sentRecord?['sentAt'] ?? '').toString(),
        );
      }),
    );
  }

  void toggleShipperSelect(ShipperCardModel shipper) {
    if (shipper.isSent) return;
    shipper.isSelected = !shipper.isSelected;
    shippers.refresh();
  }

  Future<bool> addNewShipperEmail(
    String name,
    String email,
    String phone,
  ) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanPhone = phone.trim();
    if (cleanName.isEmpty || cleanEmail.isEmpty || cleanPhone.isEmpty) {
      CommonSnackbar.showError(
        title: 'Required fields',
        message: 'Name, email and phone are required.',
      );
      return false;
    }
    try {
      await apiClient.post(
        ApiEndpoints.plantVendors,
        data: {
          'vendorName': cleanName,
          'email': cleanEmail,
          'phone': cleanPhone,
        },
      );
      if (!newShipperEmails.contains(cleanEmail)) {
        newShipperEmails.add(cleanEmail);
      }
      await loadShipperOrderData();
      return true;
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Unable to add shipper',
        message: error.toString(),
      );
      return false;
    }
  }

  void removeShipperEmail(int index) {
    if (index >= 0 && index < newShipperEmails.length) {
      newShipperEmails.removeAt(index);
    }
  }

  Future<bool> sendOrder() async {
    final vendorIds = shippers
        .where((item) => item.isSelected && !item.isSent)
        .map((item) => item.id)
        .where((id) => id.isNotEmpty)
        .toList();
    if (vendorIds.isEmpty) return false;
    isSending.value = true;
    try {
      final response = await apiClient.post(
        ApiEndpoints.plantSendConsolidatedBom(projectId.value),
        data: {'vendorIds': vendorIds},
      );
      if (response.data is Map && response.data['success'] == false) {
        throw Exception(response.data['message'] ?? 'Unable to send order.');
      }
      await loadShipperOrderData();
      return true;
    } catch (error) {
      CommonSnackbar.showError(title: 'Send failed', message: error.toString());
      return false;
    } finally {
      isSending.value = false;
    }
  }

  double _double(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
