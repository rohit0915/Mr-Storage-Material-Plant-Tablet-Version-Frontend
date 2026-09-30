import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../item_cost_list/model/item_cost_model.dart';
import '../../item_cost_list/widgets/success_dialog.dart';
import '../../item_cost_list/widgets/add_edit_part_cost_dialog.dart';
import '../../bom_files_details/repository/bom_files_details_repository.dart';
import '../model/missing_item_cost_model.dart';

class MissingItemCostController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'Latest'.obs;
  final RxBool selectAll = false.obs;

  final RxInt missingQty = 0.obs;
  final errorMessage = ''.obs;
  final repository = BomFilesDetailsRepository(apiClient: Get.find());

  final RxList<MissingItemCostModel> missingItems =
      <MissingItemCostModel>[].obs;
  final RxList<MissingItemCostModel> filteredItems =
      <MissingItemCostModel>[].obs;

  Worker? _sortWorker;
  @override
  void onClose() {
    _sortWorker?.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _sortWorker = ever(sortBy, (_) => applyFilter());
    loadMissingItems();
  }

  Future<void> loadMissingItems() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final jobId = Get.parameters['jobId'] ?? '';
      if (jobId.isEmpty) {
        throw StateError(
          'Open missing costs from a BOM file to select its extraction job.',
        );
      }
      final records = <Map>[];
      for (var page = 1; ; page++) {
        final data = await repository.fetchJob(
          jobId,
          filter: 'unpriced',
          page: page,
          limit: 100,
        );
        final groups = data['itemsByCategory'] as Map? ?? {};
        final rows = groups.values
            .whereType<List>()
            .expand((rows) => rows)
            .whereType<Map>()
            .toList();
        records.addAll(rows);
        if (rows.length < 100) break;
      }
      missingItems.assignAll(
        records.map(
          (item) => MissingItemCostModel(
            id: (item['_id'] ?? '').toString(),
            category: (item['category'] ?? '').toString(),
            partName: (item['partCode'] ?? '').toString(),
            partColor: (item['partColor'] ?? '').toString(),
            costUnit: (item['costUnit'] ?? '').toString(),
            description: (item['description'] ?? '').toString(),
          ),
        ),
      );
      missingQty.value = missingItems.length;
      applyFilter();
    } catch (e) {
      missingItems.clear();
      filteredItems.clear();
      missingQty.value = 0;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void filterSearchResults(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void applyFilter() {
    if (searchQuery.isEmpty) {
      filteredItems.assignAll(missingItems);
    } else {
      final q = searchQuery.value.toLowerCase();
      filteredItems.assignAll(
        missingItems.where(
          (item) =>
              item.partName.toLowerCase().contains(q) ||
              item.description.toLowerCase().contains(q) ||
              item.partColor.toLowerCase().contains(q),
        ),
      );
    }
    if (sortBy.value == 'Name A-Z') {
      filteredItems.sort((a, b) => a.partName.compareTo(b.partName));
    }
    if (sortBy.value == 'Part Colour') {
      filteredItems.sort((a, b) => a.partColor.compareTo(b.partColor));
    }
  }

  void toggleSelectAll(bool? val) {
    selectAll.value = val ?? false;
    for (var item in missingItems) {
      item.isSelected = selectAll.value;
    }
    missingItems.refresh();
    filteredItems.refresh();
  }

  void toggleSelectItem(MissingItemCostModel item, bool? val) {
    item.isSelected = val ?? false;
    missingItems.refresh();
    filteredItems.refresh();
  }

  void openAddCostForItemDialog(
    BuildContext context,
    MissingItemCostModel item,
  ) {
    final draft = ItemCostModel(
      id: item.id,
      category: item.category,
      partName: item.partName,
      partColor: item.partColor,
      costUnit: item.costUnit,
      description: item.description,
    );

    showDialog(
      context: context,
      builder: (ctx) => AddEditPartCostDialog(
        itemToEdit: draft,
        onSave: (newItem) async {
          await repository.updateItemPrice(item.id, newItem.mbsCost!);
          await loadMissingItems();
        },
      ),
    );
  }

  void saveAndContinue(BuildContext context) {
    if (missingItems.isNotEmpty) {
      CommonSnackbar.showError(
        title: 'Missing costs',
        message: 'Save a price for each missing item first.',
      );
      return;
    }
    Get.back();
  }

  Future<void> exportFile(BuildContext context) async {
    try {
      await FileExportService.saveCsv(
        fileName: 'BOM_missing_items_cost_list',
        rows: [
          const ['Part Name', 'Part Color', 'Cost Unit', 'Description'],
          ...filteredItems.map(
            (item) => [
              item.partName,
              item.partColor,
              item.costUnit,
              item.description,
            ],
          ),
        ],
      );
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => SuccessDialog(
          title: 'File Exported Successfully',
          buttonText: 'Ok',
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Export failed',
        message: error.toString(),
      );
    }
  }
}
