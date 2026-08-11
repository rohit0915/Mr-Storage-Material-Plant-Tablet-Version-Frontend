import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../model/item_cost_model.dart';
import '../widgets/add_edit_part_cost_dialog.dart';
import '../widgets/success_dialog.dart';
import '../widgets/upload_bom_file_dialog.dart';

class ItemCostController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'Latest'.obs;
  final RxBool selectAll = false.obs;

  final Rx<ItemCostSummaryModel> summary = ItemCostSummaryModel(
    totalItemCost: 24400.0,
    totalItems: 120,
    newAdded: 2,
  ).obs;

  final RxList<ItemCostModel> itemCosts = <ItemCostModel>[].obs;
  final RxList<ItemCostModel> filteredItemCosts = <ItemCostModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadItemCosts();
  }

  void loadItemCosts() {
    isLoading.value = true;
    final initialList = [
      ItemCostModel(id: '1', partName: "'30_VRR48'", partColor: "'-'", costUnit: "'FT'", mbsCost: 2.6, currentMarketCost: null, description: "'VRR+ Insul R10'"),
      ItemCostModel(id: '2', partName: "'30_VRR72'", partColor: "'-'", costUnit: "'FT'", mbsCost: 3.9, currentMarketCost: null, description: "'VRR+ Insul R10'"),
      ItemCostModel(id: '3', partName: "'35_VRR48'", partColor: "'-'", costUnit: "'FT'", mbsCost: 2.9, currentMarketCost: null, description: "'VRR+ Insul R11'"),
      ItemCostModel(id: '4', partName: "'35_VRR72'", partColor: "'-'", costUnit: "'FT'", mbsCost: 4.4, currentMarketCost: null, description: "'VRR+ Insul R11'"),
      ItemCostModel(id: '5', partName: "'40_VRR48'", partColor: "'-'", costUnit: "'FT'", mbsCost: 3.3, currentMarketCost: null, description: "'VRR+ Insul R13'"),
      ItemCostModel(id: '6', partName: "'40_VRR72'", partColor: "'-'", costUnit: "'FT'", mbsCost: 4.9, currentMarketCost: null, description: "'VRR+ Insul R13'"),
      ItemCostModel(id: '7', partName: "'60_VRR48'", partColor: "'-'", costUnit: "'FT'", mbsCost: 4.2, currentMarketCost: null, description: "'VRR+ Insul R19'"),
      ItemCostModel(id: '8', partName: "'60_VRR72'", partColor: "'-'", costUnit: "'FT'", mbsCost: 6.3, currentMarketCost: null, description: "'VRR+ Insul R19'"),
      ItemCostModel(id: '9', partName: "'30_UF48 '", partColor: "'-'", costUnit: "'FT'", mbsCost: 2.6, currentMarketCost: null, description: "-"),
      ItemCostModel(id: '10', partName: "'30_UF72 '", partColor: "'-'", costUnit: "'FT'", mbsCost: 3.9, currentMarketCost: null, description: "'UF Insul R10 '"),
      ItemCostModel(id: '11', partName: "'35_UF48 '", partColor: "'-'", costUnit: "'FT'", mbsCost: 2.9, currentMarketCost: null, description: "'UF Insul R10 '"),
      ItemCostModel(id: '12', partName: "'35_UF72 '", partColor: "'-'", costUnit: "'FT'", mbsCost: 4.4, currentMarketCost: null, description: "'UF Insul R11 '"),
      ItemCostModel(id: '13', partName: "'40_UF48 '", partColor: "'-'", costUnit: "'FT'", mbsCost: 2.9, currentMarketCost: null, description: "'UF Insul R11 '"),
      ItemCostModel(id: '14', partName: "'40_UF72 ' '", partColor: "'-'", costUnit: "'FT'", mbsCost: 4.4, currentMarketCost: null, description: "'UF Insul R13 '"),
      ItemCostModel(id: '15', partName: "'60_UF48 '", partColor: "'-'", costUnit: "'FT'", mbsCost: 3.3, currentMarketCost: null, description: "'UF Insul R13 '"),
      ItemCostModel(id: '16', partName: "'60_UF72 '", partColor: "'-'", costUnit: "'FT'", mbsCost: 4.9, currentMarketCost: null, description: "'UF Insul R19 '"),
      ItemCostModel(id: '17', partName: "'R30_FG9.5'", partColor: "'-'", costUnit: "'FT'", mbsCost: 4.2, currentMarketCost: null, description: "'UF Insul R19 '"),
      ItemCostModel(id: '18', partName: "'R30_FG10'", partColor: "'-'", costUnit: "'FT'", mbsCost: 6.3, currentMarketCost: null, description: "'Fiber Glass 9.5'"),
      ItemCostModel(id: '19', partName: "'R30_MW7.5'", partColor: "'-'", costUnit: "'FT'", mbsCost: 4.1, currentMarketCost: null, description: "'Fiber Glass 10'"),
      ItemCostModel(id: '20', partName: "'R30_SF'", partColor: "'-'", costUnit: "'FT'", mbsCost: 4.5, currentMarketCost: null, description: "'Mineral Wool7.5'"),
    ];

    itemCosts.assignAll(initialList);
    applyFilter();
    isLoading.value = false;
  }

  void filterSearchResults(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void applyFilter() {
    if (searchQuery.isEmpty) {
      filteredItemCosts.assignAll(itemCosts);
    } else {
      final q = searchQuery.value.toLowerCase();
      filteredItemCosts.assignAll(
        itemCosts.where((item) =>
            item.partName.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            item.partColor.toLowerCase().contains(q)),
      );
    }
  }

  void toggleSelectAll(bool? val) {
    selectAll.value = val ?? false;
    for (var item in itemCosts) {
      item.isSelected = selectAll.value;
    }
    itemCosts.refresh();
    filteredItemCosts.refresh();
  }

  void toggleSelectItem(ItemCostModel item, bool? val) {
    item.isSelected = val ?? false;
    itemCosts.refresh();
    filteredItemCosts.refresh();
  }

  void openAddPartCostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditPartCostDialog(
        onSave: (newItem) {
          itemCosts.insert(0, newItem);
          applyFilter();
          showSaveSuccessDialog(context);
        },
      ),
    );
  }

  void openEditPartCostDialog(BuildContext context, ItemCostModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditPartCostDialog(
        itemToEdit: item,
        onSave: (updatedItem) {
          final idx = itemCosts.indexWhere((e) => e.id == item.id);
          if (idx != -1) {
            itemCosts[idx] = updatedItem;
            applyFilter();
          }
          showSaveSuccessDialog(context);
        },
      ),
    );
  }

  void showSaveSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SuccessDialog(
        title: 'Item/Part Cost Saved Successfully',
        buttonText: 'Ok',
        onPressed: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void openUploadBomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => UploadBomFileDialog(
        onUploadSuccess: () {
          showDialog(
            context: context,
            builder: (successCtx) => SuccessDialog(
              title: 'BOM File Uploaded',
              buttonText: 'View BOM File',
              onPressed: () {
                Navigator.of(successCtx).pop();
                Get.toNamed(AppRoutes.bomFilesDetails);
              },
            ),
          );
        },
      ),
    );
  }

  void exportFile(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SuccessDialog(
        title: 'File Exported Successfully',
        buttonText: 'Ok',
        onPressed: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}
