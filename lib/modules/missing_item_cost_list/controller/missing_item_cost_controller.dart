import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../item_cost_list/model/item_cost_model.dart';
import '../../item_cost_list/widgets/add_edit_part_cost_dialog.dart';
import '../../item_cost_list/widgets/success_dialog.dart';
import '../model/missing_item_cost_model.dart';

class MissingItemCostController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'Latest'.obs;
  final RxBool selectAll = false.obs;

  final RxInt missingQty = 15.obs;

  final RxList<MissingItemCostModel> missingItems = <MissingItemCostModel>[].obs;
  final RxList<MissingItemCostModel> filteredItems = <MissingItemCostModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMissingItems();
  }

  void loadMissingItems() {
    isLoading.value = true;
    final list = [
      MissingItemCostModel(id: '1', partName: "'30_VRR48'", partColor: "'-'", costUnit: "'FT'", description: "'VRR+ Insul R10'"),
      MissingItemCostModel(id: '2', partName: "'30_VRR72'", partColor: "'-'", costUnit: "'FT'", description: "'VRR+ Insul R10'"),
      MissingItemCostModel(id: '3', partName: "'35_VRR48'", partColor: "'-'", costUnit: "'FT'", description: "'VRR+ Insul R11'"),
      MissingItemCostModel(id: '4', partName: "'35_VRR72'", partColor: "'-'", costUnit: "'FT'", description: "'VRR+ Insul R11'"),
      MissingItemCostModel(id: '5', partName: "'40_VRR48'", partColor: "'-'", costUnit: "'FT'", description: "'VRR+ Insul R13'"),
      MissingItemCostModel(id: '6', partName: "'40_VRR72'", partColor: "'-'", costUnit: "'FT'", description: "'VRR+ Insul R13'"),
      MissingItemCostModel(id: '7', partName: "'60_VRR48'", partColor: "'-'", costUnit: "'FT'", description: "'VRR+ Insul R19'"),
      MissingItemCostModel(id: '8', partName: "'60_VRR72'", partColor: "'-'", costUnit: "'FT'", description: "'VRR+ Insul R19'"),
      MissingItemCostModel(id: '9', partName: "'30_UF48 '", partColor: "'-'", costUnit: "'FT'", description: "-"),
      MissingItemCostModel(id: '10', partName: "'30_UF72 '", partColor: "'-'", costUnit: "'FT'", description: "'UF Insul R10 '"),
      MissingItemCostModel(id: '11', partName: "'35_UF48 '", partColor: "'-'", costUnit: "'FT'", description: "'UF Insul R10 '"),
      MissingItemCostModel(id: '12', partName: "'35_UF72 '", partColor: "'-'", costUnit: "'FT'", description: "'UF Insul R11 '"),
      MissingItemCostModel(id: '13', partName: "'40_UF48 '", partColor: "'-'", costUnit: "'FT'", description: "'UF Insul R11 '"),
      MissingItemCostModel(id: '14', partName: "'40_UF72 ' '", partColor: "'-'", costUnit: "'FT'", description: "'UF Insul R13 '"),
      MissingItemCostModel(id: '15', partName: "'60_UF48 '", partColor: "'-'", costUnit: "'FT'", description: "'UF Insul R13 '"),
      MissingItemCostModel(id: '16', partName: "'60_UF72 '", partColor: "'-'", costUnit: "'FT'", description: "'UF Insul R19 '"),
      MissingItemCostModel(id: '17', partName: "'R30_FG9.5'", partColor: "'-'", costUnit: "'FT'", description: "'UF Insul R19 '"),
      MissingItemCostModel(id: '18', partName: "'R30_FG10'", partColor: "'-'", costUnit: "'FT'", description: "'Fiber Glass 9.5'"),
      MissingItemCostModel(id: '19', partName: "'R30_MW7.5'", partColor: "'-'", costUnit: "'FT'", description: "'Fiber Glass 10'"),
      MissingItemCostModel(id: '20', partName: "'R30_SF'", partColor: "'-'", costUnit: "'FT'", description: "'Mineral Wool7.5'"),
    ];

    missingItems.assignAll(list);
    applyFilter();
    isLoading.value = false;
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
        missingItems.where((item) =>
            item.partName.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            item.partColor.toLowerCase().contains(q)),
      );
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

  void openAddCostForItemDialog(BuildContext context, MissingItemCostModel item) {
    final draft = ItemCostModel(
      id: item.id,
      partName: item.partName,
      partColor: item.partColor,
      costUnit: item.costUnit,
      description: item.description,
    );

    showDialog(
      context: context,
      builder: (ctx) => AddEditPartCostDialog(
        itemToEdit: draft,
        onSave: (newItem) {
          missingItems.removeWhere((e) => e.id == item.id);
          if (missingQty.value > 0) missingQty.value--;
          applyFilter();

          showDialog(
            context: context,
            builder: (successCtx) => SuccessDialog(
              title: 'Item/Part Cost Saved Successfully',
              buttonText: 'Ok',
              onPressed: () => Navigator.of(successCtx).pop(),
            ),
          );
        },
      ),
    );
  }

  void saveAndContinue(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SuccessDialog(
        title: 'Cost Mapping Approved',
        secondaryButtonText: 'Cancel',
        onSecondaryPressed: () => Navigator.of(ctx).pop(),
        buttonText: 'Categories Items',
        onPressed: () {
          Navigator.of(ctx).pop();
          Get.back();
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
