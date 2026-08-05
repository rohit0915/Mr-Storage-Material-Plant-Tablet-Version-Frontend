import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../model/projects_model.dart';

class ProjectsController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<ProjectStatModel> projectStats = <ProjectStatModel>[].obs;
  final RxList<ProjectItemModel> projectItems = <ProjectItemModel>[].obs;

  // Filter Selection States
  final RxString selectedProjectFilter = 'Select Project'.obs;
  final RxString selectedCustomerFilter = 'Select Customer'.obs;
  final RxString selectedBuildingTypeFilter = 'Building types'.obs;
  final RxString selectedStatusFilter = 'Select Status'.obs;

  // Filter Options Lists matching Figma frames
  final List<String> projectOptions = ['Project 1', 'Project 2', 'Project 3'];
  final List<String> customerOptions = ['John Doe', 'Rohan Palkan', 'Vijay Chadda'];
  final List<String> buildingTypeOptions = ['Warehouse', 'Garages', 'Workshops'];
  final List<String> statusOptions = ['All', 'Approved', 'Pending', 'Drawing Rejected'];

  final RxBool selectAllRows = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjectsData();
  }

  void loadProjectsData() {
    isLoading.value = true;

    projectStats.assignAll([
      ProjectStatModel(
        title: 'Total Projects',
        count: '4',
        iconData: Icons.person_add_outlined,
        backgroundColor: AppColors.totalProjectsCard,
      ),
      ProjectStatModel(
        title: 'Active Projects',
        count: '1',
        iconData: Icons.check_box_outlined,
        backgroundColor: AppColors.inProductionCard,
      ),
      ProjectStatModel(
        title: 'Pending Customer Approval',
        count: '1',
        iconData: Icons.monetization_on_outlined,
        backgroundColor: AppColors.readyToDispatchCard,
      ),
      ProjectStatModel(
        title: 'Canceled Projects',
        count: '0',
        iconData: Icons.show_chart,
        backgroundColor: AppColors.pendingApprovalCard,
      ),
    ]);

    projectItems.assignAll([
      ProjectItemModel(
        id: '1',
        projectName: 'ABC Constructions',
        projectSubtitle: 'Workshop . Texas',
        customerName: 'John Doe',
        customerAvatarInitial: 'J',
        buildingsCount: '1',
        status: 'Approved',
        statusType: ProjectStatusType.approved,
        projectValue: '\$12,500',
        chatCount: '2',
      ),
      ProjectItemModel(
        id: '2',
        projectName: 'PQR Warehouse',
        projectSubtitle: 'Warehouse . Texas',
        customerName: 'Roahan Sharma',
        customerAvatarInitial: 'R',
        buildingsCount: '4',
        status: 'BOM Ready',
        statusType: ProjectStatusType.bomReady,
        projectValue: '\$12,500',
        chatCount: '2',
      ),
      ProjectItemModel(
        id: '3',
        projectName: 'XYZ Mall Building',
        projectSubtitle: 'Workshop . Texas',
        customerName: 'Riyaz Verma',
        customerAvatarInitial: 'R',
        buildingsCount: '2',
        status: 'Shipper File Received',
        statusType: ProjectStatusType.shipperFileReceived,
        projectValue: '\$12,500',
        chatCount: '2',
      ),
      ProjectItemModel(
        id: '4',
        projectName: 'MNP Warehouse',
        projectSubtitle: 'Workshop . Texas',
        customerName: 'Riya Wellness',
        customerAvatarInitial: 'R',
        buildingsCount: '1',
        status: 'Shipper File Received',
        statusType: ProjectStatusType.shipperFileReceived,
        projectValue: '\$12,500',
        chatCount: '2',
      ),
    ]);

    isLoading.value = false;
  }

  void toggleSelectAll(bool? val) {
    final newValue = val ?? false;
    selectAllRows.value = newValue;
    for (var item in projectItems) {
      item.isSelected = newValue;
    }
    projectItems.refresh();
  }

  void toggleRowSelect(int index) {
    projectItems[index].isSelected = !projectItems[index].isSelected;
    selectAllRows.value = projectItems.every((item) => item.isSelected);
    projectItems.refresh();
  }
}
