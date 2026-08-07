import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../model/packing_list_model.dart';

class PackingListController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<ProjectPackingListSummaryModel> projectsList = <ProjectPackingListSummaryModel>[].obs;
  final RxList<PackingListItemModel> packingItemsList = <PackingListItemModel>[].obs;
  final RxList<PackingListTableItemModel> packingListTableItems = <PackingListTableItemModel>[].obs;
  final RxList<BundleListItemModel> bundleListItems = <BundleListItemModel>[].obs;

  final RxString selectedProjectName = 'Project 2'.obs;
  final RxString selectedProjectFilter = 'Select Project'.obs;

  final List<String> availableProjects = [
    'ABC Construction',
    'XYZ Construction',
    'PQR Construction',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProjectsData();
    loadPackingItemsData();
    loadPackingDetailsData();
  }

  void loadProjectsData() {
    isLoading.value = true;
    projectsList.assignAll([
      ProjectPackingListSummaryModel(id: 'PRJ-001', projectName: 'ABC Warehouse', listGeneratedDate: '22 Feb 2025', totalPackingList: 5),
      ProjectPackingListSummaryModel(id: 'PRJ-002', projectName: 'Tech Park Dev', listGeneratedDate: '07 Feb 2025', totalPackingList: 3),
      ProjectPackingListSummaryModel(id: 'PRJ-003', projectName: 'Downtown Plaza', listGeneratedDate: '30 Jan 2025', totalPackingList: 2),
      ProjectPackingListSummaryModel(id: 'PRJ-004', projectName: 'Riverside Complex', listGeneratedDate: '17 Jan 2025', totalPackingList: 6),
      ProjectPackingListSummaryModel(id: 'PRJ-005', projectName: 'Tech Park Dev', listGeneratedDate: '04 Jan 2025', totalPackingList: 4),
      ProjectPackingListSummaryModel(id: 'PRJ-006', projectName: 'Downtown Plaza', listGeneratedDate: '09 Dec 2024', totalPackingList: 8),
    ]);
    isLoading.value = false;
  }

  void loadPackingItemsData() {
    packingItemsList.assignAll([
      PackingListItemModel(packingId: 'PKL-101', loadId: 'LOAD-101', truck: 'TX-4135', bundles: 5, weight: '18,500 IBS', destination: 'Site A', date: '22 Feb 2025', status: 'Dispatched'),
      PackingListItemModel(packingId: 'PKL-102', loadId: 'LOAD-102', truck: 'TX-4135', bundles: 8, weight: '37,700 IBS', destination: 'Site A', date: '07 Feb 2025', status: 'Ready'),
      PackingListItemModel(packingId: 'PKL-103', loadId: 'LOAD-103', truck: 'TX-4135', bundles: 6, weight: '21,400 IBS', destination: 'Site B', date: '30 Jan 2025', status: 'Dispatched'),
      PackingListItemModel(packingId: 'PKL-104', loadId: 'LOAD-104', truck: 'TX-4135', bundles: 5, weight: '18,500 IBS', destination: 'Site A', date: '17 Jan 2025', status: 'Ready'),
      PackingListItemModel(packingId: 'PKL-105', loadId: 'LOAD-105', truck: 'TX-4135', bundles: 8, weight: '37,700 IBS', destination: 'Site A', date: '04 Jan 2025', status: 'Dispatched'),
      PackingListItemModel(packingId: 'PKL-106', loadId: 'LOAD-106', truck: 'TX-4135', bundles: 6, weight: '21,400 IBS', destination: 'Site B', date: '09 Dec 2024', status: 'Ready'),
      PackingListItemModel(packingId: 'PKL-107', loadId: 'LOAD-107', truck: 'TX-4135', bundles: 3, weight: '18,500 IBS', destination: 'Site A', date: '02 Dec 2024', status: 'Dispatched'),
      PackingListItemModel(packingId: 'PKL-108', loadId: 'LOAD-108', truck: 'TX-4135', bundles: 4, weight: '37,700 IBS', destination: 'Site A', date: '15 Nov 2024', status: 'Ready'),
    ]);
  }

  void loadPackingDetailsData() {
    packingListTableItems.assignAll([
      PackingListTableItemModel(id: 1, loadId: 'LOAD-001', truck: 'TX-2141', bundles: 3, weight: '36000 IBS', destination: 'Riverside Site A', status: 'Ready'),
      PackingListTableItemModel(id: 2, loadId: 'LOAD-002', truck: 'TX-4712', bundles: 2, weight: '45500 IBS', destination: 'Riverside Site A', status: 'Ready'),
    ]);

    bundleListItems.assignAll([
      BundleListItemModel(id: 1, bundleId: 'BND-001', profile: 'Beam', items: 'STL-B12 × 30', length: '20 ft', unitWeight: '3600 IBS'),
      BundleListItemModel(id: 2, bundleId: 'BND-002', profile: 'Angle', items: 'STL-B12 × 30', length: '12 ft', unitWeight: '2400 IBS'),
      BundleListItemModel(id: 3, bundleId: 'BND-003', profile: 'Channel', items: 'STL-B12 × 30', length: '15 ft', unitWeight: '4500 IBS'),
      BundleListItemModel(id: 4, bundleId: 'BND-004', profile: 'Beam', items: 'STL-B12 × 30', length: '20 ft', unitWeight: '2700 IBS'),
    ]);
  }

  void openProjectPackingList(ProjectPackingListSummaryModel item) {
    selectedProjectName.value = item.projectName;
    Get.toNamed(AppRoutes.projectPackingList);
  }

  void openPackingListDetails(PackingListItemModel item) {
    Get.toNamed(AppRoutes.packingListDetails);
  }

  void selectProjectFilter(String project) {
    selectedProjectFilter.value = project;
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

  void toggleSelectAllPackingItems(bool? val) {
    final value = val ?? false;
    for (var item in packingItemsList) {
      item.isSelected = value;
    }
    packingItemsList.refresh();
  }

  void toggleSelectPackingItem(int index, bool? val) {
    packingItemsList[index].isSelected = val ?? false;
    packingItemsList.refresh();
  }
}
