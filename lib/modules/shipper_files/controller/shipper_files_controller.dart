import 'package:get/get.dart';
import '../model/shipper_files_model.dart';

class ShipperFilesController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<ShipperFileItemModel> shipperFiles = <ShipperFileItemModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSort = 'Latest'.obs;
  final RxInt currentPage = 4.obs;
  final RxInt rowsPerPage = 10.obs;

  @override
  void onInit() {
    super.onInit();
    loadShipperFiles();
  }

  void loadShipperFiles() {
    isLoading.value = true;

    shipperFiles.assignAll([
      ShipperFileItemModel(
        id: '1',
        shipperName: 'ABC Steel',
        fileName: 'SHP-1044',
        uploadDate: '22 Feb 2025',
        items: 120,
        rate: '\$2900',
        status: 'Pending',
      ),
      ShipperFileItemModel(
        id: '2',
        shipperName: 'Steel Works LTD',
        fileName: 'SHP-1045',
        uploadDate: '07 Feb 2025',
        items: 120,
        rate: '\$3900',
        status: 'Approved',
      ),
      ShipperFileItemModel(
        id: '3',
        shipperName: 'Metro Steel',
        fileName: 'SHP-1046',
        uploadDate: '30 Jan 2025',
        items: 120,
        rate: '\$4900',
        status: 'Compared',
      ),
      ShipperFileItemModel(
        id: '4',
        shipperName: 'ABC Steel',
        fileName: 'SHP-1047',
        uploadDate: '17 Jan 2025',
        items: 120,
        rate: '\$5900',
        status: 'Compared',
      ),
      ShipperFileItemModel(
        id: '5',
        shipperName: 'Steel Works LTD',
        fileName: 'SHP-1048',
        uploadDate: '04 Jan 2025',
        items: 120,
        rate: '\$6900',
        status: 'Compared',
      ),
      ShipperFileItemModel(
        id: '6',
        shipperName: 'Metro Steel',
        fileName: 'SHP-1049',
        uploadDate: '09 Dec 2024',
        items: 120,
        rate: '\$8900',
        status: 'Compared',
      ),
    ]);

    isLoading.value = false;
  }

  List<ShipperFileItemModel> get filteredFiles {
    return shipperFiles.where((item) {
      return searchQuery.value.isEmpty ||
          item.shipperName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          item.fileName.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }
}
