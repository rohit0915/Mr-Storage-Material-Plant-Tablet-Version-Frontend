import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../model/packing_list_model.dart';
import '../repository/packing_list_repository.dart';

class PackingListController extends GetxController {
  final PackingListRepository repository;
  PackingListController({required this.repository});

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ProjectPackingListSummaryModel> projectsList =
      <ProjectPackingListSummaryModel>[].obs;
  final RxList<PackingListItemModel> packingItemsList =
      <PackingListItemModel>[].obs;
  final RxList<PackingListTableItemModel> packingListTableItems =
      <PackingListTableItemModel>[].obs;
  final RxList<BundleListItemModel> bundleListItems =
      <BundleListItemModel>[].obs;
  final RxString selectedProjectId = ''.obs;
  final RxString selectedProjectName = ''.obs;
  final RxString selectedProjectFilter = 'Select Project'.obs;
  final RxList<String> projectOptions = <String>[].obs;
  List<String> get availableProjects => projectOptions;

  final searchQuery = ''.obs;
  final currentPage = 1.obs, rowsPerPage = 10.obs, totalProjects = 0.obs;
  Worker? _searchWorker;
  int _generation = 0;
  int get totalPages =>
      (totalProjects.value / rowsPerPage.value).ceil().clamp(1, 1000000);
  void changePage(int value) {
    currentPage.value = value;
    loadProjectsData();
  }

  void changeRows(int value) {
    rowsPerPage.value = value;
    changePage(1);
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _searchWorker = debounce(
      searchQuery,
      (_) => changePage(1),
      time: const Duration(milliseconds: 350),
    );
    selectedProjectId.value = Get.parameters['id'] ?? '';
    selectedProjectName.value = Get.parameters['name'] ?? '';
    if (selectedProjectId.value.isEmpty) {
      loadProjectsData();
    } else {
      loadPackingDetailsData(selectedProjectId.value);
    }
  }

  Future<void> loadProjectsData() async {
    final request = ++_generation;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.fetchProjects(
        page: currentPage.value,
        limit: rowsPerPage.value,
        search: searchQuery.value,
      );
      if (request != _generation) return;
      totalProjects.value = _int(data['total']);
      final projects = data['projects'] is List
          ? data['projects'] as List
          : const [];
      projectsList.assignAll(
        projects.whereType<Map>().toList().asMap().entries.map((entry) {
          final item = Map<String, dynamic>.from(entry.value);
          final lead = _map(item['lead']);
          final pName =
              (item['projectName'] ?? lead['projectName'] ?? 'Project')
                  .toString();
          String rawCode =
              (item['projectId'] ??
                      item['jobId'] ??
                      item['job_id'] ??
                      item['projectCode'] ??
                      item['projectNo'] ??
                      item['projectNumber'] ??
                      '')
                  .toString();
          final rawTotal = _int(
            item['totalPackingList'] ??
                item['totalPackingLists'] ??
                item['packingListCount'] ??
                item['totalLists'],
          );
          return ProjectPackingListSummaryModel(
            id:
                (item['packingListPlanId'] ??
                        item['leadId'] ??
                        lead['_id'] ??
                        item['projectId'] ??
                        item['packingListPlanId'] ??
                        item['packingListId'] ??
                        item['_id'] ??
                        '')
                    .toString(),
            displayProjectId: rawCode,
            projectName: pName,
            listGeneratedDate: _date(
              item['listGeneratedAt'] ??
                  item['generatedAt'] ??
                  item['updatedAt'] ??
                  item['createdAt'],
            ),
            totalPackingList: rawTotal,
          );
        }),
      );
      projectOptions.assignAll(
        projectsList.map((item) => item.projectName).toSet(),
      );
    } catch (e) {
      if (request != _generation) return;
      errorMessage.value = e.toString();
      projectsList.clear();
      totalProjects.value = 0;
    } finally {
      if (request == _generation) isLoading.value = false;
    }
  }

  void initProjectPackingList(String id, String name) {
    if (id.isEmpty) return;
    if (selectedProjectId.value != id || packingItemsList.isEmpty) {
      selectedProjectId.value = id;
      if (name.isNotEmpty) selectedProjectName.value = name;
      loadPackingDetailsData(id);
    }
  }

  Future<void> loadPackingDetailsData(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.fetchPackingListPlan(id);
      final plan = _map(data['packingListPlan']);
      final project = _map(data['project']);
      selectedProjectName.value =
          project['projectName']?.toString() ?? selectedProjectName.value;
      final rows = data['packingLists'] as List? ?? [];
      packingItemsList.assignAll(
        rows.whereType<Map>().map((item) {
          final rawBundles = item['bundles'] as List? ?? [];
          final bundles = rawBundles
              .whereType<Map>()
              .toList()
              .asMap()
              .entries
              .map((entry) {
                final row = entry.value;
                return BundleListItemModel(
                  id: entry.key,
                  bundleId: (row['bundleNo'] ?? row['_id'] ?? '').toString(),
                  profile: (row['bundleType'] ?? '').toString(),
                  partNumber: (row['title'] ?? '').toString(),
                  items:
                      (row['items'] is List ? (row['items'] as List).length : 0)
                          .toString(),
                  quantity: _int(row['totalQty']),
                  length: (row['maxLengthFeet'] ?? '—').toString(),
                  unitWeight: _weight(row['totalWeight']),
                  status: (row['status'] ?? '—').toString(),
                );
              })
              .toList();
          final projectCode = (item['projectId'] ??
                  item['jobId'] ??
                  item['job_id'] ??
                  item['projectCode'] ??
                  item['projectNo'] ??
                  item['projectNumber'] ??
                  project['projectId'] ??
                  project['jobId'] ??
                  project['job_id'] ??
                  project['projectCode'] ??
                  project['projectNo'] ??
                  project['projectNumber'] ??
                  '')
              .toString();
          return PackingListItemModel(
            packingId: projectCode.isNotEmpty
                ? projectCode
                : (item['_id'] ?? '').toString(),
            loadId: (item['packingListNo'] ?? '').toString(),
            truck: (item['truckLabel'] ?? item['truckType'] ?? '—').toString(),
            bundles: _int(item['totalBundles']),
            weight: _weight(item['totalWeight']),
            destination: (project['location'] ?? '—').toString(),
            date: _date(plan['createdAt']),
            status: (item['status'] ?? '—').toString(),
            totalItems: _int(item['totalItems']),
            bundleList: bundles,
            rawData: Map<String, dynamic>.from(item),
          );
        }),
      );
      final selectedPackingId = Get.parameters['packingId'];
      if (selectedPackingId != null) {
        final selected = packingItemsList.where(
          (item) => item.packingId == selectedPackingId,
        );
        bundleListItems.assignAll(
          selected.isEmpty
              ? <BundleListItemModel>[]
              : selected.first.bundleList,
        );
      }
      packingListTableItems.assignAll(
        packingItemsList.asMap().entries.map(
          (entry) => PackingListTableItemModel(
            id: entry.key,
            loadId: entry.value.loadId,
            truck: entry.value.truck,
            bundles: entry.value.bundles,
            weight: entry.value.weight,
            destination: entry.value.destination,
            status: entry.value.status,
          ),
        ),
      );
    } catch (e) {
      packingItemsList.clear();
      packingListTableItems.clear();
      bundleListItems.clear();
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openProjectPackingList(
    ProjectPackingListSummaryModel item,
  ) async {
    selectedProjectId.value = item.id;
    selectedProjectName.value = item.projectName;
    packingItemsList.clear();
    packingListTableItems.clear();
    bundleListItems.clear();
    errorMessage.value = '';
    isLoading.value = true;
    Get.toNamed(
      AppRoutes.projectPackingList,
      parameters: {'id': item.id, 'name': item.projectName},
    );
    await loadPackingDetailsData(item.id);
  }

  Future<void> openPackingListDetails(PackingListItemModel item) async {
    bundleListItems.assignAll(item.bundleList);
    errorMessage.value = '';
    Get.toNamed(
      AppRoutes.packingListDetails,
      parameters: {
        'id': selectedProjectId.value,
        'packingId': item.packingId,
        'name': selectedProjectName.value,
      },
    );
  }

  Future<void> exportProjects() async {
    await _saveCsv(
      fileName: 'packing_list_projects',
      rows: [
        const ['Project Name', 'Generated Date', 'Total Packing Lists'],
        ...projectsList.map(
          (item) => [
            item.projectName,
            item.listGeneratedDate,
            item.totalPackingList,
          ],
        ),
      ],
    );
  }

  Future<void> exportPackingLists() async {
    await _saveCsv(
      fileName: 'packing_list_${_safeName(selectedProjectName.value)}',
      rows: [
        const [
          'Packing ID',
          'Load ID',
          'Truck',
          'Bundles',
          'Weight',
          'Destination',
          'Date',
          'Status',
        ],
        ...packingItemsList.map(
          (item) => [
            item.packingId,
            item.loadId,
            item.truck,
            item.bundles,
            item.weight,
            item.destination,
            item.date,
            item.status,
          ],
        ),
      ],
    );
  }

  Future<void> exportBundlesCsv() async {
    await _saveCsv(
      fileName: 'bundle_list_${_safeName(selectedProjectName.value)}',
      rows: [
        const ['Bundle ID', 'Profile', 'Items', 'Length', 'Unit Weight'],
        ...bundleListItems.map(
          (item) => [
            item.bundleId,
            item.profile,
            item.items,
            item.length,
            item.unitWeight,
          ],
        ),
      ],
    );
  }

  Future<void> downloadPackingPdf() async {
    try {
      final bytes = await FileExportService.tablePdf(
        title: 'Packing List',
        subtitle: selectedProjectName.value,
        headers: const [
          'Load ID',
          'Truck',
          'Bundles',
          'Weight',
          'Destination',
          'Status',
        ],
        rows: packingListTableItems
            .map(
              (item) => [
                item.loadId,
                item.truck,
                item.bundles,
                item.weight,
                item.destination,
                item.status,
              ],
            )
            .toList(),
      );
      await FileExportService.savePdf(
        fileName: 'packing_list_${_safeName(selectedProjectName.value)}',
        bytes: bytes,
      );
      CommonSnackbar.showSuccess(
        title: 'Download complete',
        message: 'Packing list PDF was created.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Download failed',
        message: error.toString(),
      );
    }
  }

  Future<void> _saveCsv({
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

  String _safeName(String value) => value.trim().isEmpty
      ? 'export'
      : value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  String _weight(dynamic value) =>
      value == null ? '—' : '${value.toString()} lbs';

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

  void toggleSelectAllPackingItems(bool? val) {
    for (final item in packingItemsList) {
      item.isSelected = val ?? false;
    }
    packingItemsList.refresh();
  }

  void toggleSelectPackingItem(int index, bool? val) {
    packingItemsList[index].isSelected = val ?? false;
    packingItemsList.refresh();
  }
}
