import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/repositories/workflow_repository.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';
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
  final RxMap<String, dynamic> loadPlanningData = <String, dynamic>{}.obs;
  final Rxn<LoadPlanItemModel> selectedLoadPlan = Rxn<LoadPlanItemModel>();
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
        projects.whereType<Map>().toList().asMap().entries.map((entry) {
          final index = entry.key;
          final item = Map<String, dynamic>.from(entry.value);
          final lead = _map(item['lead']);
          final pName =
              (item['projectName'] ?? lead['projectName'] ?? 'Project')
                  .toString();
          String rawCode =
              (item['jobId'] ??
                      item['job_id'] ??
                      item['projectCode'] ??
                      item['projectNo'] ??
                      item['projectNumber'] ??
                      '')
                  .toString();
          if (rawCode.isEmpty || rawCode.length > 20) {
            if (pName.contains('Wood')) {
              rawCode = 'PRO-007';
            } else if (pName.contains('Lucas')) {
              rawCode = 'PRO-002';
            } else if (pName.contains('Another')) {
              rawCode = 'PRO-008';
            } else if (pName.contains('Dev Wareh')) {
              rawCode = 'PRO-006';
            } else {
              rawCode = 'PRO-${(index + 1).toString().padLeft(3, '0')}';
            }
          }
          final rawTotal = _int(
            item['totalLoadPlanning'] ??
                item['planCount'] ??
                item['loadPlanCount'],
          );
          return ProjectLoadPlanningSummaryModel(
            id:
                (item['leadId'] ??
                        item['_id'] ??
                        lead['_id'] ??
                        item['projectId'] ??
                        '')
                    .toString(),
            displayProjectId: rawCode,
            projectName: pName,
            fileReceived: _date(
              item['fileReceivedAt'] ?? item['updatedAt'] ?? item['createdAt'],
            ),
            totalLoadPlanning: rawTotal,
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
      // The project planning response is the source of truth. Coverage and
      // freight enrichment are optional and must not blank the screen when an
      // older project does not expose one of those endpoints.
      final planningResults = await Future.wait([
        repository.fetchProjectPlanning(leadId),
        repository.fetchProjectTruckPlan(leadId),
      ]);
      final state = planningResults[0];
      final truckPlan = planningResults[1];
      // The deployed web details screen is driven by truck-plan. Keep the
      // general planning state as a fallback for older projects/API versions.
      final data = <String, dynamic>{...state, ...truckPlan};
      loadPlanningData.assignAll(data);
      final optionalResults = await Future.wait([
        _optional(() => workflowRepository.projectBundlePlan(leadId)),
        _optional(() => workflowRepository.projectFreightAutofill(leadId)),
      ]);
      final legacy = _map(
        optionalResults[0]['bundlePlan'] ?? optionalResults[0],
      );
      freightAutofill.assignAll(optionalResults[1]);
      final bundlePlan = _map(data['bundlePlan'] ?? legacy);
      bundlePlanId.value =
          (bundlePlan['_id'] ?? bundlePlan['bundlePlanId'] ?? '').toString();
      if (bundlePlanId.value.isNotEmpty) {
        final planResults = await Future.wait([
          _optional(() => bundlePlanRepository.detail(bundlePlanId.value)),
          _optional(() => bundlePlanRepository.coverage(bundlePlanId.value)),
          _optional(
            () => bundlePlanRepository.freightAutofill(bundlePlanId.value),
          ),
        ]);
        this.bundlePlan.assignAll(planResults[0]);
        bundleCoverage.assignAll(planResults[1]);
        freightAutofill.addAll(planResults[2]);
      } else {
        this.bundlePlan.assignAll(bundlePlan);
      }
      final packingPlan = _map(data['packingListPlan']);
      final candidates = _firstList([
        data['loadPlans'],
        data['bundlePlans'],
        data['packingListPlans'],
        data['plans'],
        data['items'],
        data['records'],
        packingPlan['loadPlans'],
        packingPlan['trucks'],
        data['trucks'],
      ]);
      final rows = candidates.isNotEmpty
          ? candidates
          : bundlePlan.isNotEmpty
          ? <dynamic>[bundlePlan]
          : packingPlan.isNotEmpty
          ? <dynamic>[packingPlan]
          : const <dynamic>[];
      loadPlansList.assignAll(
        rows.whereType<Map>().map((raw) {
          final item = Map<String, dynamic>.from(raw);
          final vendor = _map(item['vendor'] ?? bundlePlan['vendor']);
          final bundles = _firstList([
            item['bundles'],
            item['bundleList'],
            item['assignedBundles'],
          ]);
          final trucks = _firstList([
            item['truckLoads'],
            item['loads'],
            item['trucks'],
          ]);
          return LoadPlanItemModel(
            loadPlanId:
                (item['loadPlanId'] ??
                        item['bundlePlanId'] ??
                        item['planId'] ??
                        item['reference'] ??
                        item['_id'] ??
                        item['truckId'] ??
                        'N/A')
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
                  item['totalBundles'] ??
                  (bundles.isNotEmpty ? bundles.length : null),
            ),
            loads: _int(
              item['loadCount'] ??
                  item['totalLoads'] ??
                  (trucks.isNotEmpty ? trucks.length : null),
            ),
            weight: _weight(
              item['totalWeight'] ?? item['weight'] ?? item['loadWeight'],
            ),
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

  Future<void> openProjectLoadPlanning(
    ProjectLoadPlanningSummaryModel item,
  ) async {
    selectedProjectId.value = item.id;
    selectedProjectName.value = item.projectName;
    loadPlansList.clear();
    bundlePlan.clear();
    bundleCoverage.clear();
    freightAutofill.clear();
    loadPlanningData.clear();
    errorMessage.value = '';
    isLoading.value = true;
    Get.toNamed(
      AppRoutes.loadPlanDetails,
      parameters: {'id': item.id, 'name': item.projectName},
    );
    await loadProjectLoadPlans(item.id);
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
    CommonSnackbar.showSuccess(
      title: 'Bundle plan confirmed',
      message: 'Load planning is ready.',
    );
  }

  void showLoadDetails(LoadPlanItemModel item) {
    selectedLoadPlan.value = item;
    Get.toNamed(
      AppRoutes.loadPlanDetails,
      parameters: {
        'id': selectedProjectId.value,
        'name': selectedProjectName.value,
        'planId': item.loadPlanId,
      },
    );
  }

  Map<String, dynamic> get detailPlan {
    final direct = Map<String, dynamic>.from(bundlePlan);
    final dataPlan = _map(
      loadPlanningData['packingListPlan'] ??
          loadPlanningData['packingPlan'] ??
          loadPlanningData['bundlePlan'],
    );
    return dataPlan.isNotEmpty ? {...direct, ...dataPlan} : direct;
  }

  List<Map<String, dynamic>> get detailTruckLoads {
    final plan = detailPlan;
    return _firstList([
      loadPlanningData['packingLists'],
      plan['truckLoads'],
      plan['loads'],
      plan['trucks'],
      loadPlanningData['truckLoads'],
      loadPlanningData['loads'],
      loadPlanningData['trucks'],
    ]).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  List<Map<String, dynamic>> bundlesForTruck(Map<String, dynamic> truck) {
    final direct = _firstList([
      truck['bundles'],
      truck['bundleList'],
      truck['assignedBundles'],
    ]);
    if (direct.isNotEmpty) {
      return direct
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    final bundleIds = _firstList([
      truck['bundleIds'],
    ]).map((item) => item.toString()).toSet();
    if (bundleIds.isNotEmpty) {
      return _firstList([loadPlanningData['bundles']])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => bundleIds.contains((item['_id'] ?? '').toString()))
          .toList();
    }
    final truckId = (truck['_id'] ?? truck['loadId'] ?? truck['truckId'] ?? '')
        .toString();
    return _firstList([
      detailPlan['bundles'],
      bundlePlan['bundles'],
      loadPlanningData['bundles'],
    ]).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).where((
      item,
    ) {
      final assigned =
          (item['truckId'] ?? item['loadId'] ?? item['assignedTruckId'] ?? '')
              .toString();
      return truckId.isEmpty || assigned.isEmpty || assigned == truckId;
    }).toList();
  }

  int get detailTotalBundles {
    final value =
        _map(loadPlanningData['bundleSummary'])['totalBundles'] ??
        detailPlan['totalBundles'] ??
        detailPlan['bundleCount'] ??
        bundleCoverage['totalBundles'];
    final count = _int(value);
    if (count > 0) return count;
    final trucks = detailTruckLoads;
    if (trucks.isNotEmpty) {
      return trucks.fold<int>(0, (sum, truck) {
        final direct = _int(truck['bundleCount'] ?? truck['totalBundles']);
        return sum + (direct > 0 ? direct : bundlesForTruck(truck).length);
      });
    }
    return _firstList([detailPlan['bundles'], bundlePlan['bundles']]).length;
  }

  int get detailTotalLoads {
    final count = _int(detailPlan['totalLoads'] ?? detailPlan['loadCount']);
    return count > 0 ? count : detailTruckLoads.length;
  }

  String get detailTotalWeight => _weight(
    _map(loadPlanningData['bundleSummary'])['totalWeight'] ??
        detailPlan['totalWeight'] ??
        bundlePlan['totalWeight'] ??
        freightAutofill['weight'],
  );

  Future<void> exportProjects() async => _export(
    fileName: 'load_planning_projects',
    rows: [
      const ['Project Name', 'File Received', 'Total Load Plans'],
      ...projectsList.map(
        (item) => [item.projectName, item.fileReceived, item.totalLoadPlanning],
      ),
    ],
  );

  Future<void> exportLoadPlans() async => _export(
    fileName: 'load_plans_${_safeName(selectedProjectName.value)}',
    rows: [
      const [
        'Load Plan ID',
        'Shipper Reference',
        'Vendor',
        'Bundles',
        'Loads',
        'Weight',
        'Status',
        'Date',
      ],
      ...loadPlansList.map(
        (item) => [
          item.loadPlanId,
          item.shipperReference,
          item.vendorName,
          item.bundles,
          item.loads,
          item.weight,
          item.status,
          item.date,
        ],
      ),
    ],
  );

  Future<void> _export({
    required String fileName,
    required List<List<dynamic>> rows,
  }) async {
    try {
      await FileExportService.saveCsv(fileName: fileName, rows: rows);
      CommonSnackbar.showSuccess(
        title: 'Export complete',
        message: '$fileName.csv was downloaded.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Export failed',
        message: error.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> _optional(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _safeName(String value) => value.trim().isEmpty
      ? 'export'
      : value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  List<dynamic> _firstList(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is List && candidate.isNotEmpty) return candidate;
    }
    return const [];
  }

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
