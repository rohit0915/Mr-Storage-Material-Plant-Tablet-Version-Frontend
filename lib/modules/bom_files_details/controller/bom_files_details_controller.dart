import 'dart:async';

import 'package:get/get.dart';
import 'package:file_saver/file_saver.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../../app/services/plant_socket_service.dart';
import '../model/bom_files_details_model.dart';
import '../model/bom_document_mapper.dart';
import '../repository/bom_files_details_repository.dart';

class BomFilesDetailsController extends GetxController {
  final BomFilesDetailsRepository repository;
  BomFilesDetailsController({required this.repository});
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<BomSummaryModel?> summary = Rx<BomSummaryModel?>(null);
  final Rx<MissingItemCostSummaryModel?> missingSummary =
      Rx<MissingItemCostSummaryModel?>(null);
  final RxList<BomItemModel> bomItems = <BomItemModel>[].obs;
  final RxMap<String, List<BomItemModel>> groupedBomItems =
      <String, List<BomItemModel>>{}.obs;

  final RxString projectId = ''.obs;
  final RxString projectName = ''.obs;
  final RxString bomId = ''.obs;
  final RxString date = ''.obs;
  final RxString jobId = ''.obs;
  final RxString customerName = ''.obs;
  final RxString totalCost = ''.obs;
  final RxString sourceFileUrl = ''.obs;
  final RxString buildingName = ''.obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxInt pricedItems = 0.obs;
  final RxString buildingId = ''.obs;
  final RxBool isConfirmed = false.obs;
  final RxBool isConfirming = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt rowsPerPage = 50.obs;
  final RxInt totalEntries = 0.obs;
  StreamSubscription<PlantSocketEvent>? _socketSubscription;

  int get totalPages =>
      (totalEntries.value / rowsPerPage.value).ceil().clamp(1, 999);

  static const filters = ['all', 'unpriced', 'bom_priced', 'frames', 'matched'];

  final RxInt qtyTotal = 0.obs;
  final RxDouble totalTons = 0.0.obs;
  final RxDouble totalWeightLbs = 0.0.obs;
  final RxDouble totalCostAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor(
        {
          'bom_extraction_complete',
          'bom_extraction_failed',
          'bom_review_complete',
        },
        (event) {
          final eventJobId = event.payload['jobId']?.toString();
          if (eventJobId == null ||
              eventJobId.isEmpty ||
              eventJobId == jobId.value ||
              eventJobId == Get.parameters['id']) {
            loadBomData();
          }
        },
      );
    }
    loadBomData();
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadBomData() async {
    isLoading.value = true;
    errorMessage.value = '';
    final id = Get.parameters['id'] ?? '';
    projectId.value = Get.parameters['projectId'] ?? '';
    buildingName.value = Get.parameters['buildingName'] ?? '';

    try {
      if (Get.parameters['mode'] == 'consolidated') {
        final leadId = projectId.value.isNotEmpty ? projectId.value : id;
        if (leadId.isEmpty) throw Exception('Project id is missing.');
        final data = await repository.fetch(leadId);
        _applyConsolidatedData(data, leadId);
      } else if (id.isNotEmpty) {
        final data = await repository.fetchJob(
          id,
          filter: filters[selectedTabIndex.value],
          page: currentPage.value,
          limit: rowsPerPage.value,
        );
        _applyJob(data, id);
        qtyTotal.value = bomItems.fold(0, (sum, item) => sum + item.qty);
        totalWeightLbs.value = _number(summary.value?.totalWeight ?? '0');
        totalTons.value = totalWeightLbs.value / 2000;
        totalCostAmount.value = _number(summary.value?.totalCost ?? '0');
        totalCost.value = summary.value?.totalCost ?? '\$0.00';
      } else {
        throw Exception('BOM job id is missing.');
      }
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      _clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyConsolidatedData(Map<String, dynamic> data, String leadId) {
    final document = BomDocumentMapper.fromApi(
      projectId: leadId,
      response: data,
    );
    projectName.value = Get.parameters['name'] ?? document.projectName;
    projectId.value = document.projectId;
    bomId.value = document.bomId;
    buildingName.value = '';
    customerName.value = Get.parameters['customer'] ?? document.customerName;
    jobId.value = Get.parameters['projectJobId'] ?? document.jobId;
    date.value = document.date;
    sourceFileUrl.value = document.sourceFileUrl;
    summary.value = document.summary;
    missingSummary.value = document.missingSummary;
    bomItems.assignAll(document.items);
    final groups = <String, List<BomItemModel>>{};
    for (final item in document.items) {
      groups.putIfAbsent(item.category, () => []).add(item);
    }
    groupedBomItems.assignAll(groups);
    totalEntries.value = document.items.length;
    pricedItems.value = document.items.where((item) => !item.isMissing).length;
    qtyTotal.value = document.items.fold(0, (sum, item) => sum + item.qty);
    totalWeightLbs.value = _number(document.summary.totalWeight);
    totalTons.value = totalWeightLbs.value / 2000;
    totalCostAmount.value = _number(document.summary.totalCost ?? '0');
    totalCost.value = document.summary.totalCost ?? '\$0.00';
  }

  Future<void> selectTab(int index) async {
    if (selectedTabIndex.value == index) return;
    selectedTabIndex.value = index;
    currentPage.value = 1;
    await loadBomData();
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > totalPages || page == currentPage.value) return;
    currentPage.value = page;
    await loadBomData();
  }

  Future<void> changeRowsPerPage(int rows) async {
    if (rows == rowsPerPage.value) return;
    rowsPerPage.value = rows;
    currentPage.value = 1;
    await loadBomData();
  }

  void _applyJob(Map<String, dynamic> data, String bomJobId) {
    final rawSummary = _map(data['summary']);
    final rawJob = _map(data['bomJob']);
    buildingId.value = _nestedId(rawJob['buildingId']);
    isConfirmed.value = rawJob['isConfirmed'] == true;
    final rawGroups = _map(data['itemsByCategory']);
    totalEntries.value = _int(data['total'] ?? rawSummary['totalItems']);
    final groups = <String, List<BomItemModel>>{};
    for (final entry in rawGroups.entries) {
      if (entry.value is! List) continue;
      final items = (entry.value as List)
          .whereType<Map>()
          .map((raw) => _jobItem(Map<String, dynamic>.from(raw), entry.key))
          .toList();
      if (items.isNotEmpty) groups[entry.key] = items;
    }
    groupedBomItems.assignAll(groups);
    bomItems.assignAll(groups.values.expand((items) => items));

    projectName.value =
        Get.parameters['name'] ??
        (rawJob['projectName'] ?? 'BOM Details').toString();
    bomId.value = bomJobId;
    buildingName.value =
        Get.parameters['buildingName'] ??
        'Building -${rawJob['buildingNumber'] ?? 'N/A'}';
    customerName.value = Get.parameters['customer'] ?? 'N/A';
    jobId.value = Get.parameters['projectJobId'] ?? 'N/A';
    date.value = Get.parameters['date'] ?? 'N/A';
    sourceFileUrl.value = (rawJob['fileUrl'] ?? '').toString();

    final totalItems = _int(rawSummary['totalItems']);
    pricedItems.value = _int(rawSummary['pricedItems']);
    final unpriced = _int(rawSummary['unpricedItems']);
    final weight = _double(rawSummary['totalWeight']);
    final cost = _double(rawSummary['totalCost']);
    summary.value = BomSummaryModel(
      totalItems: totalItems,
      totalWeight: '${_compact(weight)} lbs',
      totalPanelsArea: '0 sq ft',
      totalCost: '\$${cost.toStringAsFixed(2)}',
    );
    missingSummary.value = MissingItemCostSummaryModel(
      totalAmount: 0,
      missingItemQty: unpriced,
    );
  }

  Future<void> confirmBom() async {
    if (buildingId.value.isEmpty || isConfirming.value) return;
    isConfirming.value = true;
    try {
      await repository.confirmBuilding(buildingId.value);
      isConfirmed.value = true;
      CommonSnackbar.showSuccess(
        title: 'BOM Confirmed',
        message: 'BOM has been confirmed successfully.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Confirmation failed',
        message: error.toString(),
      );
    } finally {
      isConfirming.value = false;
    }
  }

  BomItemModel _jobItem(Map<String, dynamic> item, String category) {
    final isPriced = item['isPriced'] == true;
    return BomItemModel(
      category: category,
      qty: _int(item['quantity']),
      mark: (item['markId'] ?? '-').toString(),
      description: (item['description'] ?? '-').toString(),
      part: (item['partCode'] ?? '-').toString(),
      color: (item['partColor'] ?? '-').toString(),
      angle: '-',
      thick: (item['gauge'] ?? item['type'] ?? '--').toString(),
      length:
          (item['lengthRaw'] ??
                  (item['lengthFeet'] == null
                      ? '--'
                      : "${item['lengthFeet']}'"))
              .toString(),
      weight: _compact(_double(item['weight'])),
      amount: isPriced
          ? '\$${_double(item['finalTotalCost']).toStringAsFixed(2)}'
          : 'Unpriced',
      isMissing: !isPriced,
      isFrame: filters[selectedTabIndex.value] == 'frames',
      isMatched: filters[selectedTabIndex.value] == 'matched',
    );
  }

  void _clear() {
    projectName.value = '';
    bomId.value = '';
    date.value = '';
    jobId.value = '';
    customerName.value = '';
    totalCost.value = '';
    sourceFileUrl.value = '';
    summary.value = null;
    missingSummary.value = null;
    bomItems.clear();
    groupedBomItems.clear();
    qtyTotal.value = 0;
    totalWeightLbs.value = 0;
    totalTons.value = 0;
    totalCostAmount.value = 0;
  }

  Future<void> downloadExcel() async {
    try {
      if (sourceFileUrl.value.isEmpty) {
        throw Exception('The BOM Excel file is not available.');
      }
      await FileSaver.instance.saveFile(
        name: '${bomId.value}_bom_details',
        link: LinkDetails(link: sourceFileUrl.value),
        fileExtension: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
      CommonSnackbar.showSuccess(
        title: 'Download complete',
        message: '${bomId.value} BOM Excel was downloaded.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Download failed',
        message: error.toString(),
      );
    }
  }

  double _number(String value) =>
      double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0;

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  double _double(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  String _compact(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  String _nestedId(dynamic value) => value is Map
      ? (value['_id'] ?? value['id'] ?? '').toString()
      : (value ?? '').toString();
}
