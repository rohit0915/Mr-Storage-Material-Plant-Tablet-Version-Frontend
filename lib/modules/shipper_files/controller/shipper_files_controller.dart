import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/shipper_files_model.dart';
import '../widgets/file_status_changed_dialog.dart';

class ShipperFilesController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<ProjectShipperFileModel> projectsList = <ProjectShipperFileModel>[].obs;
  final RxList<ShipperFileItemModel> shipperFiles = <ShipperFileItemModel>[].obs;

  final RxString selectedProjectName = 'ABC Warehouse'.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSort = 'Latest'.obs;
  final RxString selectedStatus = 'Select Status'.obs;
  final RxInt currentPage = 4.obs;
  final RxInt rowsPerPage = 10.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    isLoading.value = true;

    // Image 1: Main Project List for Shipper Files
    projectsList.assignAll([
      ProjectShipperFileModel(
        projectId: 'PRJ-001',
        projectName: 'ABC Warehouse',
        fileReceived: '22 Feb 2025',
        totalShipperFiles: 5,
      ),
      ProjectShipperFileModel(
        projectId: 'PRJ-002',
        projectName: 'Tech Park Dev',
        fileReceived: '07 Feb 2025',
        totalShipperFiles: 3,
      ),
      ProjectShipperFileModel(
        projectId: 'PRJ-003',
        projectName: 'Downtown Plaza',
        fileReceived: '30 Jan 2025',
        totalShipperFiles: 2,
      ),
      ProjectShipperFileModel(
        projectId: 'PRJ-004',
        projectName: 'Riverside Complex',
        fileReceived: '17 Jan 2025',
        totalShipperFiles: 6,
      ),
      ProjectShipperFileModel(
        projectId: 'PRJ-005',
        projectName: 'Tech Park Dev',
        fileReceived: '04 Jan 2025',
        totalShipperFiles: 4,
      ),
      ProjectShipperFileModel(
        projectId: 'PRJ-006',
        projectName: 'Downtown Plaza',
        fileReceived: '09 Dec 2024',
        totalShipperFiles: 8,
      ),
    ]);

    // Image 2: Files list for selected project
    shipperFiles.assignAll([
      ShipperFileItemModel(
        id: '1',
        shipperName: 'ABC Steel',
        fileName: 'SHP-1044',
        uploadDate: '22 Feb 2025',
        items: 120,
        rate: '\$2100',
        status: 'File Received',
      ),
      ShipperFileItemModel(
        id: '2',
        shipperName: 'Steel Works LTD',
        fileName: 'SHP-1045',
        uploadDate: '07 Feb 2025',
        items: 120,
        rate: '\$3100',
        status: 'Compared',
      ),
      ShipperFileItemModel(
        id: '3',
        shipperName: 'Metro Steel',
        fileName: 'SHP-1046',
        uploadDate: '30 Jan 2025',
        items: 120,
        rate: '\$7100',
        status: 'Revision Sent',
      ),
      ShipperFileItemModel(
        id: '4',
        shipperName: 'ABC Steel',
        fileName: 'SHP-1047',
        uploadDate: '17 Jan 2025',
        items: 120,
        rate: '\$12100',
        status: 'File Received',
      ),
      ShipperFileItemModel(
        id: '5',
        shipperName: 'Steel Works LTD',
        fileName: 'SHP-1048',
        uploadDate: '04 Jan 2025',
        items: 120,
        rate: '\$4100',
        status: 'Compared',
      ),
      ShipperFileItemModel(
        id: '6',
        shipperName: 'Metro Steel',
        fileName: 'SHP-1049',
        uploadDate: '09 Dec 2024',
        items: 120,
        rate: '\$8100',
        status: 'Order Sent',
      ),
    ]);

    isLoading.value = false;
  }

  void updateFileStatus(int index, String newStatus) {
    shipperFiles[index].status = newStatus;
    shipperFiles.refresh();
    Get.dialog(const FileStatusChangedDialog());
  }

  void toggleSelectProject(int index, bool? val) {
    projectsList[index].isSelected = val ?? false;
    projectsList.refresh();
  }

  void toggleSelectFile(int index, bool? val) {
    shipperFiles[index].isSelected = val ?? false;
    shipperFiles.refresh();
  }
}
