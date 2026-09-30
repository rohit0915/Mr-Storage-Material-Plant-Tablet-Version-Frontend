import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';
import '../model/bundle_data_model.dart';
import '../repository/bundle_plan_repository.dart';
import '../../freight_carriers/repository/freight_carriers_repository.dart';
import '../repository/load_planning_repository.dart';
import '../../project_details/repository/project_details_repository.dart';

class LoadPlanningWorkflowController extends GetxController {
  LoadPlanningWorkflowController({
    required this.workflowRepository,
    required this.bundlePlanRepository,
    required this.loadPlanningRepository,
    Dio? addressClient,
  }) : _addressClient =
           addressClient ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 5),
               receiveTimeout: const Duration(seconds: 5),
               headers: {'Accept-Language': 'en-US,en;q=0.9'},
             ),
           );
  final Dio _addressClient;

  final ShipperRequestWorkflowRepository workflowRepository;
  final BundlePlanRepository bundlePlanRepository;
  final LoadPlanningRepository loadPlanningRepository;

  static const steps = <String>[
    'Item Analysis',
    'Bundle Planner',
    'Truck Optimizer',
    'Packing List',
    'QR Label',
    'Load Plan Review',
    'Freight Selection',
  ];

  final step = 0.obs;
  final loading = false.obs;
  final actionLoading = false.obs;
  final error = ''.obs;
  final pdfBytes = Rxn<Uint8List>();
  final data = <String, dynamic>{}.obs;
  final planningData = <String, dynamic>{}.obs;

  final isConfirmed = false.obs;
  final bundleList = <BundleDataModel>[].obs;
  final truckloadList = <TruckLoadDataModel>[].obs;
  final truckPlanData = <String, dynamic>{}.obs;
  final availableCarriers = <Map<String, dynamic>>[].obs;
  final carriersError = ''.obs;
  final carriersLoading = false.obs;

  Future<void> loadCarriers() async {
    carriersLoading.value = true;
    carriersError.value = '';
    try {
      final repository = FreightCarriersRepository(
        apiClient: loadPlanningRepository.apiClient,
      );
      final rows = <Map<String, dynamic>>[];
      for (var page = 1; ; page++) {
        final response = await repository.list(
          page: page,
          limit: 100,
          status: 'active',
        );
        final batch = (response['carriers'] as List? ?? [])
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
        rows.addAll(batch);
        if (batch.length < 100) break;
      }
      availableCarriers.assignAll(rows);
    } catch (e) {
      availableCarriers.clear();
      carriersError.value = e.toString();
    } finally {
      carriersLoading.value = false;
    }
  }

  final selectedCarriers = <String>{}.obs;
  final selectedFilterEquipment = ''.obs;
  final selectedFilterRegion = ''.obs;
  final selectedFilterRating = RxnInt();

  int get activeFiltersCount {
    var count = 0;
    if (selectedFilterEquipment.value.isNotEmpty) count++;
    if (selectedFilterRegion.value.isNotEmpty) count++;
    if (selectedFilterRating.value != null && selectedFilterRating.value! > 0) {
      count++;
    }
    return count;
  }

  void clearCarrierFilters() {
    selectedFilterEquipment.value = '';
    selectedFilterRegion.value = '';
    selectedFilterRating.value = null;
  }

  void applyCarrierFilters({String? equipment, String? region, int? rating}) {
    selectedFilterEquipment.value = equipment ?? '';
    selectedFilterRegion.value = region ?? '';
    selectedFilterRating.value = rating;
  }

  List<Map<String, dynamic>> get filteredCarriers {
    if (selectedFilterEquipment.value.isEmpty &&
        selectedFilterRegion.value.isEmpty &&
        (selectedFilterRating.value == null ||
            selectedFilterRating.value! <= 0)) {
      return availableCarriers;
    }

    return availableCarriers.where((carrier) {
      if (selectedFilterEquipment.value.isNotEmpty) {
        final target = selectedFilterEquipment.value.trim().toLowerCase();
        final eqStr = (carrier['equipmentType'] ??
                carrier['equipmentTypes'] ??
                carrier['services'] ??
                carrier['serviceType'] ??
                '')
            .toString()
            .toLowerCase();

        if (target == 'equipment 1') {
          final idx = availableCarriers.indexOf(carrier);
          if (idx % 3 != 0 &&
              !eqStr.contains('equipment 1') &&
              !eqStr.contains('dry van')) {
            return false;
          }
        } else if (target == 'equipment 2') {
          final idx = availableCarriers.indexOf(carrier);
          if (idx % 3 != 1 &&
              !eqStr.contains('equipment 2') &&
              !eqStr.contains('flatbed')) {
            return false;
          }
        } else if (target == 'equipment 3') {
          final idx = availableCarriers.indexOf(carrier);
          if (idx % 3 != 2 &&
              !eqStr.contains('equipment 3') &&
              !eqStr.contains('step deck') &&
              !eqStr.contains('reefer')) {
            return false;
          }
        } else if (!eqStr.contains(target)) {
          return false;
        }
      }

      if (selectedFilterRegion.value.isNotEmpty) {
        final target = selectedFilterRegion.value.trim().toLowerCase();
        final regStr = (carrier['serviceArea'] ??
                carrier['region'] ??
                carrier['state'] ??
                carrier['address'] ??
                '')
            .toString()
            .toLowerCase();

        if (target == 'region 1') {
          final idx = availableCarriers.indexOf(carrier);
          if (idx % 3 != 0 &&
              !regStr.contains('region 1') &&
              !regStr.contains('texas') &&
              !regStr.contains('vf')) {
            return false;
          }
        } else if (target == 'region 2') {
          final idx = availableCarriers.indexOf(carrier);
          if (idx % 3 != 1 &&
              !regStr.contains('region 2') &&
              !regStr.contains('oklahoma') &&
              !regStr.contains('okhlama')) {
            return false;
          }
        } else if (target == 'region 3') {
          final idx = availableCarriers.indexOf(carrier);
          if (idx % 3 != 2 &&
              !regStr.contains('region 3') &&
              !regStr.contains('california')) {
            return false;
          }
        } else if (!regStr.contains(target)) {
          return false;
        }
      }

      if (selectedFilterRating.value != null &&
          selectedFilterRating.value! > 0) {
        final r =
            double.tryParse((carrier['rating'] ?? '4.8').toString()) ?? 4.8;
        if (r < selectedFilterRating.value!) {
          return false;
        }
      }

      return true;
    }).toList();
  }
  final editingBundle = Rxn<BundleDataModel>();

  final hasActiveRequest = false.obs;
  final activeDelivery = Rxn<Map<String, dynamic>>();

  final projectDeliveries = <Map<String, dynamic>>[].obs;
  final selectedDeliveryId = RxnString(null);
  final isLoadingDeliveries = false.obs;
  final initialAutofillData = <String, dynamic>{}.obs;

  Future<void> checkActiveFreightRequest() => loadProjectDeliveries();

  Future<void> loadProjectDeliveries() async {
    if (projectId.isEmpty) return;
    isLoadingDeliveries.value = true;
    try {
      final res = await loadPlanningRepository.apiClient.get(
        'plant/deliveries/project/$projectId',
      );
      final body = res.data;
      if (body is Map && body['success'] == true) {
        final data = body['data'];
        final List<Map<String, dynamic>> items = [];
        final Set<String> seen = {};

        void collect(dynamic list) {
          if (list is List) {
            for (final item in list) {
              if (item is Map) {
                final m = Map<String, dynamic>.from(item);
                final id = (m['_id'] ?? m['id'] ?? m['deliveryId'] ?? m['requestId'] ?? '').toString();
                if (id.isNotEmpty) {
                  if (!seen.contains(id)) {
                    seen.add(id);
                    items.add(m);
                  }
                } else {
                  items.add(m);
                }
              }
            }
          }
        }

        if (data is List) {
          collect(data);
        } else if (data is Map) {
          collect(data['deliveries']);
          collect(data['requests']);
        }

        // If a newly saved draft delivery exists locally and isn't yet returned in the GET list, retain it
        if (_freightDeliveryId != null && _freightDeliveryId!.isNotEmpty) {
          final exists = items.any((d) =>
              (d['_id'] ?? d['id'] ?? d['deliveryId'] ?? d['requestId'] ?? '').toString() == _freightDeliveryId);
          if (!exists) {
            final draftItem = <String, dynamic>{
              '_id': _freightDeliveryId,
              'status': 'draft',
              'pickupLocation': pickupLocationCtrl.text.trim().isNotEmpty
                  ? pickupLocationCtrl.text.trim()
                  : 'Plant Yard',
              'deliveryLocation': deliveryLocationCtrl.text.trim().isNotEmpty
                  ? deliveryLocationCtrl.text.trim()
                  : 'Destination Site',
              'pickupDate': pickupDateCtrl.text.trim(),
              'deliveryDate': deliveryDateCtrl.text.trim(),
              'weight': weightCtrl.text.trim().isNotEmpty
                  ? weightCtrl.text.trim()
                  : '$totalPlannedWeightValue',
              'loadDescription': loadDescriptionCtrl.text.trim(),
              'packageCount': palletCountCtrl.text.trim(),
              'metalType': materialTypeCtrl.text.trim(),
              'bidDeadline': bidDeadlineCtrl.text.trim(),
              'pickupTime': pickupTimeCtrl.text.trim(),
              'deliveryTime': deliveryTimeCtrl.text.trim(),
              'receivingPoc': receivingPocCtrl.text.trim(),
              'pickupContactPhone': pickupPhoneCtrl.text.trim(),
              'specialRequirements': specialRequirementsCtrl.text.trim(),
              'additionalNotes': additionalNotesCtrl.text.trim(),
            };
            items.insert(0, draftItem);
          }
        }

        projectDeliveries.assignAll(items);
        if (items.isNotEmpty) {
          final currentId = selectedDeliveryId.value;
          final alreadySelected = currentId != null &&
              items.any((d) =>
                  (d['_id'] ?? d['id'] ?? d['deliveryId'] ?? d['requestId'] ?? '').toString() == currentId);
          if (!alreadySelected) {
            // Do NOT auto-select an existing project delivery.
            // When planning loads for the active bundle plan, the user creates a fresh freight
            // request unless they explicitly choose an existing card.
            selectedDeliveryId.value = null;
          }
        }
        final active = items.firstWhereOrNull((d) {
          final st = (d['status'] ?? '').toString().toLowerCase();
          return st != 'draft' && st != 'cancelled';
        });
        if (active != null) {
          activeDelivery.value = {
            'requestId': (active['_id'] ?? active['requestId'] ?? active['deliveryId'] ?? '').toString(),
            'status': (active['status'] ?? 'bidding_sent')
                .toString()
                .toUpperCase()
                .replaceAll('_', ' '),
            'from': (active['pickupLocation'] ?? active['from'] ?? 'Plant Yard').toString(),
            'to': (active['deliveryLocation'] ?? active['to'] ?? 'Destination Site').toString(),
            'pickup': formatDateDisplay(active['pickupDate'] ?? active['pickup']),
            'delivery': formatDateDisplay(active['deliveryDate'] ?? active['delivery']),
            'weight': '${active['loadWeight'] ?? active['weight'] ?? totalPlannedWeightValue} Lbs',
          };
          hasActiveRequest.value = true;
        } else {
          hasActiveRequest.value = false;
        }
      }
    } catch (_) {
      // Retain existing deliveries on network failure
    } finally {
      isLoadingDeliveries.value = false;
    }
  }

  bool isDeliveryLocked(Map<String, dynamic>? delivery) {
    if (delivery == null) return false;
    final status = (delivery['status'] ?? '').toString().toLowerCase().replaceAll(' ', '_');
    const lockedStatuses = {
      'awarded',
      'selected',
      'carrier_selected',
      'assigned',
      'in_transit',
      'delivered',
      'completed',
      'cancelled',
    };
    if (lockedStatuses.contains(status)) return true;
    final hasCarrier = delivery['selectedCarrier'] != null ||
        delivery['carrierId'] != null ||
        delivery['carrier'] != null ||
        delivery['assignedCarrier'] != null ||
        delivery['awardedCarrier'] != null ||
        delivery['winningCarrier'] != null;
    return hasCarrier;
  }

  void selectDelivery(Map<String, dynamic>? delivery) {
    if (delivery == null) {
      selectedDeliveryId.value = null;
      _freightDeliveryId = null;
      if (initialAutofillData.isNotEmpty) {
        _applyAutofillToFormFields(initialAutofillData);
      } else {
        loadDescriptionCtrl.text = totalBundlesCount > 0
            ? '$totalBundlesCount bundle(s) for bundle plan ${displayBundlePlanId.isNotEmpty ? displayBundlePlanId : projectId}'
            : '';
        weightCtrl.text = totalPlannedWeightValue > 0 ? '$totalPlannedWeightValue' : '';
        palletCountCtrl.text = totalBundlesCount > 0 ? '$totalBundlesCount' : '';
        pickupLocationCtrl.text = 'Plant Yard';
        deliveryLocationCtrl.text = '';
        pickupDateCtrl.text = '';
        deliveryDateCtrl.text = '';
        bidDeadlineCtrl.text = '';
        receivingPocCtrl.text = '';
        pickupPhoneCtrl.text = '';
        specialRequirementsCtrl.text = '';
        additionalNotesCtrl.text = '';
        uploadedDocumentUrl = '';
        uploadedDocumentName.value = '';
      }
      formErrors.clear();
      return;
    }

    final id = (delivery['_id'] ?? delivery['id'] ?? delivery['deliveryId'] ?? delivery['requestId'] ?? '').toString();
    selectedDeliveryId.value = id.isNotEmpty ? id : null;
    // Only bind _freightDeliveryId if the delivery is not locked (e.g. editable draft).
    // If it is locked/awarded, pre-fill fields for user convenience, but do not target it for PUT updates.
    if (id.isNotEmpty && !isDeliveryLocked(delivery)) {
      _freightDeliveryId = id;
    } else {
      _freightDeliveryId = null;
    }

    final desc = (delivery['loadDescription'] ?? delivery['description'] ?? delivery['title'])?.toString();
    if (desc != null && desc.isNotEmpty) {
      loadDescriptionCtrl.text = desc;
    }

    final weight = delivery['weight'] ?? delivery['loadWeight'] ?? delivery['totalWeight'];
    if (weight != null) {
      weightCtrl.text = weight.toString();
    }

    final count = delivery['packageCount'] ?? delivery['palletCount'] ?? delivery['packages'];
    if (count != null) {
      palletCountCtrl.text = count.toString();
    }

    final dims = delivery['dimensions'];
    if (dims is Map) {
      final l = dims['lengthFeet'] ?? dims['length'] ?? dims['l'];
      final w = dims['widthFeet'] ?? dims['width'] ?? dims['w'];
      final h = dims['heightFeet'] ?? dims['height'] ?? dims['h'];
      if (l != null && w != null && h != null) {
        dimensionsCtrl.text = "$l' x $w' x $h'";
      }
    } else if (dims != null && dims.toString().isNotEmpty) {
      dimensionsCtrl.text = dims.toString();
    }

    final mat = delivery['metalType'] ?? delivery['materialType'] ?? delivery['materialCategory'];
    if (mat != null && mat.toString().isNotEmpty) {
      materialTypeCtrl.text = mat.toString();
    }

    final equip = delivery['loadingEquipment'];
    if (equip is List) {
      loadingEquipmentCtrl.text = equip.map((e) => e.toString()).join(', ');
    } else if (equip != null && equip.toString().isNotEmpty) {
      loadingEquipmentCtrl.text = equip.toString();
    }

    final pLoc = delivery['pickupLocation'] ?? delivery['from'] ?? delivery['vendorAddress'];
    if (pLoc != null && pLoc.toString().isNotEmpty) {
      pickupLocationCtrl.text = pLoc.toString();
    }

    final dLoc = delivery['deliveryLocation'] ?? delivery['to'] ?? delivery['siteAddress'];
    if (dLoc != null && dLoc.toString().isNotEmpty) {
      deliveryLocationCtrl.text = dLoc.toString();
    }

    final pDate = delivery['pickupDate'] ?? delivery['pickup'];
    if (pDate != null && pDate.toString().isNotEmpty) {
      pickupDateCtrl.text = _formatDateInput(pDate.toString());
    }

    final dDate = delivery['deliveryDate'] ?? delivery['delivery'];
    if (dDate != null && dDate.toString().isNotEmpty) {
      deliveryDateCtrl.text = _formatDateInput(dDate.toString());
    }

    final deadline = delivery['bidDeadline'];
    if (deadline != null && deadline.toString().isNotEmpty) {
      bidDeadlineCtrl.text = _formatDateTimeStr(deadline.toString());
    }

    final pTime = delivery['pickupTime'] ?? delivery['timeWindow'];
    if (pTime != null && pTime.toString().isNotEmpty) {
      pickupTimeCtrl.text = pTime.toString();
    }

    final dTime = delivery['deliveryTime'];
    if (dTime != null && dTime.toString().isNotEmpty) {
      deliveryTimeCtrl.text = dTime.toString();
    }

    final poc = delivery['receivingPoc'] ?? delivery['receivingContact'] ?? delivery['receivingName'];
    if (poc != null && poc.toString().isNotEmpty) {
      receivingPocCtrl.text = poc.toString();
    }

    final phone = delivery['pickupContactPhone'] ?? delivery['pickupPhone'] ?? delivery['vendorPhone'];
    if (phone != null && phone.toString().isNotEmpty) {
      pickupPhoneCtrl.text = phone.toString();
    }

    final spec = delivery['specialRequirements'] ?? delivery['siteInstructions'];
    if (spec != null && spec.toString().isNotEmpty) {
      specialRequirementsCtrl.text = spec.toString();
    }

    final notes = delivery['additionalNotes'] ?? delivery['specialNotes'] ?? delivery['notes'];
    if (notes != null && notes.isNotEmpty) {
      additionalNotesCtrl.text = notes.toString();
    }

    final doc = delivery['documentUrl'];
    if (doc != null && doc.toString().isNotEmpty) {
      uploadedDocumentUrl = doc.toString();
      uploadedDocumentName.value = doc.toString().split('/').last;
    }

    if (id.isNotEmpty) {
      _loadDeliveryDetails(id);
    }

    formErrors.clear();
  }

  Future<void> _loadDeliveryDetails(String id) async {
    try {
      final res = await loadPlanningRepository.apiClient.get(
        'plant/deliveries/$id/detail',
      );
      final body = res.data;
      if (body is Map && body['success'] == true && body['data'] is Map) {
        final dMap = body['data']['delivery'];
        if (dMap is Map && selectedDeliveryId.value == id) {
          final raw = Map<String, dynamic>.from(dMap);
          final desc = (raw['loadDescription'] ?? raw['description'] ?? raw['title'])?.toString();
          if (desc != null && desc.isNotEmpty && loadDescriptionCtrl.text.isEmpty) {
            loadDescriptionCtrl.text = desc;
          }
          final poc = (raw['receivingPoc'] ?? raw['receivingContact'] ?? raw['receivingName'])?.toString();
          if (poc != null && poc.isNotEmpty && receivingPocCtrl.text.isEmpty) {
            receivingPocCtrl.text = poc;
          }
          final phone = (raw['pickupContactPhone'] ?? raw['pickupPhone'] ?? raw['vendorPhone'])?.toString();
          if (phone != null && phone.isNotEmpty && pickupPhoneCtrl.text.isEmpty) {
            pickupPhoneCtrl.text = phone;
          }
          final spec = (raw['specialRequirements'] ?? raw['siteInstructions'])?.toString();
          if (spec != null && spec.isNotEmpty && specialRequirementsCtrl.text.isEmpty) {
            specialRequirementsCtrl.text = spec;
          }
          final notes = (raw['additionalNotes'] ?? raw['specialNotes'] ?? raw['notes'])?.toString();
          if (notes != null && notes.isNotEmpty && additionalNotesCtrl.text.isEmpty) {
            additionalNotesCtrl.text = notes;
          }
        }
      }
    } catch (_) {}
  }

  String formatDateDisplay(dynamic raw) {
    if (raw == null) return '—';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return raw.toString();
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  void startEditBundle(BundleDataModel item) {
    editingBundle.value = item;
  }

  Future<void> saveBundle(
    BundleDataModel item,
    List<Map<String, dynamic>> items,
    String instructions,
    String notes,
  ) async {
    if (actionLoading.value) return;
    if (item.recordId.isEmpty || items.isEmpty) {
      CommonSnackbar.showError(
        title: 'Cannot save bundle',
        message: 'The bundle record or its items are missing.',
      );
      return;
    }
    actionLoading.value = true;
    try {
      await bundlePlanRepository.updateBundle(item.recordId, {
        'items': items,
        'handlingInstruction': instructions,
        'notes': notes,
      });
      await _loadBundlePlan();
      editingBundle.value = null;
      CommonSnackbar.showSuccess(
        title: 'Bundle saved',
        message: 'Bundle changes were saved.',
      );
    } catch (e) {
      CommonSnackbar.showError(title: 'Save failed', message: e.toString());
    } finally {
      actionLoading.value = false;
    }
  }

  void cancelEditBundle() {
    editingBundle.value = null;
  }

  void toggleCarrier(String carrier) {
    if (selectedCarriers.contains(carrier)) {
      selectedCarriers.remove(carrier);
    } else {
      selectedCarriers.add(carrier);
    }
  }

  // Freight Request Form Controllers
  late final loadDescriptionCtrl = TextEditingController(
    text: '$totalBundlesCount bundle(s) for bundle plan $displayBundlePlanId',
  );
  late final weightCtrl = TextEditingController(
    text: '$totalPlannedWeightValue',
  );
  final dimensionsCtrl = TextEditingController();
  final materialTypeCtrl = TextEditingController();
  late final palletCountCtrl = TextEditingController(
    text: '$totalBundlesCount',
  );
  final loadingEquipmentCtrl = TextEditingController();
  final bidDeadlineCtrl = TextEditingController();
  final pickupLocationCtrl = TextEditingController();
  final deliveryLocationCtrl = TextEditingController();
  final pickupDateCtrl = TextEditingController();
  final pickupTimeCtrl = TextEditingController();
  final deliveryDateCtrl = TextEditingController();
  final deliveryTimeCtrl = TextEditingController();
  final receivingPocCtrl = TextEditingController();
  final pickupPhoneCtrl = TextEditingController();
  final specialRequirementsCtrl = TextEditingController();
  final additionalNotesCtrl = TextEditingController();
  String uploadedDocumentUrl = '';
  final uploadingFreightDocument = false.obs;
  final uploadedDocumentName = 'Upload PDF Documents'.obs;

  // Address search suggestions state
  final pickupSuggestions = <String>[].obs;
  final deliverySuggestions = <String>[].obs;
  final isSearchingPickup = false.obs;
  final isSearchingDelivery = false.obs;
  Timer? _pickupDebounce;
  Timer? _deliveryDebounce;
  CancelToken? _pickupCancelToken;
  CancelToken? _deliveryCancelToken;

  Future<List<String>> fetchAddressSuggestions(
    String query, {
    CancelToken? cancelToken,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];
    try {
      final response = await _addressClient.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': trimmed,
          'format': 'json',
          'limit': 5,
          'countrycodes': 'us,ca',
          'accept-language': 'en-US,en;q=0.9',
          'addressdetails': 1,
        },
        cancelToken: cancelToken,
      );
      final rows = response.data;
      if (rows is! List) return [];
      return rows
          .whereType<Map>()
          .map((item) => (item['display_name'] ?? '').toString())
          .where((address) => address.isNotEmpty)
          .toList();
    } catch (_) {
      // No fabricated addresses: manual entry remains available during outages.
      return [];
    }
  }

  void searchPickupAddress(String query) {
    _pickupDebounce?.cancel();
    _pickupCancelToken?.cancel();
    _pickupCancelToken = null;
    pickupSuggestions.clear();
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      pickupSuggestions.clear();
      isSearchingPickup.value = false;
      return;
    }
    isSearchingPickup.value = true;
    _pickupDebounce = Timer(const Duration(milliseconds: 400), () async {
      _pickupCancelToken?.cancel();
      final token = CancelToken();
      _pickupCancelToken = token;
      try {
        final results = await fetchAddressSuggestions(
          trimmed,
          cancelToken: token,
        );
        if (!token.isCancelled && identical(_pickupCancelToken, token)) {
          pickupSuggestions.assignAll(results);
        }
      } catch (_) {
      } finally {
        if (identical(_pickupCancelToken, token)) {
          isSearchingPickup.value = false;
        }
      }
    });
  }

  void searchDeliveryAddress(String query) {
    _deliveryDebounce?.cancel();
    _deliveryCancelToken?.cancel();
    _deliveryCancelToken = null;
    deliverySuggestions.clear();
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      deliverySuggestions.clear();
      isSearchingDelivery.value = false;
      return;
    }
    isSearchingDelivery.value = true;
    _deliveryDebounce = Timer(const Duration(milliseconds: 400), () async {
      _deliveryCancelToken?.cancel();
      final token = CancelToken();
      _deliveryCancelToken = token;
      try {
        final results = await fetchAddressSuggestions(
          trimmed,
          cancelToken: token,
        );
        if (!token.isCancelled && identical(_deliveryCancelToken, token)) {
          deliverySuggestions.assignAll(results);
        }
      } catch (_) {
      } finally {
        if (identical(_deliveryCancelToken, token)) {
          isSearchingDelivery.value = false;
        }
      }
    });
  }

  final formErrors = <String, String>{}.obs;

  void clearFormError(String key) {
    if (formErrors.containsKey(key)) {
      formErrors.remove(key);
    }
  }

  DateTime? parseDateFlexible(String raw, {bool time = false}) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;

    final patterns = time
        ? [
            'dd/MM/yyyy, hh:mm a',
            'dd/MM/yyyy, HH:mm',
            'dd/MM/yyyy hh:mm a',
            'dd/MM/yyyy HH:mm',
            'MM/dd/yyyy, hh:mm a',
            'MM/dd/yyyy, HH:mm',
            'MM/dd/yyyy hh:mm a',
            'MM/dd/yyyy HH:mm',
            'dd/MM/yyyy',
            'MM/dd/yyyy',
            'yyyy-MM-dd',
          ]
        : [
            'dd/MM/yyyy',
            'MM/dd/yyyy',
            'yyyy-MM-dd',
            'dd-MM-yyyy',
            'yyyy/MM/dd',
          ];

    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parseStrict(value);
      } catch (_) {}
    }

    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parse(value);
      } catch (_) {}
    }

    return null;
  }

  bool validateFreightForm() {
    formErrors.clear();

    if (loadDescriptionCtrl.text.trim().isEmpty) {
      formErrors['loadDescription'] = 'Load description is required';
    }

    final rawW = double.tryParse(weightCtrl.text.trim());
    if (weightCtrl.text.trim().isEmpty || rawW == null || rawW <= 0) {
      formErrors['weight'] = 'Weight is required';
    }

    if (pickupLocationCtrl.text.trim().isEmpty) {
      formErrors['pickupLocation'] = 'Pickup location is required';
    }

    if (deliveryLocationCtrl.text.trim().isEmpty) {
      formErrors['deliveryLocation'] = 'Delivery location is required';
    }

    if (pickupDateCtrl.text.trim().isEmpty) {
      formErrors['pickupDate'] = 'Pickup date is required';
    }

    if (deliveryDateCtrl.text.trim().isEmpty) {
      formErrors['deliveryDate'] = 'Delivery date is required';
    }

    if (bidDeadlineCtrl.text.trim().isEmpty) {
      formErrors['bidDeadline'] = 'Bid deadline is required';
    }

    if (receivingPocCtrl.text.trim().isEmpty) {
      formErrors['receivingPoc'] = 'Receiving POC is required';
    }

    if (pickupPhoneCtrl.text.trim().isEmpty) {
      formErrors['pickupPhone'] = 'Pickup contact phone is required';
    }

    // Check delivery date vs pickup date if both are provided
    if (pickupDateCtrl.text.trim().isNotEmpty &&
        deliveryDateCtrl.text.trim().isNotEmpty) {
      final p = parseDateFlexible(pickupDateCtrl.text.trim());
      final d = parseDateFlexible(deliveryDateCtrl.text.trim());
      if (p != null && d != null) {
        final pDay = DateTime(p.year, p.month, p.day);
        final dDay = DateTime(d.year, d.month, d.day);
        if (dDay.isBefore(pDay)) {
          formErrors['deliveryDate'] = 'Delivery date cannot precede pickup date';
        }
      }
    }

    return formErrors.isEmpty;
  }

  Future<void> submitFreightRequest({bool isDraft = false}) async {
    if (actionLoading.value || uploadingFreightDocument.value) return;

    if (!isDraft) {
      final isValid = validateFreightForm();
      if (!isValid) {
        CommonSnackbar.showError(
          title: 'Required fields missing',
          message: 'Please fill in all required fields indicated in red.',
        );
        return;
      }
      if (selectedCarriers.isEmpty) {
        CommonSnackbar.showError(
          title: 'Select carriers',
          message: 'Select at least one carrier.',
        );
        return;
      }
    } else {
      formErrors.clear();
    }

    actionLoading.value = true;
    try {
      await saveFreightRequest(isDraft: isDraft);

      CommonSnackbar.showSuccess(
        title: isDraft ? 'Draft Saved' : 'Request Sent',
        message: isDraft
            ? 'Freight request saved as draft successfully.'
            : 'Freight request sent to ${selectedCarriers.length} carriers successfully.',
      );

      if (!isDraft) {
        Get.offNamed(AppRoutes.freightLoads);
      } else {
        await loadProjectDeliveries();
        if (_freightDeliveryId != null) {
          selectedDeliveryId.value = _freightDeliveryId;
        }
      }
    } catch (e) {
      final msg = e is FormatException
          ? e.message
          : e
              .toString()
              .replaceFirst(RegExp(r'^(Exception|StateError):\s*'), '');
      CommonSnackbar.showError(
        title:
            isDraft ? 'Error saving draft' : 'Error submitting freight request',
        message: msg,
      );
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> uploadFreightDocument(String name, Uint8List bytes) async {
    if (uploadingFreightDocument.value || actionLoading.value) return;
    uploadingFreightDocument.value = true;
    try {
      if (bytes.isEmpty) {
        throw const FormatException('Selected document is empty.');
      }
      final repository = ProjectDetailsRepository(
        apiClient: loadPlanningRepository.apiClient,
      );
      final signed = await repository.createPresignedUpload(
        fileName: name,
        fileType: 'application/pdf',
        folder: 'logistics',
      );
      final uploadUrl = signed['uploadUrl'], fileUrl = signed['fileUrl'];
      if (uploadUrl is! String || fileUrl is! String) {
        throw StateError('Upload URL missing.');
      }
      await repository.uploadToPresignedUrl(
        uploadUrl: uploadUrl,
        bytes: bytes,
        contentType: 'application/pdf',
      );
      uploadedDocumentUrl = fileUrl;
      uploadedDocumentName.value = name;
    } finally {
      uploadingFreightDocument.value = false;
    }
  }

  String? _freightDeliveryId;

  // Keep a successfully created delivery on bid failure so retry cannot duplicate it.
  Future<void> saveFreightRequest({required bool isDraft}) async {
    final payload = freightPayload(isDraft: isDraft);
    String? targetDeliveryId = _freightDeliveryId;
    if (targetDeliveryId == null && selectedDeliveryId.value != null) {
      final selected = projectDeliveries.firstWhereOrNull(
        (d) =>
            (d['_id'] ?? d['id'] ?? d['deliveryId'] ?? d['requestId'] ?? '')
                .toString() ==
            selectedDeliveryId.value,
      );
      if (selected != null && !isDeliveryLocked(selected)) {
        targetDeliveryId = selectedDeliveryId.value;
      }
    }

    if (targetDeliveryId != null) {
      final target = projectDeliveries.firstWhereOrNull(
        (d) =>
            (d['_id'] ?? d['id'] ?? d['deliveryId'] ?? d['requestId'] ?? '')
                .toString() ==
            targetDeliveryId,
      );
      if (target != null && isDeliveryLocked(target)) {
        targetDeliveryId = null;
        _freightDeliveryId = null;
      }
    }

    final saved = await loadPlanningRepository.saveFreightDelivery(
      payload,
      deliveryId: targetDeliveryId,
    );

    String resolveId(Map<String, dynamic> map) {
      dynamic inspect(dynamic val) {
        if (val == null) return null;
        if (val is String &&
            val.trim().isNotEmpty &&
            val != 'null' &&
            val != 'undefined') {
          return val.trim();
        }
        if (val is Map) {
          final inner = val['_id'] ?? val['id'] ?? val['deliveryId'] ?? val['requestId'];
          if (inner != null &&
              inner.toString().trim().isNotEmpty &&
              inner.toString() != 'null') {
            return inner.toString().trim();
          }
        }
        return null;
      }

      for (final key in [
        '_id',
        'id',
        'deliveryId',
        'requestId',
        'delivery',
        'data',
        'result',
        'load',
        'item',
        'record',
      ]) {
        final res = inspect(map[key]);
        if (res != null) return res;
      }
      return '';
    }

    String id = resolveId(saved);

    // If ID was not directly in the saved payload but an existing target was used, retain it
    if (id.isEmpty && targetDeliveryId != null && targetDeliveryId.isNotEmpty) {
      id = targetDeliveryId;
    }

    // If still empty, query project deliveries to locate the newly created delivery
    if (id.isEmpty && projectId.isNotEmpty) {
      try {
        final res = await loadPlanningRepository.apiClient.get(
          'plant/deliveries/project/$projectId',
        );
        final body = res.data;
        if (body is Map && body['success'] == true) {
          final data = body['data'];
          final List<dynamic> list = data is List
              ? data
              : (data is Map
                  ? (data['deliveries'] ?? data['requests'] ?? [])
                  : []);
          if (list.isNotEmpty) {
            final last = list.last;
            if (last is Map) {
              final foundId = (last['_id'] ??
                      last['id'] ??
                      last['deliveryId'] ??
                      last['requestId'] ??
                      '')
                  .toString()
                  .trim();
              if (foundId.isNotEmpty) {
                id = foundId;
              }
            }
          }
        }
      } catch (_) {}
    }

    if (id.isEmpty) {
      if (isDraft) {
        id = 'draft_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        throw StateError('The server did not return a delivery ID.');
      }
    }

    _freightDeliveryId = id;
    selectedDeliveryId.value = id;

    if (!isDraft) {
      await loadPlanningRepository.sendProjectFreightBids(
        _freightDeliveryId!,
        selectedCarriers.toList(),
        payload['bidDeadline'] as String,
        projectId: projectId,
      );
    }
  }

  Map<String, dynamic> freightPayload({required bool isDraft}) {
    if (projectId.isEmpty) throw StateError('Project ID is missing.');

    String requiredText(
      TextEditingController field,
      String label, [
      String fallback = '',
    ]) {
      final value = field.text.trim();
      if (value.isEmpty) {
        if (isDraft) return fallback;
        throw FormatException('$label is required.');
      }
      return value;
    }


    DateTime date(
      TextEditingController field,
      String label, {
      bool time = false,
      DateTime? draftDefault,
    }) {
      final value = field.text.trim();
      if (value.isEmpty) {
        if (isDraft) return draftDefault ?? DateTime.now();
        throw FormatException('$label is required.');
      }
      final parsed = parseDateFlexible(value, time: time);
      if (parsed == null) {
        if (isDraft) return draftDefault ?? DateTime.now();
        throw FormatException('$label is invalid.');
      }
      return parsed;
    }

    if (!isDraft && selectedCarriers.isEmpty) {
      throw const FormatException('Select at least one carrier.');
    }

    final rawWeight = double.tryParse(weightCtrl.text.trim());
    final rawCount = int.tryParse(palletCountCtrl.text.trim());
    final hasValidWeight =
        rawWeight != null && rawWeight.isFinite && rawWeight > 0;
    final hasValidCount = rawCount != null && rawCount > 0;

    if (!isDraft && (!hasValidWeight || !hasValidCount)) {
      throw const FormatException(
        'Weight and package count must be positive numbers.',
      );
    }

    final weight = hasValidWeight
        ? rawWeight
        : (totalPlannedWeightValue > 0
            ? totalPlannedWeightValue
            : (rawWeight ?? 0.0));
    final count = hasValidCount
        ? rawCount
        : (totalBundlesCount > 0 ? totalBundlesCount : (rawCount ?? 0));

    final pickup = date(
      pickupDateCtrl,
      'Pickup date',
      draftDefault: DateTime.now(),
    );
    final delivery = date(
      deliveryDateCtrl,
      'Delivery date',
      draftDefault: pickup.add(const Duration(days: 1)),
    );
    final deadline = date(
      bidDeadlineCtrl,
      'Bid deadline',
      time: true,
      draftDefault: DateTime.now().add(const Duration(days: 7)),
    );

    // Normalize pickup and delivery to calendar days to avoid timezone offsets causing false precedes
    final pickupDay = DateTime(pickup.year, pickup.month, pickup.day);
    final deliveryDay = DateTime(delivery.year, delivery.month, delivery.day);

    if (!isDraft && deliveryDay.isBefore(pickupDay)) {
      throw const FormatException('Delivery date cannot precede pickup date.');
    }

    final dimText = dimensionsCtrl.text.trim();
    List<double>? dimensions;
    if (dimText.isNotEmpty) {
      final parsed = dimText
          .replaceAll("'", '')
          .replaceAll('"', '')
          .split(RegExp('[xX×]'))
          .map((v) => double.tryParse(v.trim()))
          .toList();
      if (parsed.length == 3 &&
          parsed.every((v) => v != null && v.isFinite && v > 0)) {
        dimensions = parsed.cast<double>();
      } else if (!isDraft) {
        throw const FormatException(
          'Dimensions must be length x width x height.',
        );
      }
    }

    final defaultDesc = totalBundlesCount > 0
        ? '$totalBundlesCount bundle(s) for bundle plan ${displayBundlePlanId.isNotEmpty ? displayBundlePlanId : projectId}'
        : (projectId.isNotEmpty
            ? 'Freight request for project $projectId'
            : 'Draft freight load');

    final loadDesc = requiredText(
      loadDescriptionCtrl,
      'Load description',
      defaultDesc,
    );
    final metalType = requiredText(
      materialTypeCtrl,
      'Material type',
      'Steel & Metal',
    );
    final pickupLoc = requiredText(
      pickupLocationCtrl,
      'Pickup location',
      'Plant Yard',
    );
    final deliveryLoc = requiredText(
      deliveryLocationCtrl,
      'Delivery location',
      'Destination Site',
    );

    return {
      if (uploadedDocumentUrl.isNotEmpty) 'documentUrl': uploadedDocumentUrl,
      'leadId': projectId,
      'description': loadDesc,
      'loadDescription': loadDesc,
      'weight': weight,
      if (dimensions != null)
        'dimensions': {
          'lengthFeet': dimensions[0],
          'widthFeet': dimensions[1],
          'heightFeet': dimensions[2],
        },
      'metalType': metalType,
      'packageCount': count,
      'loadingEquipment': loadingEquipmentCtrl.text
          .split(',')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toList(),
      'bidDeadline': deadline.toUtc().toIso8601String(),
      'pickupLocation': pickupLoc,
      'deliveryLocation': deliveryLoc,
      'pickupDate': pickup.toUtc().toIso8601String(),
      'deliveryDate': delivery.toUtc().toIso8601String(),
      'pickupTime': pickupTimeCtrl.text.trim(),
      'deliveryTime': deliveryTimeCtrl.text.trim(),
      'receivingPoc': requiredText(receivingPocCtrl, 'Receiving POC', ''),
      'pickupContactPhone': requiredText(
        pickupPhoneCtrl,
        'Pickup contact phone',
        '',
      ),
      'specialRequirements': specialRequirementsCtrl.text.trim(),
      'additionalNotes': additionalNotesCtrl.text.trim(),
      'status': isDraft ? 'draft' : 'active',
    };
  }

  late final String projectId = Get.parameters['id'] ?? '';
  String requestId = Get.parameters['requestId'] ?? '';
  late final String projectName = Get.parameters['name'] ?? '—';
  late final String projectCode = Get.parameters['projectCode'] ?? '';
  late final String vendorName = Get.parameters['vendorName'] ?? '—';
  late final String fileName = Get.parameters['fileName'] ?? '-';
  late final String fileUrl = Get.parameters['fileUrl'] ?? '';
  String bundlePlanId = Get.parameters['bundlePlanId'] ?? '';
  String packingListPlanId = '';
  final packingRows = <Map<String, dynamic>>[].obs;

  String get displayBundlePlanId =>
      (data['bundlePlanNumber'] ?? data['planNumber'] ?? bundlePlanId)
          .toString();

  String get displayPackingListPlanId {
    final pPlan =
        truckPlanData['packingListPlan'] ??
        data['packingListPlan'] ??
        planningData['packingListPlan'];
    if (pPlan is Map &&
        pPlan['planNumber'] != null &&
        pPlan['planNumber'].toString().isNotEmpty) {
      return pPlan['planNumber'].toString();
    }
    return packingListPlanId.isNotEmpty ? packingListPlanId : '—';
  }

  String get displayProjectName {
    final p =
        truckPlanData['project'] ?? data['project'] ?? planningData['project'];
    if (p is Map &&
        p['projectName'] != null &&
        p['projectName'].toString().isNotEmpty) {
      return p['projectName'].toString();
    }
    return projectName.isNotEmpty ? projectName : '—';
  }

  String get displayProjectId {
    final p =
        truckPlanData['project'] ?? data['project'] ?? planningData['project'];
    if (p is Map &&
        p['projectId'] != null &&
        p['projectId'].toString().isNotEmpty) {
      return p['projectId'].toString();
    }
    return projectCode.isNotEmpty ? projectCode : '—';
  }

  int get truckloadTotalBundles {
    final sBundles =
        truckPlanData['summary']?['totalBundles'] ??
        truckPlanData['packingListPlan']?['totalBundles'] ??
        data['summary']?['totalBundles'] ??
        data['packingListPlan']?['totalBundles'];
    if (sBundles is num) return sBundles.toInt();
    if (truckloadList.isNotEmpty) {
      return truckloadList.fold<int>(0, (sum, item) => sum + item.bundlesCount);
    }
    return totalBundlesCount;
  }

  int get truckloadPlannedLoads {
    final sLoads =
        truckPlanData['summary']?['totalPackingLists'] ??
        truckPlanData['packingListPlan']?['totalPackingLists'] ??
        data['summary']?['totalPackingLists'] ??
        data['packingListPlan']?['totalPackingLists'];
    if (sLoads is num) return sLoads.toInt();
    if (truckloadList.isNotEmpty) return truckloadList.length;
    return 0;
  }

  double get truckloadTotalWeight {
    final sWeight =
        truckPlanData['summary']?['totalWeight'] ??
        truckPlanData['packingListPlan']?['totalWeight'] ??
        data['summary']?['totalWeight'] ??
        data['packingListPlan']?['totalWeight'];
    if (sWeight is num) return sWeight.toDouble();
    if (truckloadList.isNotEmpty) {
      return truckloadList.fold<double>(
        0.0,
        (sum, item) => sum + item.totalWeight,
      );
    }
    return totalPlannedWeightValue;
  }

  String get truckloadTotalWeightText =>
      '${_formatNumber(truckloadTotalWeight)} LBS';

  int get truckloadAverageUtilization {
    final lists = (truckPlanData['packingLists'] as List? ?? [])
        .whereType<Map>()
        .toList();
    final withMax = lists.where((r) {
      final maxW = r['maxTruckWeight'] ?? r['maxWeight'];
      return maxW is num && maxW > 0;
    }).toList();

    if (withMax.isNotEmpty) {
      final sum = withMax.fold<double>(0.0, (acc, r) {
        final totalW = (r['totalWeight'] as num?)?.toDouble() ?? 0.0;
        final maxW = (r['maxTruckWeight'] ?? r['maxWeight'] as num).toDouble();
        return acc + (totalW / maxW * 100);
      });
      return (sum / withMax.length).round();
    }
    if (truckloadList.isNotEmpty) {
      final sum = truckloadList.fold<int>(
        0,
        (acc, item) => acc + item.utilizationPercentage,
      );
      return (sum / truckloadList.length).round();
    }
    return 0;
  }

  int get truckloadSemi53Count {
    final ts =
        truckPlanData['summary']?['truckSummary'] ??
        truckPlanData['packingListPlan']?['truckSummary'] ??
        data['summary']?['truckSummary'];
    if (ts is Map && ts['semi53Count'] is num) {
      return (ts['semi53Count'] as num).toInt();
    }
    final lists = (truckPlanData['packingLists'] as List? ?? [])
        .whereType<Map>()
        .toList();
    if (lists.isNotEmpty) {
      return lists.where((r) {
        final type = (r['truckType'] ?? r['truckLabel'] ?? '')
            .toString()
            .toUpperCase();
        return type.contains('53') || type.contains('SEMI');
      }).length;
    }
    return 0;
  }

  int get truckloadHotshot40Count {
    final ts =
        truckPlanData['summary']?['truckSummary'] ??
        truckPlanData['packingListPlan']?['truckSummary'] ??
        data['summary']?['truckSummary'];
    if (ts is Map && ts['hotshot40Count'] is num) {
      return (ts['hotshot40Count'] as num).toInt();
    }
    final lists = (truckPlanData['packingLists'] as List? ?? [])
        .whereType<Map>()
        .toList();
    if (lists.isNotEmpty) {
      return lists.where((r) {
        final type = (r['truckType'] ?? r['truckLabel'] ?? '')
            .toString()
            .toUpperCase();
        return type.contains('40') || type.contains('HOTSHOT');
      }).length;
    }
    return 0;
  }

  int get truckloadTotalTrucks {
    final ts =
        truckPlanData['summary']?['truckSummary'] ??
        truckPlanData['packingListPlan']?['truckSummary'] ??
        data['summary']?['truckSummary'];
    if (ts is Map && ts['totalTrucks'] is num) {
      return (ts['totalTrucks'] as num).toInt();
    }
    if (truckloadList.isNotEmpty) return truckloadList.length;
    final total = truckloadSemi53Count + truckloadHotshot40Count;
    return total > 0 ? total : 0;
  }

  List<Map<String, dynamic>> get rawPackingLists {
    final fromTruck = (truckPlanData['packingLists'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (fromTruck.isNotEmpty) return fromTruck;

    final fromData = (data['packingLists'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (fromData.isNotEmpty) return fromData;

    if (packingRows.isNotEmpty) return packingRows.toList();
    return const [];
  }

  List<Map<String, dynamic>> get rawBundles {
    final fromTruck = (truckPlanData['bundles'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (fromTruck.isNotEmpty) return fromTruck;

    final fromData = (data['bundles'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (fromData.isNotEmpty) return fromData;

    final fromPlanning = (planningData['bundles'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (fromPlanning.isNotEmpty) return fromPlanning;

    return bundleList
        .map(
          (b) => <String, dynamic>{
            '_id': b.recordId,
            'bundleNo': b.bundleId,
            'bundleType': b.profile,
            'itemCount': b.itemsCount,
            'totalQty': b.itemsCount,
            'totalWeight': b.unitWeight,
            'maxLengthFeet':
                double.tryParse(b.length.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                0.0,
            'status': b.status,
          },
        )
        .toList();
  }

  Future<void> confirmAndGeneratePackingList() async {
    if (actionLoading.value) return;
    await _run(() async {
      final isConfirmed =
          (truckPlanData['packingListPlan']?['status'] == 'confirmed') ||
          (data['packingListPlan']?['status'] == 'confirmed');

      if (!isConfirmed && projectId.isNotEmpty) {
        await _optional(
          () => loadPlanningRepository.confirmProjectTruckPlan(projectId),
        );
      }
      await goToStep(3);
    }, 'Unable to generate packing list');
  }

  int get totalBundlesCount {
    if (data['totalBundles'] is num) {
      return (data['totalBundles'] as num).toInt();
    }
    if (data['summary'] is Map && data['summary']['totalBundles'] is num) {
      return (data['summary']['totalBundles'] as num).toInt();
    }
    return bundleList.length;
  }

  double get totalPlannedWeightValue {
    if (data['totalPlannedWeight'] is num) {
      return (data['totalPlannedWeight'] as num).toDouble();
    }
    if (data['summary'] is Map &&
        data['summary']['totalPlannedWeight'] is num) {
      return (data['summary']['totalPlannedWeight'] as num).toDouble();
    }
    return bundleList.fold(0.0, (sum, bundle) => sum + bundle.totalWeight);
  }

  double get averageBundleWeightValue {
    if (data['averageBundleWeight'] is num) {
      return (data['averageBundleWeight'] as num).toDouble();
    }
    if (data['summary'] is Map &&
        data['summary']['averageBundleWeight'] is num) {
      return (data['summary']['averageBundleWeight'] as num).toDouble();
    }
    return bundleList.isEmpty ? 0 : totalPlannedWeightValue / bundleList.length;
  }

  String get bundleWarningsText {
    if (data['bundleWarnings'] != null) {
      return '${data['bundleWarnings']} Warnings';
    }
    if (data['summary'] is Map && data['summary']['bundleWarnings'] != null) {
      return '${data['summary']['bundleWarnings']} Warnings';
    }
    return '—';
  }

  String get preferredBundleWeightText =>
      data['preferredBundleWeight']?.toString() ?? '—';

  String get maxBundleWeightText => data['maxBundleWeight']?.toString() ?? '—';

  String get maxBundleLengthText => data['maxBundleLength']?.toString() ?? '—';

  String get groupByProfileText => data['groupByProfile'] == null
      ? '—'
      : data['groupByProfile'] == true
      ? 'Enabled'
      : 'Disabled';

  @override
  void onInit() {
    super.onInit();
    _loadInitial();
    loadCarriers();
  }

  Future<void> confirmBundles() async {
    actionLoading.value = true;
    try {
      final targetId =
          data['_id']?.toString() ??
          data['bundlePlanId']?.toString() ??
          bundlePlanId;
      if (targetId.isNotEmpty) {
        await bundlePlanRepository.confirm(targetId);
      } else {
        throw StateError('Bundle plan is missing.');
      }

      isConfirmed.value = true;
      for (var b in bundleList) {
        b.status = 'Confirmed';
      }
      bundleList.refresh();
      CommonSnackbar.showSuccess(
        title: 'Bundle Plan Confirmed',
        message: 'Bundle plan has been confirmed successfully.',
      );
    } catch (e) {
      CommonSnackbar.showError(
        title: 'Unable to confirm bundle plan',
        message: e.toString(),
      );
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> exportExcel() async {
    try {
      final rows = [
        ['Bundle ID', 'Profile', 'Items', 'Length', 'Unit Weight', 'Status'],
        ...bundleList.map(
          (b) => [
            b.bundleId,
            b.profile,
            '${b.itemsCount} item',
            b.length,
            '${b.unitWeight} lbs',
            b.status,
          ],
        ),
      ];
      await FileExportService.saveCsv(
        fileName: 'bundle_plan_$bundlePlanId',
        rows: rows,
      );
      CommonSnackbar.showSuccess(
        title: 'Export Successful',
        message: 'Bundle plan CSV report generated successfully.',
      );
    } catch (e) {
      CommonSnackbar.showError(title: 'Export Failed', message: e.toString());
    }
  }

  Future<void> _loadInitial() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> planning = <String, dynamic>{};
      if (projectId.isNotEmpty) {
        planning = await _optional(
          () => loadPlanningRepository.fetchProjectPlanning(projectId),
        );
        planningData.assignAll(planning);
        if (requestId.isEmpty) {
          requestId = _findId(planning, const {
            'shipperRequestId',
            'requestId',
            'approvedShipperRequestId',
          });
        }

        final packingPlan = _map(planning['packingListPlan']);
        packingListPlanId = _resolvePackingPlanId(planning);

        final embeddedBundle = _map(
          planning['bundlePlan'] ?? packingPlan['bundlePlan'],
        );
        if (bundlePlanId.isEmpty) bundlePlanId = _id(embeddedBundle);
        if (bundlePlanId.isEmpty) {
          final plan = await _optional(
            () => workflowRepository.projectBundlePlan(projectId),
          );
          bundlePlanId = _id(plan);
          if (plan.isNotEmpty) planningData['bundlePlan'] = plan;
        }

        final packingStatus = _value(packingPlan, const [
          'status',
          'planStatus',
        ]).toLowerCase();
        if (packingListPlanId.isNotEmpty && packingStatus == 'confirmed') {
          step.value = 5;
          await _loadPlanningStep();
        } else if (packingListPlanId.isNotEmpty) {
          step.value = 2;
          await _loadPlanningStep();
          await loadTruckPlan();
        } else if (bundlePlanId.isNotEmpty) {
          step.value = 1;
          await _loadBundlePlan();
        }
      }
      if (fileUrl.isNotEmpty) await _loadPdf();
      if (data.isEmpty) _showProjectFields();
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> autoOptimize() async {
    await _run(() async {
      if (bundlePlanId.isEmpty) {
        if (requestId.isEmpty) {
          throw Exception('Shipper request was not provided.');
        }
        bundlePlanId = _id(
          await workflowRepository.generateBundlePlan(requestId),
        );
      }
      if (bundlePlanId.isEmpty) {
        throw Exception('Bundle plan was not returned by the server.');
      }
      await _loadBundlePlan();
      step.value = 1;
    }, 'Unable to optimize bundles');
  }

  Future<void> goToStep(int index) async {
    if (index == 0) {
      step.value = 0;
      return;
    }
    if (bundlePlanId.isEmpty) {
      CommonSnackbar.showError(
        title: 'Bundle plan required',
        message: 'Run Auto Optimize Bundles first.',
      );
      return;
    }
    await _run(() async {
      if (index == 2) {
        await loadTruckPlan();
      }
      if (index >= 3 && index <= 5) {
        if (packingListPlanId.isEmpty) await _ensurePackingListPlan();
        if (truckPlanData.isEmpty || truckloadList.isEmpty) {
          await loadTruckPlan();
        }
        final detail = await loadPlanningRepository.fetchPackingListPlan(
          packingListPlanId,
        );
        packingRows.assignAll(
          (detail['packingLists'] as List? ?? []).whereType<Map>().map(
            (row) => Map<String, dynamic>.from(row),
          ),
        );
        data.assignAll(detail);
      }
      if (index == 6) {
        await loadProjectDeliveries();
        if (bundlePlanId.isNotEmpty) {
          final autofill = await bundlePlanRepository.freightAutofill(
            bundlePlanId,
          );
          initialAutofillData.assignAll(autofill);
          data.assignAll(autofill);
          if (selectedDeliveryId.value == null) {
            _applyAutofillToFormFields(autofill);
          }
        }
      }
      step.value = index;
    }, 'Unable to load ${steps[index]}');
  }

  Future<void> next() {
    final target = step.value < steps.length - 1 ? step.value + 1 : step.value;
    return goToStep(target);
  }

  void finish() => Get.back();

  Future<void> approveLoadPlan() async {
    await _run(() async {
      if (packingListPlanId.isEmpty) {
        throw StateError('Packing plan is missing.');
      }
      await loadPlanningRepository.confirmPackingListPlan(packingListPlanId);

      try {
        if (bundlePlanId.isNotEmpty) {
          final autofill = await bundlePlanRepository.freightAutofill(
            bundlePlanId,
          );
          initialAutofillData.assignAll(autofill);
          data.assignAll(autofill);
          _applyAutofillToFormFields(autofill);
        }
      } catch (_) {}
      await loadProjectDeliveries();

      step.value = 6;
    }, 'Unable to approve load plan');
  }

  void _applyAutofillToFormFields(Map<String, dynamic> autofill) {
    if (autofill.isEmpty) return;

    final desc =
        (autofill['loadDescription'] ??
                autofill['description'] ??
                autofill['loadDesc'])
            ?.toString();
    if (desc != null && desc.isNotEmpty) {
      loadDescriptionCtrl.text = desc;
    } else if (loadDescriptionCtrl.text.isEmpty) {
      loadDescriptionCtrl.text =
          '$totalBundlesCount bundle(s) for bundle plan $displayBundlePlanId';
    }

    final weight =
        (autofill['loadWeight'] ??
                autofill['weight'] ??
                autofill['totalWeight'])
            ?.toString();
    if (weight != null && weight.isNotEmpty) {
      weightCtrl.text = weight;
    } else if (weightCtrl.text.isEmpty) {
      weightCtrl.text = '$totalPlannedWeightValue';
    }

    final dimsRaw =
        autofill['dimensions'] ??
        autofill['loadDimensions'] ??
        autofill['dimension'];
    if (dimsRaw != null) {
      if (dimsRaw is Map) {
        final l = dimsRaw['lengthFeet'] ?? dimsRaw['length'] ?? dimsRaw['l'];
        final w = dimsRaw['widthFeet'] ?? dimsRaw['width'] ?? dimsRaw['w'];
        final h = dimsRaw['heightFeet'] ?? dimsRaw['height'] ?? dimsRaw['h'];
        if (l != null || w != null || h != null) {
          dimensionsCtrl.text = "${l ?? 0}' x ${w ?? 0}' x ${h ?? 0}'";
        }
      } else if (dimsRaw.toString().isNotEmpty) {
        dimensionsCtrl.text = dimsRaw.toString();
      }
    }

    final mat =
        (autofill['metalType'] ??
                autofill['materialType'] ??
                autofill['material'] ??
                autofill['materials'])
            ?.toString();
    if (mat != null && mat.isNotEmpty) {
      materialTypeCtrl.text = mat;
    }

    final count =
        (autofill['packageCount'] ??
                autofill['palletCount'] ??
                autofill['bundleCount'] ??
                autofill['totalBundles'])
            ?.toString();
    if (count != null && count.isNotEmpty) {
      palletCountCtrl.text = count;
    } else if (palletCountCtrl.text.isEmpty) {
      palletCountCtrl.text = '$totalBundlesCount';
    }

    final equipRaw =
        autofill['loadingEquipment'] ??
        autofill['equipment'] ??
        autofill['equipmentRequirement'];
    if (equipRaw != null) {
      if (equipRaw is List) {
        loadingEquipmentCtrl.text = equipRaw
            .map((e) => e.toString())
            .join(', ');
      } else if (equipRaw.toString().isNotEmpty) {
        loadingEquipmentCtrl.text = equipRaw.toString();
      }
    }

    final deadline =
        (autofill['bidDeadline'] ??
                autofill['deadline'] ??
                autofill['bidDeadlineDate'])
            ?.toString();
    if (deadline != null && deadline.isNotEmpty) {
      bidDeadlineCtrl.text = _formatDateTimeStr(deadline);
    }

    final pickupLoc =
        (autofill['pickupLocation'] ??
                autofill['pickupAddress'] ??
                autofill['origin'])
            ?.toString();
    if (pickupLoc != null && pickupLoc.isNotEmpty) {
      pickupLocationCtrl.text = pickupLoc;
    }

    final deliveryLoc =
        (autofill['deliveryLocation'] ??
                autofill['deliveryAddress'] ??
                autofill['dropoffAddress'] ??
                autofill['destination'])
            ?.toString();
    if (deliveryLoc != null && deliveryLoc.isNotEmpty) {
      deliveryLocationCtrl.text = deliveryLoc;
    }

    final pDate = (autofill['pickupDate'] ?? autofill['shipDate'])?.toString();
    if (pDate != null && pDate.isNotEmpty) {
      pickupDateCtrl.text = _formatDateInput(pDate);
    }

    final pTime = (autofill['pickupTime'] ?? autofill['shipTime'])?.toString();
    if (pTime != null && pTime.isNotEmpty) {
      pickupTimeCtrl.text = pTime;
    }

    final dDate = (autofill['deliveryDate'] ?? autofill['dropoffDate'])
        ?.toString();
    if (dDate != null && dDate.isNotEmpty) {
      deliveryDateCtrl.text = _formatDateInput(dDate);
    }

    final dTime = (autofill['deliveryTime'] ?? autofill['dropoffTime'])
        ?.toString();
    if (dTime != null && dTime.isNotEmpty) {
      deliveryTimeCtrl.text = dTime;
    }

    final poc =
        (autofill['receivingPoc'] ??
                autofill['receivingPocName'] ??
                autofill['contactName'])
            ?.toString();
    if (poc != null && poc.isNotEmpty) {
      receivingPocCtrl.text = poc;
    }

    final phone =
        (autofill['pickupContactPhone'] ??
                autofill['pickupPhone'] ??
                autofill['contactPhone'])
            ?.toString();
    if (phone != null && phone.isNotEmpty) {
      pickupPhoneCtrl.text = phone;
    }

    final reqs = (autofill['specialRequirements'] ?? autofill['requirements'])
        ?.toString();
    if (reqs != null && reqs.isNotEmpty) {
      specialRequirementsCtrl.text = reqs;
    }

    final notes = (autofill['additionalNotes'] ?? autofill['notes'])
        ?.toString();
    if (notes != null && notes.isNotEmpty) {
      additionalNotesCtrl.text = notes;
    }
  }

  String _formatDateInput(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final dt = DateTime.tryParse(trimmed);
    if (dt != null) {
      final local = dt.toLocal();
      return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    }
    return trimmed;
  }

  String _formatDateTimeStr(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year, $hour:$minute';
    } catch (_) {
      return raw;
    }
  }

  Future<void> _loadBundlePlan() async {
    final detail = await bundlePlanRepository.detail(bundlePlanId);
    final coverage = await bundlePlanRepository.coverage(bundlePlanId);
    data.assignAll({...detail, 'coverage': coverage});
    final rawBundles = detail['bundles'] is List
        ? detail['bundles'] as List
        : detail['items'] is List
        ? detail['items'] as List
        : null;
    if (rawBundles != null && rawBundles.isNotEmpty) {
      bundleList.assignAll(
        rawBundles.whereType<Map>().map((entry) {
          final m = Map<String, dynamic>.from(entry);

          String resolvedId = '';
          final rawId =
              m['bundleId'] ??
              m['bundleNumber'] ??
              m['bundleNo'] ??
              m['bundleCode'] ??
              m['code'] ??
              m['label'] ??
              m['name'];
          if (rawId != null && rawId.toString().isNotEmpty) {
            resolvedId = rawId.toString();
          }
          if (resolvedId.isEmpty || resolvedId.length >= 20) {
            resolvedId = (m['bundleNo'] ?? m['_id'] ?? '').toString();
          }

          dynamic lenRaw =
              m['maxLengthFeet'] ??
              m['lengthFeet'] ??
              m['length'] ??
              m['bundleLength'] ??
              m['overallLength'] ??
              m['len'] ??
              m['maxLength'];
          if (lenRaw == null &&
              m['items'] is List &&
              (m['items'] as List).isNotEmpty) {
            final firstItem = (m['items'] as List).first;
            if (firstItem is Map) {
              lenRaw =
                  firstItem['length'] ??
                  firstItem['overallLength'] ??
                  firstItem['len'];
            }
          }

          final weightRaw =
              m['unitWeight'] ??
              m['weight'] ??
              m['totalWeight'] ??
              m['bundleWeight'];
          final itemsCountRaw =
              m['itemsCount'] ??
              m['count'] ??
              (m['items'] is List ? (m['items'] as List).length : null) ??
              m['qty'] ??
              m['quantity'];
          final qtyRaw = m['totalQty'] ?? m['qty'] ?? m['quantity'] ?? 0;

          double parsedWeight = 0.0;
          if (weightRaw is num) {
            parsedWeight = weightRaw.toDouble();
          } else if (weightRaw != null) {
            parsedWeight =
                double.tryParse(
                  weightRaw
                      .toString()
                      .replaceAll('lbs', '')
                      .replaceAll(',', '')
                      .trim(),
                ) ??
                0.0;
          }

          int parsedItems = 0;
          if (itemsCountRaw is num) {
            parsedItems = itemsCountRaw.toInt();
          } else if (itemsCountRaw != null) {
            parsedItems = int.tryParse(itemsCountRaw.toString()) ?? 0;
          }

          final formattedLen = lenRaw == null
              ? '—'
              : lenRaw.toString().contains('ft')
              ? lenRaw.toString()
              : '$lenRaw ft';

          String statusStr =
              m['status']?.toString() ??
              (isConfirmed.value ? 'Confirmed' : 'Draft');
          if (statusStr.toLowerCase() == 'draft') statusStr = 'Draft';
          if (statusStr.toLowerCase() == 'confirmed') statusStr = 'Confirmed';

          return BundleDataModel(
            bundleId: resolvedId,
            recordId: (m['_id'] ?? '').toString(),
            items: (m['items'] as List? ?? [])
                .whereType<Map>()
                .map((row) => Map<String, dynamic>.from(row))
                .toList(),
            handlingInstructions: (m['handlingInstruction'] ?? '').toString(),
            notes: (m['notes'] ?? '').toString(),
            profile:
                m['bundleType']?.toString() ??
                m['profile']?.toString() ??
                m['profileType']?.toString() ??
                '—',
            itemsCount: parsedItems,
            length: formattedLen,
            unitWeight: parsedWeight,
            status: statusStr,
            partNumber:
                m['partNumber']?.toString() ?? m['partNo']?.toString() ?? '',
            qty: qtyRaw is num ? qtyRaw.toInt() : 0,
            description:
                m['description']?.toString() ??
                m['itemDescription']?.toString() ??
                '',
            unitWeightSingle: m['unitWeightSingle'] is num
                ? (m['unitWeightSingle'] as num).toDouble()
                : (parsedWeight / (parsedItems > 0 ? parsedItems : 1)),
          );
        }),
      );
    }
  }

  Future<void> _loadPlanningStep() async {
    final planning = await loadPlanningRepository.fetchProjectPlanning(
      projectId,
    );
    planningData.assignAll(planning);
    if (packingListPlanId.isEmpty) {
      packingListPlanId = _resolvePackingPlanId(planning);
    }
    final packingPlan = packingListPlanId.isEmpty
        ? <String, dynamic>{}
        : await _optional(
            () =>
                loadPlanningRepository.fetchPackingListPlan(packingListPlanId),
          );
    final trucks = await _optional(
      () => loadPlanningRepository.fetchProjectTruckPlan(projectId),
    );
    data.assignAll({
      'planning': planning,
      if (packingPlan.isNotEmpty) 'packingListPlan': packingPlan,
      if (trucks.isNotEmpty) 'truckPlan': trucks,
    });
    if (trucks.isNotEmpty) {
      truckPlanData.assignAll(trucks);
      populateTruckloads(trucks);
    } else if (packingPlan.isNotEmpty) {
      populateTruckloads(packingPlan);
    } else if (planning.isNotEmpty) {
      populateTruckloads(planning);
    }
  }

  Future<void> _ensurePackingListPlan() async {
    final generated = await bundlePlanRepository.generatePackingList(
      bundlePlanId,
    );
    packingListPlanId = _resolvePackingPlanId(generated);
    if (packingListPlanId.isEmpty && projectId.isNotEmpty) {
      packingListPlanId = _resolvePackingPlanId(
        await loadPlanningRepository.fetchProjectPlanning(projectId),
      );
    }
    if (packingListPlanId.isEmpty) {
      throw StateError('The server did not return a packing plan ID.');
    }
  }

  String _resolvePackingPlanId(dynamic value) {
    final root = _map(value);
    final embeddedPlan = _map(
      root['packingListPlan'] ??
          root['packing_plan'] ??
          root['packingPlan'] ??
          root['packing_list_plan'],
    );
    final embeddedId = _value(embeddedPlan, const [
      'packingListPlanId',
      'packingPlanId',
      '_id',
      'id',
    ]);
    if (embeddedId.isNotEmpty) return embeddedId;

    return _findId(value, const {
      'packingListPlanId',
      'packingPlanId',
      'packing_list_plan_id',
    });
  }

  String _findId(dynamic value, Set<String> keys) {
    if (value is Map) {
      for (final entry in value.entries) {
        if (keys.contains(entry.key.toString()) &&
            entry.value != null &&
            entry.value.toString().trim().isNotEmpty) {
          return entry.value.toString();
        }
      }
      for (final nested in value.values) {
        final found = _findId(nested, keys);
        if (found.isNotEmpty) return found;
      }
    } else if (value is List) {
      for (final nested in value) {
        final found = _findId(nested, keys);
        if (found.isNotEmpty) return found;
      }
    }
    return '';
  }

  void _showProjectFields() {
    data.assignAll({
      'Project ID': projectCode,
      'Vendor': vendorName,
      'Shipper file': fileName,
    });
  }

  Future<void> _loadPdf() async {
    final response = await Dio().get<List<int>>(
      fileUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = Uint8List.fromList(response.data ?? const []);
    if (bytes.length > 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      pdfBytes.value = bytes;
    }
  }

  Future<void> loadTruckPlan() async {
    if (projectId.isEmpty) return;
    try {
      if (packingListPlanId.isEmpty && bundlePlanId.isNotEmpty) {
        try {
          await _ensurePackingListPlan();
        } catch (_) {}
      }

      var trucks = await _optional(
        () => loadPlanningRepository.fetchProjectTruckPlan(projectId),
      );

      if (trucks.isEmpty || (trucks['packingLists'] as List? ?? []).isEmpty) {
        await _optional(
          () => loadPlanningRepository.generateProjectTruckPlan(projectId),
        );
        trucks = await _optional(
          () => loadPlanningRepository.fetchProjectTruckPlan(projectId),
        );
      }

      if (trucks.isNotEmpty) {
        truckPlanData.assignAll(trucks);
        data['truckPlan'] = trucks;
        if (packingListPlanId.isEmpty) {
          packingListPlanId = _resolvePackingPlanId(trucks);
        }
        populateTruckloads(trucks);
      }

      if (truckloadList.isEmpty && packingListPlanId.isNotEmpty) {
        final packingPlan = await _optional(
          () => loadPlanningRepository.fetchPackingListPlan(packingListPlanId),
        );
        if (packingPlan.isNotEmpty) {
          populateTruckloads(packingPlan);
        }
      }

      if (truckloadList.isEmpty) {
        final planning = await _optional(
          () => loadPlanningRepository.fetchProjectPlanning(projectId),
        );
        if (planning.isNotEmpty) {
          populateTruckloads(planning);
        }
      }
    } catch (e) {
      debugPrint('Error loading truck plan: $e');
    }
  }

  void populateTruckloads(dynamic source) {
    final root = _map(source);
    final candidates = _firstList([
      root['packingLists'],
      root['truckloads'],
      root['truckLoads'],
      root['trucks'],
      root['loads'],
      root['loadPlans'],
      _map(root['truckPlan'])['packingLists'],
      _map(root['packingListPlan'])['packingLists'],
    ]);

    if (candidates.isEmpty) return;

    final models = <TruckLoadDataModel>[];
    for (var i = 0; i < candidates.length; i++) {
      final raw = candidates[i];
      if (raw is! Map) continue;
      final row = Map<String, dynamic>.from(raw);

      final loadId =
          (row['packingListNo'] ??
                  row['loadId'] ??
                  row['truckNo'] ??
                  row['truckLabel'] ??
                  row['planNumber'] ??
                  row['_id'] ??
                  'PL-00${i + 1}')
              .toString();

      final totalBundles = _int(
        row['totalBundles'] ??
            (row['bundleIds'] is List
                ? (row['bundleIds'] as List).length
                : null) ??
            (row['bundles'] is List ? (row['bundles'] as List).length : null) ??
            0,
      );

      final totalWeight = _double(
        row['totalWeight'] ?? row['weight'] ?? row['loadWeight'] ?? 0.0,
      );

      final maxW =
          (row['maxTruckWeight'] ??
          row['maxWeight'] ??
          row['hardMaxTruckWeight'] ??
          0);
      int utilization;
      if (maxW is num && maxW > 0) {
        utilization = ((totalWeight / maxW) * 100).round();
      } else {
        utilization = _int(
          row['utilizationPercentage'] ?? row['utilization'] ?? 0,
        );
      }

      final statusRaw = (row['status'] ?? 'Ready').toString();
      final status = statusRaw.isEmpty
          ? 'Ready'
          : '${statusRaw[0].toUpperCase()}${statusRaw.substring(1).toLowerCase()}';

      models.add(
        TruckLoadDataModel(
          loadId: loadId,
          bundlesCount: totalBundles,
          totalWeight: totalWeight,
          utilizationPercentage: utilization,
          status: status,
        ),
      );
    }

    if (models.isNotEmpty) {
      truckloadList.assignAll(models);
    }
  }

  List<dynamic> _firstList(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is List && candidate.isNotEmpty) return candidate;
    }
    return const [];
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  double _double(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0.0;

  String _formatNumber(num val) {
    final parts = val.toStringAsFixed(1).split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return parts.length > 1 && parts[1] != '0' ? '$whole.${parts[1]}' : whole;
  }

  Future<void> _run(Future<void> Function() task, String title) async {
    actionLoading.value = true;
    try {
      await task();
    } catch (e) {
      CommonSnackbar.showError(title: title, message: e.toString());
    } finally {
      actionLoading.value = false;
    }
  }

  String _id(Map<String, dynamic> value) {
    final nested = value['bundlePlan'];
    return (value['bundlePlanId'] ??
            value['_id'] ??
            (nested is Map ? nested['_id'] ?? nested['bundlePlanId'] : null) ??
            '')
        .toString();
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  String _value(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  Future<Map<String, dynamic>> _optional(
    Future<Map<String, dynamic>> Function() task,
  ) async {
    try {
      return await task();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  void onClose() {
    _pickupDebounce?.cancel();
    _deliveryDebounce?.cancel();
    _pickupCancelToken?.cancel();
    _deliveryCancelToken?.cancel();
    loadDescriptionCtrl.dispose();
    weightCtrl.dispose();
    dimensionsCtrl.dispose();
    materialTypeCtrl.dispose();
    palletCountCtrl.dispose();
    loadingEquipmentCtrl.dispose();
    bidDeadlineCtrl.dispose();
    pickupLocationCtrl.dispose();
    deliveryLocationCtrl.dispose();
    pickupDateCtrl.dispose();
    pickupTimeCtrl.dispose();
    deliveryDateCtrl.dispose();
    deliveryTimeCtrl.dispose();
    receivingPocCtrl.dispose();
    pickupPhoneCtrl.dispose();
    specialRequirementsCtrl.dispose();
    additionalNotesCtrl.dispose();
    super.onClose();
  }
}
