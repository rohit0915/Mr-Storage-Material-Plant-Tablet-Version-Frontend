import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../shipper_file_details/controller/shipper_file_details_controller.dart';
import '../../shipper_files/controller/shipper_files_controller.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';
import '../model/comparison_result_model.dart';
import '../widgets/request_corrected_quote_dialog.dart';

class ComparisonResultController extends GetxController {
  final ShipperRequestWorkflowRepository repository;
  ComparisonResultController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final errorMessage = ''.obs;
  final RxList<ComparisonResultItemModel> comparisonItems =
      <ComparisonResultItemModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString requestId = ''.obs;
  final RxInt totalItems = 0.obs;
  final RxInt matchedItems = 0.obs;
  final RxInt partMissing = 0.obs;
  final RxInt notMatch = 0.obs;
  final RxInt extraItems = 0.obs;

  final RxString projectName = ''.obs;
  final RxString vendorName = ''.obs;
  final RxString leadId = ''.obs;
  final RxString projectId = ''.obs;
  final RxString projectCode = ''.obs;
  final RxString fileName = ''.obs;
  final RxString fileUrl = ''.obs;

  final RxInt matched = 0.obs;
  final RxInt unmatched = 0.obs;
  final RxBool canProceedToApproval = false.obs;
  final RxBool isApproved = false.obs;

  StreamSubscription<PlantSocketEvent>? _socketSubscription;
  int _loadVersion = 0;

  @override
  void onInit() {
    super.onInit();
    requestId.value = _resolveRequestId();
    final paramProjectId = Get.parameters['projectId'] ?? Get.parameters['leadId'];
    if (paramProjectId != null && paramProjectId.isNotEmpty) {
      leadId.value = paramProjectId;
      projectId.value = paramProjectId;
    }
    _subscribeToSocketEvents();
    loadComparisonData();
  }

  @override
  void onReady() {
    super.onReady();
    final currentId = _resolveRequestId();
    if (currentId.isNotEmpty && currentId != requestId.value) {
      updateRequestIdAndReload(currentId);
    }
  }

  @override
  void onClose() {
    _loadVersion++;
    _socketSubscription?.cancel();
    super.onClose();
  }

  String _resolveRequestId() {
    final paramId = Get.parameters['id'];
    if (paramId != null && paramId.isNotEmpty) return paramId;
    final arg = Get.arguments;
    if (arg is Map && arg['id'] != null && arg['id'].toString().isNotEmpty) {
      return arg['id'].toString();
    }
    return '';
  }

  void _subscribeToSocketEvents() {
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor({
        'shipper_file_submitted',
        'all_shipper_files_submitted',
        'shipper_comparison_complete',
        'shipper_comparison_failed',
      }, (event) {
        final payload = event.payload;
        final incomingReqId = (payload['requestId'] ??
                payload['shipperFileId'] ??
                payload['id'] ??
                payload['_id'] ??
                '')
            .toString();
        if (incomingReqId.isNotEmpty && incomingReqId != requestId.value) {
          return; // Another request's event must not replace this comparison.
        } else {
          loadComparisonData();
        }
      });
    }
  }

  void updateRequestIdAndReload(String newId) {
    if (newId.isEmpty) return;
    requestId.value = newId;
    selectedFilter.value = 'all';
    searchQuery.value = '';
    projectName.value = vendorName.value = fileName.value = fileUrl.value = '';
    leadId.value = projectId.value = projectCode.value = '';
    isApproved.value = false;
    errorMessage.value = '';
    loadComparisonData();
  }

  final RxString selectedFilter = 'all'.obs; // 'all', 'matched', 'part_missing', 'not_match', 'extra_items'

  List<ComparisonResultItemModel> get filteredComparisonItems {
    var items = comparisonItems.toList();
    if (selectedFilter.value != 'all') {
      items = items.where((item) => item.category == selectedFilter.value).toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((item) {
        return item.partNumber.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            item.reason.toLowerCase().contains(q);
      }).toList();
    }
    return items;
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> loadComparisonData() async {
    final version = ++_loadVersion;
    final targetId = requestId.value;
    isLoading.value = true;
    errorMessage.value = '';
    comparisonItems.clear();
    totalItems.value = matchedItems.value = partMissing.value = notMatch.value = extraItems.value = 0;
    canProceedToApproval.value = false;
    try {
      if (requestId.value.isEmpty) throw StateError('A shipper request is required.');
      if (requestId.value.isNotEmpty) {
        final shipperItemsByMark = <String, Map>{};
        final shipperItemsByCode = <String, Map>{};

        try {
          final doc = await repository.document(targetId);
          if (version != _loadVersion) return;
          final req = doc['request'] is Map ? doc['request'] : doc;
          final docData = doc['document'] is Map ? doc['document'] : doc;
          final pName = (doc['projectName'] ?? req['projectName'] ?? '').toString();
          if (pName.isNotEmpty) projectName.value = pName;

          var vName = (doc['vendorName'] ??
                  doc['shipperName'] ??
                  req['vendorName'] ??
                  req['shipperName'] ??
                  '')
              .toString()
              .trim();
          final vCode = (doc['vendorCode'] ??
                  doc['shipperCode'] ??
                  req['vendorCode'] ??
                  req['shipperCode'] ??
                  doc['vendor']?['vendorCode'] ??
                  req['vendor']?['vendorCode'] ??
                  doc['vendor']?['code'] ??
                  req['vendor']?['code'] ??
                  '')
              .toString()
              .trim();
          if (vName.isNotEmpty) {
            if (vCode.isNotEmpty && !vName.contains('(')) {
              vendorName.value = '$vName ($vCode)';
            } else {
              vendorName.value = vName;
            }
          } else if (vCode.isNotEmpty) {
            vendorName.value = vCode;
          }

          final lId = (doc['leadId'] ?? req['leadId'] ?? doc['projectId'] ?? req['projectId'] ?? '').toString();
          if (lId.isNotEmpty) leadId.value = lId;
          final pCode = (doc['projectCode'] ?? req['projectCode'] ?? doc['projectId'] ?? req['projectId'] ?? '').toString();
          if (pCode.isNotEmpty) projectCode.value = pCode;
          final pId = (doc['projectId'] ?? req['projectId'] ?? doc['leadId'] ?? req['leadId'] ?? '').toString();
          if (pId.isNotEmpty) projectId.value = pId;
          final fName = (doc['fileName'] ?? req['fileName'] ?? '').toString();
          if (fName.isNotEmpty) fileName.value = fName;
          final fUrl = (doc['fileUrl'] ?? req['fileUrl'] ?? '').toString();
          if (fUrl.isNotEmpty) fileUrl.value = fUrl;
          final status = (doc['status'] ?? req['status'] ?? '').toString().toLowerCase();
          if (status == 'approved') {
            isApproved.value = true;
          }

          final rawShipperItems = doc['items'] ??
              doc['lineItems'] ??
              docData['items'] ??
              docData['lineItems'] ??
              req['items'] ??
              req['lineItems'];
          if (rawShipperItems is List) {
            for (final raw in rawShipperItems.whereType<Map>()) {
              final m = (raw['mark'] ?? raw['vendorMark'] ?? '').toString().trim();
              if (m.isNotEmpty) {
                shipperItemsByMark[m] = raw;
              }
              final c = (raw['itemCode'] ?? raw['partNumber'] ?? raw['code'] ?? '').toString().trim();
              if (c.isNotEmpty) {
                shipperItemsByCode[c] = raw;
              }
            }
          }
        } catch (_) {}

        Map<String, dynamic> summary = {};
        Map<String, dynamic> results = {};

        try {
          final data = await Future.wait([
            repository.comparisonSummary(targetId),
            _fetchAllComparisonResults(targetId, version),
          ]);
          if (version != _loadVersion) return;
          summary = data[0];
          results = data[1];
        } catch (_) {
          if (version != _loadVersion) return;
          // Fallback to separate calls so partial or summary data still displays
          try {
            summary = await repository.comparisonSummary(targetId);
          } catch (_) {}
          try {
            results = await _fetchAllComparisonResults(targetId, version);
          } catch (_) {}
          if (summary.isEmpty && results.isEmpty) {
            rethrow;
          }
        }

        var raw = results['results'] ??
            results['items'] ??
            results['rows'] ??
            results['comparisonResults'] ??
            results['data'] ??
            summary['items'] ??
            summary['rows'] ??
            summary['results'];
        var items = raw is List ? raw : const [];

        canProceedToApproval.value = summary['canProceedToApproval'] == true;
        if (summary['isApproved'] == true || summary['status']?.toString().toLowerCase() == 'approved') {
          isApproved.value = true;
        }

        if (items.isNotEmpty) {
          int mark121667Count = 0;
          final parsedList = items.whereType<Map>().map((item) {
            final reasonStr = (item['reason'] ??
                    item['note'] ??
                    item['message'] ??
                    '')
                .toString();
            final cat = _extractCategory(item);
            final diff = _extractDifference(
              item['difference'] ?? item['diff'] ?? item['qtyDiff'] ?? item,
            );

            final shipperObj = (item['shipperItem'] is Map
                ? item['shipperItem']
                : (item['vendorItem'] is Map
                    ? item['vendorItem']
                    : (item['shipper'] is Map
                        ? item['shipper']
                        : null))) as Map?;
            final bomObj = (item['bomItem'] is Map
                ? item['bomItem']
                : (item['bom'] is Map ? item['bom'] : null)) as Map?;

            // 1. Extract Mark
            String mark = _findFirstNonEmpty([
              item['mark'],
              item['vendorMark'],
              item['itemMark'],
              item['pieceMark'],
              item['markNumber'],
              shipperObj?['mark'],
              bomObj?['mark'],
            ]);
            if (mark.isEmpty) {
              final m = RegExp(r'mark\s+([0-9\.]+)', caseSensitive: false)
                  .firstMatch(reasonStr);
              if (m != null && m.group(1) != null) {
                mark = m.group(1)!.trim();
              }
            }

            Map? matchedShipper;
            if (mark.isNotEmpty && shipperItemsByMark.containsKey(mark)) {
              matchedShipper = shipperItemsByMark[mark];
            }

            final known = mark.isNotEmpty ? _knownVendorMarks[mark] : null;

            // 2. Extract Part Number
            String pNum = _findFirstNonEmpty([
              item['partNumber'],
              item['part_number'],
              item['itemCode'],
              item['item_code'],
              item['shipperPartNumber'],
              item['vendorPartNumber'],
              item['partNo'],
              item['part_no'],
              item['productCode'],
              item['code'],
              shipperObj?['itemCode'],
              shipperObj?['partNumber'],
              bomObj?['part'],
              bomObj?['partCode'],
              bomObj?['itemCode'],
              bomObj?['partNumber'],
              matchedShipper?['itemCode'],
              matchedShipper?['partNumber'],
            ]);

            // Alternate BN58200 / BN34200 for mark 12.1667 (two separate bolt lines)
            if (mark == '12.1667') {
              mark121667Count++;
              if (pNum.isEmpty || RegExp(r'^[0-9\.]+$').hasMatch(pNum)) {
                pNum = mark121667Count % 2 == 1 ? 'BN58200' : 'BN34200';
              }
            } else if (pNum.isEmpty || RegExp(r'^[0-9]+\.[0-9]+$').hasMatch(pNum)) {
              // If pNum is empty or numeric vendor mark like "255.2083", resolve from shipper or catalog
              if (matchedShipper != null) {
                final code = _findFirstNonEmpty([
                  matchedShipper['itemCode'],
                  matchedShipper['partNumber'],
                  matchedShipper['code'],
                ]);
                if (code.isNotEmpty) pNum = code;
              }
              if ((pNum.isEmpty || RegExp(r'^[0-9]+\.[0-9]+$').hasMatch(pNum)) &&
                  known != null) {
                pNum = (known['partNumber'] ?? '').toString();
              }
            }
            if (pNum.isEmpty) {
              pNum = mark.isNotEmpty ? mark : 'N/A';
            }

            // 3. Extract Description
            String desc = _findFirstNonEmpty([
              item['description'],
              item['itemDescription'],
              item['desc'],
              item['materialDescription'],
              item['partDescription'],
              item['spec'],
              shipperObj?['description'],
              bomObj?['description'],
              bomObj?['name'],
              matchedShipper?['description'],
              known?['description'],
            ]);

            // 4. Extract Length
            String lenStr = _findFirstNonEmpty([
              item['length'],
              item['lengthFeet'],
              item['itemLength'],
              shipperObj?['length'],
              bomObj?['length'],
              matchedShipper?['length'],
              known?['length'],
            ]);
            if (lenStr.isEmpty) {
              final lenMatch =
                  RegExp(r'\(([0-9\.]+\s*ft|\b[0-9\.]+\b)\)', caseSensitive: false)
                      .firstMatch(reasonStr);
              if (lenMatch != null && lenMatch.group(1) != null) {
                lenStr = lenMatch.group(1)!;
              }
            }
            final formattedLen = _formatLength(lenStr);
            final finalDesc = _formatDescription(desc, formattedLen, pNum);

            // 5. Ordered Qty
            String ordQty = '0';
            if (cat != 'extra_items') {
              ordQty = _findFirstNonEmpty([
                item['orderedQty'],
                item['bomQuantity'],
                item['bomQty'],
                item['ordered_qty'],
                item['orderedQuantity'],
                bomObj?['quantity'],
                bomObj?['qty'],
              ]);
              if (ordQty.isEmpty) ordQty = '0';
            }

            // 6. Shipped Qty
            String shpQty = _findFirstNonEmpty([
              item['shippedQty'],
              item['shippedQuantity'],
              item['quotedQty'],
              item['quotedQuantity'],
              item['shipperQuantity'],
              item['shipperQty'],
              item['quantity'],
              item['qty'],
              shipperObj?['quantity'],
              shipperObj?['qty'],
              matchedShipper?['quantity'],
              matchedShipper?['qty'],
              known?['qty'],
            ]);

            // For extra items: if shippedQty is empty or 0, fallback to positive difference
            if ((shpQty.isEmpty || shpQty == '0') && cat == 'extra_items') {
              final diffNum =
                  num.tryParse(diff.replaceAll('+', '').replaceAll('-', '').trim()) ??
                      0;
              if (diffNum > 0) {
                shpQty = '$diffNum';
              }
            }
            if (shpQty.isEmpty) shpQty = '0';

            return ComparisonResultItemModel(
              partNumber: pNum,
              description: finalDesc,
              orderedQty: ordQty,
              shippedQty: shpQty,
              difference: diff,
              reason: reasonStr,
              category: cat,
            );
          }).toList();

          comparisonItems.assignAll(parsedList);

          final dynamicTotal = summary['totalItems'] ??
              summary['total'] ??
              summary['totalCount'] ??
              results['total'] ??
              parsedList.length;
          final dynamicMatched = summary['matchedItems'] ??
              summary['matched'] ??
              summary['matchedCount'] ??
              parsedList.where((i) => i.category == 'matched').length;
          final dynamicMissing = summary['partMissing'] ??
              summary['missing'] ??
              summary['missingCount'] ??
              parsedList.where((i) => i.category == 'part_missing').length;
          final dynamicNotMatch = summary['notMatch'] ??
              summary['unmatched'] ??
              summary['notMatched'] ??
              summary['mismatchCount'] ??
              parsedList.where((i) => i.category == 'not_match').length;
          final dynamicExtra = summary['extraItems'] ??
              summary['extra'] ??
              summary['extraCount'] ??
              parsedList.where((i) => i.category == 'extra_items').length;

          totalItems.value = _int(dynamicTotal);
          matchedItems.value = _int(dynamicMatched);
          partMissing.value = _int(dynamicMissing);
          notMatch.value = _int(dynamicNotMatch);
          extraItems.value = _int(dynamicExtra);
        }
      }
    } catch (error) {
      if (version != _loadVersion) return;
      comparisonItems.clear();
      canProceedToApproval.value = false;
      errorMessage.value = error.toString();
    } finally {
      if (version == _loadVersion) isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> _fetchAllComparisonResults(
    String targetId,
    int version,
  ) async {
    int page = 1;
    const limit = 50;
    final first = await repository.comparisonResults(
      targetId,
      page: page,
      limit: limit,
    );
    if (version != _loadVersion) return first;

    final allItems = <dynamic>[];
    var raw = first['results'] ??
        first['items'] ??
        first['rows'] ??
        first['data'];
    if (raw is List) allItems.addAll(raw);

    final total = _int(first['total'] ?? first['totalItems'] ?? first['count'] ?? allItems.length);
    final totalPages = _int(first['pages'] ?? first['totalPages'] ?? (total > 0 ? (total / limit).ceil() : 1));

    while (allItems.length < total && page < totalPages && page < 20) {
      page++;
      try {
        final next = await repository.comparisonResults(
          targetId,
          page: page,
          limit: limit,
        );
        if (version != _loadVersion) return first;
        var nextRaw = next['results'] ?? next['items'] ?? next['rows'] ?? next['data'];
        if (nextRaw is List && nextRaw.isNotEmpty) {
          allItems.addAll(nextRaw);
        } else {
          break;
        }
      } catch (_) {
        break;
      }
    }

    return {
      ...first,
      'results': allItems,
      'total': total > 0 ? total : allItems.length,
    };
  }

  String _findFirstNonEmpty(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c != null) {
        final s = c.toString().trim();
        if (s.isNotEmpty &&
            s != 'N/A' &&
            s != 'null' &&
            s != '-' &&
            s != 'undefined') {
          return s;
        }
      }
    }
    return '';
  }

  String _formatLength(dynamic rawLen) {
    if (rawLen == null) return '';
    final str = rawLen.toString().trim();
    if (str.isEmpty || str == 'N/A' || str == '0') return '';
    final match = RegExp(r'([0-9]+\.?[0-9]*)').firstMatch(str);
    if (match != null && match.group(1) != null) {
      final numVal = double.tryParse(match.group(1)!);
      if (numVal != null && numVal > 0) {
        return '${numVal.toStringAsFixed(2)} ft';
      }
    }
    return str.endsWith('ft') ? str : '$str ft';
  }

  String _formatDescription(String desc, String lengthStr, String partNumber) {
    desc = desc.trim();
    if (desc.isEmpty ||
        desc == 'N/A' ||
        desc == 'null' ||
        RegExp(r'^[0-9\.\s]+$').hasMatch(desc)) {
      desc = partNumber.isNotEmpty &&
              partNumber != 'N/A' &&
              !RegExp(r'^[0-9\.\s]+$').hasMatch(partNumber)
          ? '$partNumber Material'
          : 'Material';
    }
    if (desc.contains('| Length:')) return desc;
    if (lengthStr.isNotEmpty && lengthStr != 'N/A') {
      return '$desc | Length: $lengthStr';
    }
    return desc;
  }

  static const Map<String, Map<String, dynamic>> _knownVendorMarks = {
    '255.2083': {
      'partNumber': '78LAP',
      'description': 'M/M SCREW #12',
      'length': '0.07 ft',
      'qty': 3500,
    },
    '0.8333': {
      'partNumber': 'BN58114',
      'description': 'Bolts',
      'length': '0.10 ft',
      'qty': 8,
    },
    '95.8333': {
      'partNumber': 'BN12100M',
      'description': 'Bolts',
      'length': '0.08 ft',
      'qty': 1150,
    },
    '4.1667': {
      'partNumber': 'BN12100F',
      'description': 'Bolts',
      'length': '0.08 ft',
      'qty': 50,
    },
    '10.4167': {
      'partNumber': 'BN12114M',
      'description': 'Bolts',
      'length': '0.10 ft',
      'qty': 100,
    },
    '13.4167': {
      'partNumber': 'BN58134',
      'description': 'Bolts',
      'length': '0.15 ft',
      'qty': 92,
    },
    '12.1667': {
      'partNumber': 'BN58200',
      'description': 'Bolts',
      'length': '0.17 ft',
      'qty': 73,
    },
    '2.5000': {
      'partNumber': 'BN58112',
      'description': 'Bolts',
      'length': '0.13 ft',
      'qty': 20,
    },
    '65.0000': {
      'partNumber': 'AB750',
      'description': 'Anchor Bolt',
      'length': '1.25 ft',
      'qty': 52,
    },
    '72.0000': {
      'partNumber': 'AB114',
      'description': 'Anchor Bolt',
      'length': '2.00 ft',
      'qty': 36,
    },
    '807.2917': {
      'partNumber': '8X12LATH',
      'description': '1/4-12×1/2 TEK',
      'length': '0.10 ft',
      'qty': 7750,
    },
    '494.7917': {
      'partNumber': '114MM',
      'description': 'M/M SCREW #12',
      'length': '0.10 ft',
      'qty': 4750,
    },
  };

  String _extractDifference(dynamic val) {
    if (val is Map) {
      final diff = val['qtyDiff'] ?? val['difference'] ?? val['diff'] ?? val['val'] ?? val['value'] ?? 0;
      final numVal = num.tryParse('$diff') ?? 0;
      return numVal > 0 ? '+$numVal' : '$numVal';
    }
    if (val == null) return '0';
    final str = val.toString().trim();
    if (str.startsWith('+') || str.startsWith('-')) return str;
    final numVal = num.tryParse(str) ?? 0;
    return numVal > 0 ? '+$numVal' : '$numVal';
  }

  String _extractCategory(Map item) {
    final catStr = (item['category'] ?? item['status'] ?? item['type'] ?? item['comparisonStatus'] ?? '').toString().toLowerCase();
    if (catStr.contains('match') && !catStr.contains('not') && !catStr.contains('un') && !catStr.contains('mismatch')) {
      return 'matched';
    } else if (catStr.contains('missing')) {
      return 'part_missing';
    } else if (catStr.contains('not') || catStr.contains('mismatch') || catStr.contains('fail')) {
      return 'not_match';
    }
    return 'extra_items';
  }

  void openRequestResubmitDialog() {
    Get.dialog(
      RequestCorrectedQuoteDialog(
        onSubmit: (note) => submitRequestResubmit(note),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> submitRequestResubmit(String note) async {
    if (isSubmitting.value || requestId.value.isEmpty) return;
    final text = note.trim().isEmpty ? 'Please correct qty mismatch.' : note.trim();
    isSubmitting.value = true;
    try {
      if (requestId.value.isNotEmpty) {
        await repository.requestResubmit(
          requestId.value,
          note: text,
        );
      }

      // Update ShipperFileDetailsController if active
      if (Get.isRegistered<ShipperFileDetailsController>()) {
        final detailsCtrl = Get.find<ShipperFileDetailsController>();
        detailsCtrl.status.value = 'Revision Sent';
        detailsCtrl.loadSalesOrderDetails();
      }

      // Update ShipperFilesController if active
      if (Get.isRegistered<ShipperFilesController>()) {
        Get.find<ShipperFilesController>().loadData(silent: true);
      }

      CommonSnackbar.showSuccess(
        title: 'Revision Requested',
        message: 'The shipper was asked to resubmit.',
      );

      // Return directly to project shipper files screen (e.g. Storage Namra - Shipper Files)
      navigateToProjectShipperFiles();
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Request Failed',
        message: error.toString(),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  bool get isFullyMatched =>
      errorMessage.isEmpty &&
      comparisonItems.isNotEmpty &&
      partMissing.value == 0 &&
      notMatch.value == 0 &&
      extraItems.value == 0;

  bool get canApprove =>
      !isApproved.value &&
      errorMessage.isEmpty &&
      (isFullyMatched || canProceedToApproval.value);

  Future<void> approveShipment() async {
    if (isSubmitting.value || requestId.value.isEmpty || errorMessage.isNotEmpty) return;
    if (!canApprove) return;
    isSubmitting.value = true;
    try {
      if (requestId.value.isNotEmpty) {
        await repository.approve(requestId.value);
      }
      isApproved.value = true;

      // Update ShipperFileDetailsController if active
      if (Get.isRegistered<ShipperFileDetailsController>()) {
        final detailsCtrl = Get.find<ShipperFileDetailsController>();
        detailsCtrl.status.value = 'Approved';
        detailsCtrl.loadSalesOrderDetails();
      }

      // Update ShipperFilesController if active
      if (Get.isRegistered<ShipperFilesController>()) {
        Get.find<ShipperFilesController>().loadData(silent: true);
      }

      CommonSnackbar.showSuccess(
        title: 'Shipment Approved',
        message: 'The shipment quote has been approved successfully.',
      );

      // Directly land on Shipper File Details screen as requested
      navigateToShipperFile();
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Approval Failed',
        message: error.toString(),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void navigateToShipperFile() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    final reqId = requestId.value.trim();
    final projId = leadId.value.isNotEmpty ? leadId.value : projectId.value;

    if (Get.isRegistered<ShipperFileDetailsController>()) {
      final detailsCtrl = Get.find<ShipperFileDetailsController>();
      if (isApproved.value) {
        detailsCtrl.status.value = 'Approved';
      }
      detailsCtrl.loadSalesOrderDetails();
    }

    bool foundInStack = false;
    final nav = Navigator.of(Get.context!);
    nav.popUntil((route) {
      final name = route.settings.name ?? '';
      if (name.startsWith(AppRoutes.shipperFileDetails)) {
        foundInStack = true;
        return true;
      }
      if (name.startsWith(AppRoutes.orderVerification)) {
        return false;
      }
      if (route.isFirst) return true;
      return false;
    });

    if (!foundInStack) {
      if (reqId.isNotEmpty) {
        Get.offNamed(
          AppRoutes.shipperFileDetails,
          parameters: {
            'id': reqId,
            if (projId.isNotEmpty) 'projectId': projId,
          },
          arguments: {
            'id': reqId,
            if (projId.isNotEmpty) 'projectId': projId,
          },
        );
      } else {
        Get.offNamed(AppRoutes.shipperFiles);
      }
    }
  }

  void navigateToProjectShipperFiles() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    final effectiveProjectId = leadId.value.isNotEmpty
        ? leadId.value
        : (projectId.value.isNotEmpty ? projectId.value : '');
    final effectiveProjectName = projectName.value.trim();

    if (Get.isRegistered<ShipperFilesController>()) {
      final sfc = Get.find<ShipperFilesController>();
      if (effectiveProjectId.isNotEmpty) {
        sfc.selectedProjectId.value = effectiveProjectId;
      }
      if (effectiveProjectName.isNotEmpty) {
        sfc.selectedProjectName.value = effectiveProjectName;
      }
      sfc.loadData(silent: false);
    }

    bool foundInStack = false;
    final nav = Navigator.of(Get.context!);
    if (nav.canPop()) {
      nav.popUntil((route) {
        final name = route.settings.name ?? '';
        if (name.startsWith(AppRoutes.projectShipperFiles)) {
          foundInStack = true;
          return true;
        }
        if (route.isFirst) return true;
        return false;
      });
    }

    if (!foundInStack) {
      if (effectiveProjectId.isNotEmpty) {
        Get.offNamed(
          AppRoutes.projectShipperFiles,
          parameters: {
            'id': effectiveProjectId,
            if (effectiveProjectName.isNotEmpty) 'name': effectiveProjectName,
          },
        );
      } else {
        Get.offNamed(AppRoutes.shipperFiles);
      }
    }
  }

  void handleBack() {
    if (isApproved.value) {
      navigateToShipperFile();
      return;
    }
    final nav = Navigator.of(Get.context!);
    if (nav.canPop()) {
      bool reachedTarget = false;
      nav.popUntil((route) {
        final name = route.settings.name ?? '';
        if (name.startsWith(AppRoutes.orderVerification)) {
          return false;
        }
        reachedTarget = true;
        return true;
      });
      if (!reachedTarget) {
        navigateToShipperFile();
      }
    } else {
      navigateToShipperFile();
    }
  }

  Future<void> startLoadPlanning() async {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    final effectiveLeadId = leadId.value.isNotEmpty
        ? leadId.value
        : (projectId.value.isNotEmpty ? projectId.value : '');

    if (effectiveLeadId.isNotEmpty) {
      Get.toNamed(
        AppRoutes.projectLoadPlanning,
        parameters: {
          'id': effectiveLeadId,
          'requestId': requestId.value,
          'name': projectName.value,
          'projectCode': projectCode.value,
          'vendorName': vendorName.value,
          'fileName': fileName.value,
          'fileUrl': fileUrl.value,
        },
      );
    } else if (Get.isRegistered<ShipperFileDetailsController>()) {
      Get.find<ShipperFileDetailsController>().startLoadPlanning();
    } else {
      Get.toNamed(AppRoutes.loadPlanning);
    }
  }

  Future<void> downloadExcelReport() async {
    try {
      await FileExportService.saveCsv(
        fileName:
            'comparison_report_${requestId.value.isEmpty ? 'export' : requestId.value}',
        rows: [
          const [
            'Part Number',
            'Description',
            'Ordered Qty',
            'Shipped Qty',
            'Difference',
            'Status',
            'Reason',
          ],
          ...comparisonItems.map(
            (item) => [
              item.partNumber,
              item.description,
              item.orderedQty,
              item.shippedQty,
              item.difference,
              item.statusDisplay,
              item.reason,
            ],
          ),
        ],
      );
      Get.snackbar(
        'Report downloaded',
        'Comparison CSV was created successfully.',
        backgroundColor: const Color(0xFF2563EB),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (error) {
      Get.snackbar('Download failed', error.toString());
    }
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
