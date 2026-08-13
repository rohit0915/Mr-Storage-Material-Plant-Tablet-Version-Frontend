import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../model/load_planning_model.dart';
import '../repository/load_planning_repository.dart';

class LoadPlanningController extends GetxController {
  final LoadPlanningRepository repository;
  LoadPlanningController({required this.repository});

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ProjectLoadPlanningSummaryModel> projectsList =
      <ProjectLoadPlanningSummaryModel>[].obs;
  final RxList<LoadPlanItemModel> loadPlansList = <LoadPlanItemModel>[].obs;
  final RxString selectedProjectFilter = 'Select Project'.obs;
  final RxString selectedProjectId = ''.obs;
  final RxString selectedProjectName = ''.obs;
  final RxList<String> projectOptions = <String>[].obs;
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
      final data = await repository.fetchProjectPlanning(leadId);
      final bundlePlan = _map(data['bundlePlan']);
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
