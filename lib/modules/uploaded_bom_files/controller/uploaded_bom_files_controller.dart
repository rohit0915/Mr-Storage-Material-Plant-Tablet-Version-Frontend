import 'package:get/get.dart';
import '../model/uploaded_bom_files_model.dart';

class UploadedBomFilesController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<UploadedBomFileModel> bomFilesList = <UploadedBomFileModel>[].obs;
  final RxString selectedSort = 'Latest'.obs;
  final RxInt selectedRowsPerPage = 10.obs;
  final RxInt currentPage = 4.obs;

  @override
  void onInit() {
    super.onInit();
    loadBomFiles();
  }

  void loadBomFiles() {
    isLoading.value = true;
    bomFilesList.assignAll([
      UploadedBomFileModel(
        id: '1',
        project: 'ABC Warehouse',
        uploadDate: '22 Feb 2025',
        items: 125,
        status: 'Pending',
        isSelected: false,
      ),
      UploadedBomFileModel(
        id: '2',
        project: 'Riya Buildings',
        uploadDate: '07 Feb 2025',
        items: 98,
        status: 'Shared to Shippers',
        isSelected: true,
      ),
      UploadedBomFileModel(
        id: '3',
        project: 'ABC Warehouse',
        uploadDate: '30 Jan 2025',
        items: 210,
        status: 'Locked',
        isSelected: true,
      ),
      UploadedBomFileModel(
        id: '4',
        project: 'Riya Buildings',
        uploadDate: '17 Jan 2025',
        items: 125,
        status: 'Locked',
        isSelected: false,
      ),
      UploadedBomFileModel(
        id: '5',
        project: 'ABC Warehouse',
        uploadDate: '04 Jan 2025',
        items: 98,
        status: 'Locked',
        isSelected: false,
      ),
      UploadedBomFileModel(
        id: '6',
        project: 'Riya Buildings',
        uploadDate: '09 Dec 2024',
        items: 210,
        status: 'Locked',
        isSelected: false,
      ),
    ]);
    isLoading.value = false;
  }

  void toggleSelectAll(bool? val) {
    final value = val ?? false;
    for (var item in bomFilesList) {
      item.isSelected = value;
    }
    bomFilesList.refresh();
  }

  void toggleSelectItem(int index, bool? val) {
    bomFilesList[index].isSelected = val ?? false;
    bomFilesList.refresh();
  }
}
