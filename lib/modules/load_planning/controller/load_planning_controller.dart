import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../model/load_planning_model.dart';

class LoadPlanningController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<ProjectLoadPlanningSummaryModel> projectsList = <ProjectLoadPlanningSummaryModel>[].obs;
  final RxList<LoadPlanItemModel> loadPlansList = <LoadPlanItemModel>[].obs;
  final RxString selectedProjectFilter = 'Select Project'.obs;
  final RxString selectedProjectName = 'Project 1'.obs;

  final List<String> availableProjects = [
    'ABC Construction',
    'XYZ Construction',
    'PQR Construction',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProjectsData();
    loadProjectLoadPlans();
  }

  void loadProjectsData() {
    isLoading.value = true;
    projectsList.assignAll([
      ProjectLoadPlanningSummaryModel(id: 'PRJ-001', projectName: 'ABC Warehouse', fileReceived: '22 Feb 2025', totalLoadPlanning: 5),
      ProjectLoadPlanningSummaryModel(id: 'PRJ-002', projectName: 'Tech Park Dev', fileReceived: '07 Feb 2025', totalLoadPlanning: 3),
      ProjectLoadPlanningSummaryModel(id: 'PRJ-003', projectName: 'Downtown Plaza', fileReceived: '30 Jan 2025', totalLoadPlanning: 2),
      ProjectLoadPlanningSummaryModel(id: 'PRJ-004', projectName: 'Riverside Complex', fileReceived: '17 Jan 2025', totalLoadPlanning: 6),
      ProjectLoadPlanningSummaryModel(id: 'PRJ-005', projectName: 'Tech Park Dev', fileReceived: '04 Jan 2025', totalLoadPlanning: 4),
      ProjectLoadPlanningSummaryModel(id: 'PRJ-006', projectName: 'Downtown Plaza', fileReceived: '09 Dec 2024', totalLoadPlanning: 8),
    ]);
    isLoading.value = false;
  }

  void loadProjectLoadPlans() {
    loadPlansList.assignAll([
      LoadPlanItemModel(loadPlanId: 'LP-2026-001', shipperReference: 'SHP-1044', vendorName: 'ABC Steel', vendorAvatar: '', bundles: 5, loads: 2, weight: '18,500 IBS', status: 'Completed', date: '22 Feb 2025'),
      LoadPlanItemModel(loadPlanId: 'LP-2026-002', shipperReference: 'SHP-1045', vendorName: 'Steel Works LTD', vendorAvatar: '', bundles: 8, loads: 3, weight: '37,700 IBS', status: 'Planning', date: '07 Feb 2025'),
      LoadPlanItemModel(loadPlanId: 'LP-2026-003', shipperReference: 'SHP-1046', vendorName: 'Metro Steel', vendorAvatar: '', bundles: 6, loads: 2, weight: '21,400 IBS', status: 'Ready', date: '30 Jan 2025'),
      LoadPlanItemModel(loadPlanId: 'LP-2026-004', shipperReference: 'SHP-1047', vendorName: 'ABC Steel', vendorAvatar: '', bundles: 5, loads: 2, weight: '18,500 IBS', status: 'Completed', date: '17 Jan 2025'),
      LoadPlanItemModel(loadPlanId: 'LP-2026-005', shipperReference: 'SHP-1048', vendorName: 'Steel Works LTD', vendorAvatar: '', bundles: 8, loads: 2, weight: '37,700 IBS', status: 'Planning', date: '04 Jan 2025'),
      LoadPlanItemModel(loadPlanId: 'LP-2026-006', shipperReference: 'SHP-1049', vendorName: 'Metro Steel', vendorAvatar: '', bundles: 6, loads: 3, weight: '21,400 IBS', status: 'Ready', date: '09 Dec 2024'),
      LoadPlanItemModel(loadPlanId: 'LP-2026-007', shipperReference: 'SHP-1050', vendorName: 'ABC Steel', vendorAvatar: '', bundles: 3, loads: 3, weight: '18,500 IBS', status: 'Completed', date: '02 Dec 2024'),
      LoadPlanItemModel(loadPlanId: 'LP-2026-008', shipperReference: 'SHP-1051', vendorName: 'Steel Works LTD', vendorAvatar: '', bundles: 4, loads: 3, weight: '37,700 IBS', status: 'Planning', date: '15 Nov 2024'),
      LoadPlanItemModel(loadPlanId: 'LP-2026-009', shipperReference: 'SHP-1052', vendorName: 'Metro Steel', vendorAvatar: '', bundles: 2, loads: 2, weight: '21,400 IBS', status: 'Ready', date: '30 Nov 2024'),
      LoadPlanItemModel(loadPlanId: 'LP-2026-010', shipperReference: 'SHP-1053', vendorName: 'ABC Steel', vendorAvatar: '', bundles: 4, loads: 3, weight: '18,500 IBS', status: 'Completed', date: '12 Oct 2024'),
    ]);
  }

  void openProjectLoadPlanning(ProjectLoadPlanningSummaryModel item) {
    selectedProjectName.value = item.projectName;
    Get.toNamed(AppRoutes.projectLoadPlanning);
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

  void toggleSelectAllLoadPlans(bool? val) {
    final value = val ?? false;
    for (var item in loadPlansList) {
      item.isSelected = value;
    }
    loadPlansList.refresh();
  }

  void toggleSelectLoadPlan(int index, bool? val) {
    loadPlansList[index].isSelected = val ?? false;
    loadPlansList.refresh();
  }
}
