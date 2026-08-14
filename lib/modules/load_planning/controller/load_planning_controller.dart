import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/repositories/workflow_repository.dart';
import '../model/load_planning_model.dart';
import '../repository/bundle_plan_repository.dart';
import '../repository/load_planning_repository.dart';

class LoadPlanningController extends GetxController {
  final LoadPlanningRepository repository;
  final WorkflowRepository workflowRepository;
  final BundlePlanRepository bundlePlanRepository;
  LoadPlanningController({
    required this.repository,
    required this.workflowRepository,
    required this.bundlePlanRepository,
  });

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ProjectLoadPlanningSummaryModel> projectsList =
      <ProjectLoadPlanningSummaryModel>[].obs;
  final RxList<LoadPlanItemModel> loadPlansList = <LoadPlanItemModel>[].obs;
  final RxString selectedProjectFilter = 'Select Project'.obs;
  final RxString selectedProjectId = ''.obs;
  final RxString selectedProjectName = ''.obs;
  final RxList<String> projectOptions = <String>[].obs;
  final RxString bundlePlanId = ''.obs;
  final RxMap<String, dynamic> bundlePlan = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> bundleCoverage = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> freightAutofill = <String, dynamic>{}.obs;
  List<String> get availableProjects => projectOptions;

  @override
  void onInit() {
    super.onInit();
    selectedProjectId.value = Get.parameters['id'] ?? '';
    selectedProjectName.value = Get.parameters['name'] ?? '';
    if (selectedProjectId.value.isEmpty) {
      loadProjectsData();
    } else {
      loadProjectLoadPlans(selectedProjectId.value);
    }
  }

  Future<void> loadProjectsData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.fetchProjects();
      final projects = data['projects'] is List
          ? data['projects'] as List
          : const [];
      projectsList.assignAll(
        projects.whereType<Map>().map((raw) {
          final item = Map<String, dynamic>.from(raw);
          final lead = _map(item['lead']);
          return ProjectLoadPlanningSummaryModel(
            id:
                (item['leadId'] ??
                        item['_id'] ??
                        lead['_id'] ??
                        item['projectId'] ??
                        '')
                    .toString(),
            projectName:
                (item['projectName'] ?? lead['projectName'] ?? 'Project')
                    .toString(),
            fileReceived: _date(
              item['fileReceivedAt'] ?? item['updatedAt'] ?? item['createdAt'],
            ),
            totalLoadPlanning: _int(
              item['totalLoadPlanning'] ??
                  item['planCount'] ??
                  item['loadPlanCount'],
            ),
          );
        }),
      );
      projectOptions.assignAll(
        projectsList.map((item) => item.projectName).toSet(),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      projectsList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProjectLoadPlans(String leadId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        repository.fetchProjectPlanning(leadId),
        workflowRepository.projectBundlePlan(leadId),
        workflowRepository.projectFreightAutofill(leadId),
      ]);
      final data = results[0];
      final legacy = _map(results[1]['bundlePlan'] ?? results[1]);
      freightAutofill.assignAll(results[2]);
      final bundlePlan = _map(data['bundlePlan'] ?? legacy);
      bundlePlanId.value =
          (bundlePlan['_id'] ?? bundlePlan['bundlePlanId'] ?? '').toString();
      if (bundlePlanId.value.isNotEmpty) {
        final planResults = await Future.wait([
          bundlePlanRepository.detail(bundlePlanId.value),
          bundlePlanRepository.coverage(bundlePlanId.value),
          bundlePlanRepository.freightAutofill(bundlePlanId.value),
        ]);
        this.bundlePlan.assignAll(planResults[0]);
        bundleCoverage.assignAll(planResults[1]);
        freightAutofill.addAll(planResults[2]);
      } else {
        this.bundlePlan.assignAll(bundlePlan);
      }
      final packingPlan = _map(data['packingListPlan']);
      final candidates =
          data['loadPlans'] ??
          data['plans'] ??
          packingPlan['trucks'] ??
          data['trucks'];
      final rows = candidates is List ? candidates : const [];
      loadPlansList.assignAll(
        rows.whereType<Map>().map((raw) {
          final item = Map<String, dynamic>.from(raw);
          final vendor = _map(item['vendor'] ?? bundlePlan['vendor']);
          final bundles = item['bundles'] is List
              ? item['bundles'] as List
              : const [];
          return LoadPlanItemModel(
            loadPlanId:
                (item['loadPlanId'] ?? item['_id'] ?? item['truckId'] ?? 'N/A')
                    .toString(),
            shipperReference:
                (item['shipperReference'] ??
                        item['reference'] ??
                        bundlePlan['reference'] ??
                        'N/A')
                    .toString(),
            vendorName: (item['vendorName'] ?? vendor['name'] ?? 'Vendor')
                .toString(),
            vendorAvatar: (vendor['photo'] ?? vendor['logo'] ?? '').toString(),
            bundles: _int(
              item['bundleCount'] ??
                  (bundles.isNotEmpty ? bundles.length : null),
            ),
            loads: _int(item['loadCount'] ?? item['loads'] ?? 1),
            weight: _weight(item['totalWeight'] ?? item['weight']),
            status: _status(
              item['status'] ?? packingPlan['status'] ?? bundlePlan['status'],
            ),
            date: _date(item['updatedAt'] ?? item['createdAt']),
          );
        }),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      loadPlansList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void openProjectLoadPlanning(ProjectLoadPlanningSummaryModel item) {
    Get.toNamed(
      AppRoutes.projectLoadPlanning,
      parameters: {'id': item.id, 'name': item.projectName},
    );
  }

  Future<void> updateBundlePlanNotes(String notes) async {
    if (bundlePlanId.value.isEmpty) return;
    final data = await bundlePlanRepository.update(bundlePlanId.value, {
      'notes': notes,
    });
    bundlePlan.addAll(data);
  }

  Future<void> createBundle({
    required String bundleType,
    required String title,
    String notes = '',
  }) async {
    if (bundlePlanId.value.isEmpty) return;
    await bundlePlanRepository.createBundle(bundlePlanId.value, {
      'bundleType': bundleType,
      'title': title,
      'notes': notes,
    });
    await loadProjectLoadPlans(selectedProjectId.value);
  }

  Future<void> confirmBundlePlan() async {
    if (bundlePlanId.value.isEmpty) return;
    await bundlePlanRepository.confirm(bundlePlanId.value);
    await loadProjectLoadPlans(selectedProjectId.value);
    Get.snackbar('Bundle plan confirmed', 'Load planning is ready.');
  }

  void showLoadDetails(LoadPlanItemModel item) {
    final weight = freightAutofill['weight'] ?? item.weight;
    final packages = freightAutofill['packageCount'] ?? item.bundles;
    Get.defaultDialog(
      title: item.loadPlanId,
      middleText: 'Weight: $weight\nPackages: $packages',
      textConfirm: 'Close',
      onConfirm: Get.back,
    );
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  String _weight(dynamic value) =>
      value == null ? '0 lbs' : '${value.toString()} lbs';
  String _status(dynamic value) {
    final text = (value ?? 'Planning').toString().replaceAll('_', ' ');
    return text
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString())?.toLocal();
    if (date == null) return 'N/A';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  void selectProjectFilter(String project) =>
      selectedProjectFilter.value = project;
  void toggleSelectAllProjects(bool? val) {
    for (final item in projectsList) {
      item.isSelected = val ?? false;
    }
    projectsList.refresh();
  }

  void toggleSelectProject(int index, bool? val) {
    projectsList[index].isSelected = val ?? false;
    projectsList.refresh();
  }

  void toggleSelectAllLoadPlans(bool? val) {
    for (final item in loadPlansList) {
      item.isSelected = val ?? false;
    }
    loadPlansList.refresh();
  }

  void toggleSelectLoadPlan(int index, bool? val) {
    loadPlansList[index].isSelected = val ?? false;
    loadPlansList.refresh();
  }
}
