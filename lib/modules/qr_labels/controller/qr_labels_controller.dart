import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../model/qr_labels_model.dart';
import '../widgets/qr_code_dialog.dart';

class QrLabelsController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<ProjectQrLabelsSummaryModel> projectsList = <ProjectQrLabelsSummaryModel>[].obs;
  final RxList<BundleQrLabelItemModel> bundleLabelsList = <BundleQrLabelItemModel>[].obs;

  final RxString selectedProjectName = 'Project 1'.obs;
  final RxString selectedProjectFilter = 'Select Project'.obs;
  final RxString selectedSort = 'Latest'.obs;
  final RxString searchQuery = ''.obs;

  final List<String> availableProjects = [
    'ABC Warehouse',
    'Tech Park Dev',
    'Downtown Plaza',
    'Riverside Complex',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProjectsData();
    loadBundleLabelsData();
  }

  void loadProjectsData() {
    isLoading.value = true;
    projectsList.assignAll([
      ProjectQrLabelsSummaryModel(
        id: 'PRJ-001',
        projectName: 'ABC Warehouse',
        qrGeneratedDate: '22 Feb 2025',
        totalQrLabels: 5,
      ),
      ProjectQrLabelsSummaryModel(
        id: 'PRJ-002',
        projectName: 'Tech Park Dev',
        qrGeneratedDate: '07 Feb 2025',
        totalQrLabels: 3,
      ),
      ProjectQrLabelsSummaryModel(
        id: 'PRJ-003',
        projectName: 'Downtown Plaza',
        qrGeneratedDate: '30 Jan 2025',
        totalQrLabels: 2,
      ),
      ProjectQrLabelsSummaryModel(
        id: 'PRJ-004',
        projectName: 'Riverside Complex',
        qrGeneratedDate: '17 Jan 2025',
        totalQrLabels: 6,
      ),
      ProjectQrLabelsSummaryModel(
        id: 'PRJ-005',
        projectName: 'Tech Park Dev',
        qrGeneratedDate: '04 Jan 2025',
        totalQrLabels: 4,
      ),
      ProjectQrLabelsSummaryModel(
        id: 'PRJ-006',
        projectName: 'Downtown Plaza',
        qrGeneratedDate: '09 Dec 2024',
        totalQrLabels: 8,
      ),
    ]);
    isLoading.value = false;
  }

  void loadBundleLabelsData() {
    bundleLabelsList.assignAll([
      BundleQrLabelItemModel(
        bundleId: 'BND-101',
        loadId: 'LOAD-101',
        parts: 'STL-4135',
        weight: '18,500 IBS',
        length: '20 ft',
        status: 'Printed',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-102',
        loadId: 'LOAD-102',
        parts: 'STL-4135',
        weight: '37,700 IBS',
        length: '20 ft',
        status: 'Generated',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-103',
        loadId: 'LOAD-103',
        parts: 'STL-4135',
        weight: '21,400 IBS',
        length: '17 ft',
        status: 'Printed',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-104',
        loadId: 'LOAD-104',
        parts: 'STL-4135',
        weight: '18,500 IBS',
        length: '20 ft',
        status: 'Generated',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-105',
        loadId: 'LOAD-105',
        parts: 'STL-4135',
        weight: '37,700 IBS',
        length: '20 ft',
        status: 'Printed',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-106',
        loadId: 'LOAD-106',
        parts: 'STL-4135',
        weight: '21,400 IBS',
        length: '17 ft',
        status: 'Generated',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-107',
        loadId: 'LOAD-107',
        parts: 'STL-4135',
        weight: '18,500 IBS',
        length: '20 ft',
        status: 'Printed',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-108',
        loadId: 'LOAD-108',
        parts: 'STL-4135',
        weight: '37,700 IBS',
        length: '20 ft',
        status: 'Generated',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-109',
        loadId: 'LOAD-109',
        parts: 'STL-4135',
        weight: '18,500 IBS',
        length: '20 ft',
        status: 'Generated',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-110',
        loadId: 'LOAD-110',
        parts: 'STL-4135',
        weight: '37,700 IBS',
        length: '20 ft',
        status: 'Printed',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-111',
        loadId: 'LOAD-111',
        parts: 'STL-4135',
        weight: '21,400 IBS',
        length: '17 ft',
        status: 'Generated',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-112',
        loadId: 'LOAD-112',
        parts: 'STL-4135',
        weight: '18,500 IBS',
        length: '20 ft',
        status: 'Printed',
        shipper: 'SHP-1044',
      ),
      BundleQrLabelItemModel(
        bundleId: 'BND-113',
        loadId: 'LOAD-113',
        parts: 'STL-4135',
        weight: '37,700 IBS',
        length: '20 ft',
        status: 'Printed',
        shipper: 'SHP-1044',
      ),
    ]);
  }

  void openProjectQrLabels(ProjectQrLabelsSummaryModel item) {
    selectedProjectName.value = item.projectName;
    Get.toNamed(AppRoutes.projectQrLabels);
  }

  void showQrCodeDialog(BundleQrLabelItemModel item) {
    Get.dialog(
      QrCodeDialog(
        item: item,
        projectName: selectedProjectName.value.replaceAll(' ', ''),
      ),
      barrierDismissible: true,
    );
  }

  void selectProjectFilter(String project) {
    selectedProjectFilter.value = project;
  }

  void selectSort(String sort) {
    selectedSort.value = sort;
  }

  void toggleSelectAllProjects(bool? val) {
    final value = val ?? false;
    for (var item in projectsList) {
      item.isSelected = value;
    }
    projectsList.refresh();
  }

  void toggleSelectProject(int index, bool? val) {
    projectsList[index].isSelected = val ?? false;
    projectsList.refresh();
  }

  void toggleSelectAllBundles(bool? val) {
    final value = val ?? false;
    for (var item in bundleLabelsList) {
      item.isSelected = value;
    }
    bundleLabelsList.refresh();
  }

  void toggleSelectBundle(int index, bool? val) {
    bundleLabelsList[index].isSelected = val ?? false;
    bundleLabelsList.refresh();
  }
}
