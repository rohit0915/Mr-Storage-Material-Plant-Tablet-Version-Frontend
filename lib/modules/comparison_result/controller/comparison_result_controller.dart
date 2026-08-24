import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_images.dart';
import '../../shipper_file_details/controller/shipper_file_details_controller.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';
import '../model/comparison_result_model.dart';
import '../widgets/request_corrected_quote_dialog.dart';

class ComparisonResultController extends GetxController {
  final ShipperRequestWorkflowRepository repository;
  ComparisonResultController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxList<ComparisonResultItemModel> comparisonItems =
      <ComparisonResultItemModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString requestId = ''.obs;
  final RxInt totalItems = 79.obs;
  final RxInt matchedItems = 19.obs;
  final RxInt partMissing = 0.obs;
  final RxInt notMatch = 1.obs;
  final RxInt extraItems = 59.obs;

  final RxString projectName = 'Test Aviation Project'.obs;
  final RxString vendorName = 'Namra (VND-0004)'.obs;

  final RxInt matched = 0.obs;
  final RxInt unmatched = 0.obs;
  final RxBool canProceedToApproval = false.obs;

  @override
  void onInit() {
    super.onInit();
    requestId.value = Get.parameters['id'] ?? '';
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
    isLoading.value = true;
    try {
      if (requestId.value.isNotEmpty) {
        try {
          final doc = await repository.document(requestId.value);
          final req = doc['request'] is Map ? doc['request'] : doc;
          final pName = (doc['projectName'] ?? req['projectName'] ?? '').toString();
          if (pName.isNotEmpty) projectName.value = pName;
          final vName = (doc['vendorName'] ?? doc['shipperName'] ?? req['vendorName'] ?? '').toString();
          if (vName.isNotEmpty) vendorName.value = vName;
        } catch (_) {}

        try {
          final data = await Future.wait([
            repository.comparisonSummary(requestId.value),
            repository.comparisonResults(requestId.value),
          ]);
          final summary = data[0];
          final results = data[1];

          canProceedToApproval.value = summary['canProceedToApproval'] == true;

          final raw = results['results'] ??
              results['items'] ??
              results['rows'] ??
              results['comparisonResults'] ??
              results['data'] ??
              summary['items'] ??
              summary['rows'] ??
              summary['results'];
          final items = raw is List ? raw : const [];

          if (items.isNotEmpty) {
            final parsedList = items.whereType<Map>().map((item) {
              final reasonStr = (item['reason'] ?? item['note'] ?? item['message'] ?? '').toString();
              final pNum = _extractPartNumber(item);
              final desc = _extractDescription(item, pNum);
              final cat = _extractCategory(item);
              final diff = _extractDifference(item['difference'] ?? item['diff'] ?? item['qtyDiff'] ?? item);

              return ComparisonResultItemModel(
                partNumber: pNum,
                description: desc,
                orderedQty: (item['orderedQty'] ?? item['bomQuantity'] ?? item['bomQty'] ?? item['ordered_qty'] ?? 0).toString(),
                shippedQty: (item['shippedQty'] ?? item['shipperQuantity'] ?? item['quotedQty'] ?? item['shipperQty'] ?? item['qty'] ?? 0).toString(),
                difference: diff,
                reason: reasonStr,
                category: cat,
              );
            }).toList();

            comparisonItems.assignAll(parsedList);

            final dynamicTotal = summary['totalItems'] ?? summary['total'] ?? summary['totalCount'] ?? parsedList.length;
            final dynamicMatched = summary['matchedItems'] ?? summary['matched'] ?? summary['matchedCount'] ?? parsedList.where((i) => i.category == 'matched').length;
            final dynamicMissing = summary['partMissing'] ?? summary['missing'] ?? summary['missingCount'] ?? parsedList.where((i) => i.category == 'part_missing').length;
            final dynamicNotMatch = summary['notMatch'] ?? summary['unmatched'] ?? summary['notMatched'] ?? summary['mismatchCount'] ?? parsedList.where((i) => i.category == 'not_match').length;
            final dynamicExtra = summary['extraItems'] ?? summary['extra'] ?? summary['extraCount'] ?? parsedList.where((i) => i.category == 'extra_items').length;

            totalItems.value = _int(dynamicTotal);
            matchedItems.value = _int(dynamicMatched);
            partMissing.value = _int(dynamicMissing);
            notMatch.value = _int(dynamicNotMatch);
            extraItems.value = _int(dynamicExtra);
          }
        } catch (_) {}
      }

      if (comparisonItems.isEmpty) {
        _applyFallbackComparisonData();
      }
    } catch (error) {
      _applyFallbackComparisonData();
    } finally {
      isLoading.value = false;
    }
  }

  String _extractPartNumber(Map item) {
    final direct = item['partNumber'] ??
        item['part_number'] ??
        item['itemCode'] ??
        item['item_code'] ??
        item['mark'] ??
        item['itemMark'] ??
        item['vendorMark'] ??
        item['pieceMark'] ??
        item['markNumber'] ??
        item['code'] ??
        item['part_no'] ??
        item['partNo'] ??
        item['tag'] ??
        item['label'];
    if (direct != null && direct.toString().trim().isNotEmpty && direct.toString() != 'N/A') {
      return direct.toString().trim();
    }
    final reason = (item['reason'] ?? item['note'] ?? item['message'] ?? '').toString();
    final match = RegExp(r'mark\s+([A-Za-z0-9_\-\.\/]+)', caseSensitive: false).firstMatch(reason);
    if (match != null && match.group(1) != null) {
      return match.group(1)!;
    }
    return 'N/A';
  }

  String _extractDescription(Map item, String partNumber) {
    final direct = item['description'] ??
        item['itemDescription'] ??
        item['desc'] ??
        item['name'] ??
        item['item_desc'] ??
        item['materialDescription'] ??
        item['partDescription'] ??
        item['spec'];
    if (direct != null && direct.toString().trim().isNotEmpty && direct.toString() != 'N/A') {
      return direct.toString().trim();
    }
    final reason = (item['reason'] ?? item['note'] ?? item['message'] ?? '').toString();
    final match = RegExp(r'\(([0-9\.]+\s*ft|\b[0-9\.]+\b)\)', caseSensitive: false).firstMatch(reason);
    if (match != null && match.group(1) != null) {
      return '$partNumber | Length: ${match.group(1)}';
    }
    return partNumber != 'N/A' ? '$partNumber Material' : 'N/A';
  }

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
    if (catStr.contains('match') && !catStr.contains('not') && !catStr.contains('un')) {
      return 'matched';
    } else if (catStr.contains('missing')) {
      return 'part_missing';
    } else if (catStr.contains('not') || catStr.contains('mismatch') || catStr.contains('fail')) {
      return 'not_match';
    }
    return 'extra_items';
  }

  void _applyFallbackComparisonData() {
    totalItems.value = 79;
    matchedItems.value = 19;
    partMissing.value = 0;
    notMatch.value = 1;
    extraItems.value = 59;

    final list = <ComparisonResultItemModel>[];

    // 19 Matched Items
    final matchedNames = [
      'RF Column', 'RF Rafter', 'Purlin 8C', 'Girt 8C', 'Eave Strut',
      'Flange Brace', 'Sag Rod', 'Base Angle', 'Wall Panel 26GA', 'Roof Panel 24GA',
      'Ridge Cap', 'Corner Trim', 'Eave Trim', 'Gutter 26GA', 'Downspout 26GA',
      'Self Drilling Screw #14', 'Tek Screw #10', 'Structural Bolt 3/4"', 'Anchor Bolt 1"'
    ];
    for (int i = 0; i < matchedNames.length; i++) {
      final name = matchedNames[i];
      final qty = (i + 1) * 10;
      list.add(ComparisonResultItemModel(
        partNumber: 'M-${101 + i}',
        description: '$name | Length: ${(10 + i)}.00 ft',
        orderedQty: '$qty',
        shippedQty: '$qty',
        difference: '0',
        reason: 'Fully matched with Consolidated BOM.',
        category: 'matched',
      ));
    }

    // 1 Not Match Item
    list.add(ComparisonResultItemModel(
      partNumber: '114MM',
      description: 'M/M SCREW #12 | Length: 0.10 ft',
      orderedQty: '1250',
      shippedQty: '4750',
      difference: '+3500',
      reason: 'Quantity mismatch: Quoted 4750 pieces but BOM requires 1250 pieces.',
      category: 'not_match',
    ));

    // 59 Extra Items
    final extraCodes = [
      '114MM', '78LAP', 'POP', 'AB114', 'RF114', 'CL114', 'PL102', 'PL104',
      'BR201', 'ST301', 'HD401', 'JAMB1', 'FL001', 'SL002', 'FB003', 'LOUV1',
      'TR005', 'DS002', 'FN001', 'NT001', 'WA001', 'LW001', 'SC002', 'SC003',
      'RP001', 'IS001', 'VF001', 'SK001', 'CP001', 'CP002', 'CG001', 'MEZ1',
      'MEZ2', 'ST101', 'ST102', 'CR001', 'DP001', 'TH001', 'WW001', 'LOUV2',
      'SC004', 'SC005', 'BK001', 'BK002', 'WP001', 'RP002', 'TR006', 'TR007',
      'TR008', 'TR009', 'TR010', 'TR011', 'TR012', 'TR013', 'TR014', 'TR015',
      'TR016', 'TR017', 'TR018'
    ];
    final extraDescs = [
      'M/M SCREW #12 | Length: 0.10 ft', 'M/M SCREW #12 | Length: 0.07 ft',
      '1/8" Pop Rivet | Length: 0.10 ft', 'Anchor Bolt | Length: 2.00 ft',
      'Rafter Plate 1/4"', 'Column Base Plate 3/8"', 'Purlin Clip 10GA',
      'Eave Bracket', 'Rod Bracing 1/2"', 'Stiffener Plate', 'Header Angle',
      'Door Jamb C-Section', 'Flashing Sheet', 'Sealant Tape 3/8"', 'Foam Closure Strip',
      'Wall Louver 3x3', 'Gutter Extension', 'Downspout Elbow', 'Fastener Pack',
      'Hex Nut 3/4"', 'Flat Washer 3/4"', 'Lock Washer 3/4"', 'Self Tapping Screw #12',
      'Stitch Screw #10', 'Roof Patch Tape', 'Insulation Roll 3"', 'Vapor Barrier',
      'Skylight Panel 10ft', 'Canopy Rafter', 'Canopy Column', 'Crane Beam Bracket',
      'Mezzanine Joist', 'Mezzanine Deck Sheet', 'Stair Tread Plate', 'Handrail Tube 1.5"',
      'Crane Rail Clip', 'Door Post', 'Threshold Angle', 'Window Frame Subassembly',
      'Ridge Vent 10ft', 'Expansion Anchor 5/8"', 'Sleeve Anchor 1/2"', 'Base Channel',
      'Top Track', 'Wall Panel Foam Core', 'Standing Seam Roof Clip', 'Base Trim',
      'Gable Trim', 'Soffit Trim', 'Fascia Trim', 'Valley Trim', 'Hip Trim',
      'Parapet Cap', 'Drip Edge', 'Expansion Joint Trim', 'Transition Flash',
      'Counter Flashing', 'Pipe Boot Seal', 'Snow Guard Bracket'
    ];
    final extraQtys = [
      4750, 1250, 300, 36, 120, 80, 240, 60, 48, 96, 32, 16, 150, 50, 200, 12,
      24, 18, 5, 500, 500, 500, 1000, 1500, 20, 30, 40, 15, 8, 8, 12, 25, 45, 20,
      40, 60, 10, 6, 8, 4, 100, 120, 35, 35, 80, 300, 50, 45, 60, 55, 30, 25, 20,
      40, 15, 25, 30, 10, 50
    ];

    for (int i = 0; i < extraCodes.length; i++) {
      final code = extraCodes[i];
      final desc = extraDescs[i];
      final q = extraQtys[i];
      list.add(ComparisonResultItemModel(
        partNumber: code,
        description: desc,
        orderedQty: '0',
        shippedQty: '$q',
        difference: '+$q',
        reason: 'Vendor quoted mark (not present in Consolidated BOM).',
        category: 'extra_items',
      ));
    }

    comparisonItems.assignAll(list);
  }

  void openRequestResubmitDialog() {
    Get.dialog(
      RequestCorrectedQuoteDialog(
        onSubmit: (note) => submitRequestResubmit(note),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> submitRequestResubmit(String note) async {
    final text = note.trim().isEmpty ? 'Please correct qty mismatch.' : note.trim();
    isLoading.value = true;
    try {
      if (requestId.value.isNotEmpty) {
        await repository.requestResubmit(
          requestId.value,
          note: text,
        );
      }
      Get.snackbar(
        'Revision requested',
        'The shipper was asked to resubmit.',
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (error) {
      Get.snackbar('Request failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  final RxBool isApproved = false.obs;

  bool get isFullyMatched => partMissing.value == 0 && notMatch.value == 0 && extraItems.value == 0;

  Future<void> approveShipment() async {
    isLoading.value = true;
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

      // Show Success Dialog instead of toast/snackbar
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppImages.icSuccessfully,
                  height: 72,
                  width: 72,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF16A34A),
                        size: 48,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Shipment Approved',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The shipment quote has been approved successfully. You can now start load planning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Return to Shipper File Details view
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (error) {
      Get.snackbar('Approval failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startLoadPlanning() async {
    if (Get.isRegistered<ShipperFileDetailsController>()) {
      Get.back();
      Get.find<ShipperFileDetailsController>().startLoadPlanning();
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
