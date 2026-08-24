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

  @override
  void onInit() {
    super.onInit();
    loadItemCosts();
  }

  Future<void> loadItemCosts() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        repository.stats(),
        repository.list(search: searchQuery.value),
      ]);
      final stats = results[0];
      final data = results[1];
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
        newAdded: _int(stats['newAdded']),
      );
      applyFilter();
    } catch (error) {
      errorMessage.value = error.toString();
      itemCosts.clear();
      filteredItemCosts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  ItemCostModel _model(Map<String, dynamic> item) => ItemCostModel(
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
    applyFilter();
  }

  void applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    final result = query.isEmpty
        ? itemCosts
        : itemCosts.where(
            (item) =>
                item.partName.toLowerCase().contains(query) ||
                item.description.toLowerCase().contains(query) ||
                item.partColor.toLowerCase().contains(query),
          );
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
      onSave: (item) => _save(item, context, isEdit: false),
    ),
  );
  void openEditPartCostDialog(BuildContext context, ItemCostModel item) =>
      showDialog(
        context: context,
        builder: (_) => AddEditPartCostDialog(
          itemToEdit: item,
          onSave: (updated) => _save(updated, context, isEdit: true),
        ),
      );
  Future<void> _save(
    ItemCostModel item,
    BuildContext context, {
    required bool isEdit,
  }) async {
    try {
      final payload = {
        'category': 'General',
        'partName': item.partName,
        'partColor': item.partColor,
        'costUnit': item.costUnit,
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
      if (context.mounted) showSaveSuccessDialog(context);
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Unable to save item',
        message: error.toString(),
      );
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
      final bytes = await repository.export(search: searchQuery.value);
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
