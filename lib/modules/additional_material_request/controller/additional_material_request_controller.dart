import 'package:get/get.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../model/additional_material_request_model.dart';

class AdditionalMaterialRequestController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<MaterialInventoryItemModel> inventoryList = <MaterialInventoryItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInventoryData();
  }

  void loadInventoryData() {
    isLoading.value = true;
    inventoryList.assignAll([
      MaterialInventoryItemModel(
        id: '1',
        material: 'Cement\nOPC 53',
        category: 'Cement',
        qnt: '230',
        updated: '08-Apr',
      ),
      MaterialInventoryItemModel(
        id: '2',
        material: 'TMT Steel\n12mm',
        category: 'Steel',
        qnt: '8.2',
        updated: '08-Apr',
      ),
      MaterialInventoryItemModel(
        id: '3',
        material: 'Aggregates\n20mm',
        category: 'Aggregate',
        qnt: '40',
        updated: '08-Apr',
      ),
      MaterialInventoryItemModel(
        id: '4',
        material: 'Chemical\nHardener',
        category: 'Consumable',
        qnt: '4',
        updated: '08-Apr',
      ),
      MaterialInventoryItemModel(
        id: '5',
        material: 'Cement\nOPC 53',
        category: 'Cement',
        qnt: '230',
        updated: '08-Apr',
      ),
      MaterialInventoryItemModel(
        id: '6',
        material: 'TMT Steel\n12mm',
        category: 'Steel',
        qnt: '8.2',
        updated: '08-Apr',
      ),
      MaterialInventoryItemModel(
        id: '7',
        material: 'Aggregates\n20mm',
        category: 'Aggregate',
        qnt: '40',
        updated: '08-Apr',
      ),
      MaterialInventoryItemModel(
        id: '8',
        material: 'Chemical\nHardener',
        category: 'Consumable',
        qnt: '4',
        updated: '08-Apr',
      ),
    ]);
    isLoading.value = false;
  }

  void toggleApprove(int index) {
    inventoryList[index].isApproved = !inventoryList[index].isApproved;
    inventoryList.refresh();

    CommonSnackbar.showSuccess(
      title: inventoryList[index].isApproved ? 'Approved' : 'Status Reset',
      message: '${inventoryList[index].material.replaceAll('\n', ' ')} ${inventoryList[index].isApproved ? 'has been approved' : 'status changed'}.',
    );
  }

  void exportPdf() {
    CommonSnackbar.showSuccess(
      title: 'Export PDF',
      message: 'Material inventory list PDF downloaded successfully.',
    );
  }
}
