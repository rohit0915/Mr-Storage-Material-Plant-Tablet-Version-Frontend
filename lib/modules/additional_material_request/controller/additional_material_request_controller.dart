import 'package:get/get.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../model/additional_material_request_model.dart';

class AdditionalMaterialRequestController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<MaterialInventoryItemModel> inventoryList =
      <MaterialInventoryItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInventoryData();
  }

  void loadInventoryData() {
    isLoading.value = true;
    inventoryList.clear();
    isLoading.value = false;
  }

  void toggleApprove(int index) {
    CommonSnackbar.showError(title: 'Approval unavailable',
      message: 'The reference application does not expose a material-request approval API.');
  }

  Future<void> exportPdf() async {
    try {
      final bytes = await FileExportService.tablePdf(
        title: 'Material Inventory List',
        headers: const [
          'Material',
          'Category',
          'Quantity',
          'Updated',
          'Status',
        ],
        rows: inventoryList
            .map(
              (item) => [
                item.material.replaceAll('\n', ' '),
                item.category,
                item.qnt,
                item.updated,
                item.isApproved ? 'Approved' : 'Pending',
              ],
            )
            .toList(),
      );
      await FileExportService.savePdf(
        fileName: 'material_inventory_list',
        bytes: bytes,
      );
      CommonSnackbar.showSuccess(
        title: 'Export PDF',
        message: 'Material inventory list PDF downloaded successfully.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Export failed',
        message: error.toString(),
      );
    }
  }
}
