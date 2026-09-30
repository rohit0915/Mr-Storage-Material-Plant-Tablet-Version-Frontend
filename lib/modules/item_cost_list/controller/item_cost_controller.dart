import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../model/item_cost_model.dart';
import '../repository/item_cost_repository.dart';
import '../widgets/add_edit_part_cost_dialog.dart';
import '../widgets/success_dialog.dart';
import '../widgets/upload_bom_file_dialog.dart';

class ItemCostController extends GetxController {
  final ItemCostRepository repository;
  ItemCostController({required this.repository});

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final sortBy = 'Latest'.obs;
  final selectAll = false.obs;
  final summary = ItemCostSummaryModel(
    totalItemCost: 0,
    totalItems: 0,
    newAdded: 0,
  ).obs;
  final itemCosts = <ItemCostModel>[].obs;
  final filteredItemCosts = <ItemCostModel>[].obs;

  final category = ''.obs;
  final categories = <String>[].obs;
  final currentPage = 1.obs;
  final rowsPerPage = 50.obs;
  final totalItems = 0.obs;
  final workers = <Worker>[];
  int generation = 0;
  int get totalPages => (totalItems.value / rowsPerPage.value).ceil().clamp(1, 1000000);
  void changePage(int page) { currentPage.value = page; loadItemCosts(); }
  void changeRows(int rows) { rowsPerPage.value = rows; changePage(1); }
  @override
  void onClose() { for (final worker in workers) { worker.dispose(); } super.onClose(); }

  @override
  void onInit() {
    super.onInit();
    workers.add(debounce(searchQuery, (_) => changePage(1), time: const Duration(milliseconds: 350)));
    workers.add(ever(category, (_) => changePage(1)));
    workers.add(ever(sortBy, (_) => applyFilter()));
    loadItemCosts();
  }

  Future<void> loadItemCosts() async {
    final request = ++generation;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        repository.stats(),
        repository.list(search: searchQuery.value, category: category.value, page: currentPage.value, limit: rowsPerPage.value),
      ]);
      if (request != generation) return;
      final stats = results[0];
      final data = results[1];
      categories.assignAll((data['categories'] as List? ?? []).map((value) => value.toString()));
      totalItems.value = _int(data['total']);
      final raw = data['items'] is List ? data['items'] as List : const [];
      itemCosts.assignAll(
        raw.whereType<Map>().map(
          (entry) => _model(Map<String, dynamic>.from(entry)),
        ),
      );
      final totalCost = itemCosts.fold<double>(
        0,
        (sum, item) => sum + (item.mbsCost ?? 0),
      );
      summary.value = ItemCostSummaryModel(
        totalItemCost: _double(stats['totalItemCost'] ?? totalCost),
        totalItems: _int(stats['totalItems'] ?? data['total']),
        newAdded: _int(stats['newlyAdded'] ?? stats['newAdded']),
      );
      applyFilter();
    } catch (error) {
      if (request != generation) return;
      errorMessage.value = error.toString();
      itemCosts.clear();
      filteredItemCosts.clear();
    } finally {
      if (request == generation) isLoading.value = false;
    }
  }

  ItemCostModel _model(Map<String, dynamic> item) => ItemCostModel(
    category: (item['category'] ?? '').toString(),
    id: (item['_id'] ?? item['id'] ?? '').toString(),
    partName: (item['partName'] ?? item['description'] ?? '').toString(),
    partColor: (item['partColor'] ?? item['color'] ?? '').toString(),
    costUnit: (item['costUnit'] ?? 'EA').toString(),
    mbsCost: _nullableDouble(item['mbsCost']),
    currentMarketCost: _nullableDouble(item['currentMarketCost']),
    laborCost: _double(item['laborCost']),
    additionalCost: _double(item['additionalCost']),
    materialCost: _double(item['materialCost']),
    description: (item['description'] ?? item['partName'] ?? '').toString(),
    isFrameType: 'Standard',
    status: item['isActive'] == false ? 'Inactive' : 'Active',
  );

  void filterSearchResults(String query) {
    searchQuery.value = query;
  }

  void applyFilter() {
    final result = itemCosts.toList();
    if (sortBy.value == 'Name A-Z') result.sort((a, b) => a.partName.compareTo(b.partName));
    if (sortBy.value == 'MBS Cost High-Low') result.sort((a, b) => (b.mbsCost ?? 0).compareTo(a.mbsCost ?? 0));
    filteredItemCosts.assignAll(result);
  }

  void toggleSelectAll(bool? value) {
    selectAll.value = value ?? false;
    for (final item in itemCosts) {
      item.isSelected = selectAll.value;
    }
    itemCosts.refresh();
    filteredItemCosts.refresh();
  }

  void toggleSelectItem(ItemCostModel item, bool? value) {
    item.isSelected = value ?? false;
    itemCosts.refresh();
    filteredItemCosts.refresh();
  }

  void openAddPartCostDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AddEditPartCostDialog(
      onSave: (item) => _save(item, isEdit: false),
    ),
  );
  void openEditPartCostDialog(BuildContext context, ItemCostModel item) =>
      showDialog(
        context: context,
        builder: (_) => AddEditPartCostDialog(
          itemToEdit: item,
          onSave: (updated) => _save(updated, isEdit: true),
        ),
      );
  Future<void> _save(
    ItemCostModel item,
    {
    required bool isEdit,
  }) async {
    try {
      final payload = {
        'category': item.category,
        'partName': item.partName,
        'partColor': item.partColor,
        'costUnit': item.costUnit,
        'laborCost': item.laborCost,
        'additionalCost': item.additionalCost,
        'materialCost': item.materialCost,
        'mbsCost': item.mbsCost,
        'currentMarketCost': item.currentMarketCost,
        'description': item.description,
      };
      if (isEdit) {
        await repository.update(item.id, payload);
      } else {
        await repository.add(payload);
      }
      await loadItemCosts();
      CommonSnackbar.showSuccess(title: 'Item saved', message: 'The cost record was saved.');
    } catch (error) {
      rethrow;
    }
  }

  void showSaveSuccessDialog(BuildContext context) => showDialog(
    context: context,
    builder: (ctx) => SuccessDialog(
      title: 'Item/Part Cost Saved Successfully',
      buttonText: 'Ok',
      onPressed: () => Navigator.of(ctx).pop(),
    ),
  );
  void openUploadBomDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) => UploadBomFileDialog(
      onUploadSuccess: () => Get.toNamed(AppRoutes.bomFilesDetails),
    ),
  );
  Future<void> exportFile(BuildContext context) async {
    try {
      final bytes = await repository.export(search: searchQuery.value, category: category.value);
      await FileSaver.instance.saveFile(
        name: 'smdt-cost-list',
        bytes: bytes,
        fileExtension: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
      CommonSnackbar.showSuccess(
        title: 'Excel exported successfully',
        message: 'smdt-cost-list.xlsx was downloaded.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Export failed',
        message: error.toString(),
      );
    }
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  double _double(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  double? _nullableDouble(dynamic value) =>
      value == null ? null : _double(value);
}
