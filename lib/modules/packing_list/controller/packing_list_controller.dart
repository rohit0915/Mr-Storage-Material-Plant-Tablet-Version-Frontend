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

  @override
  void onInit() {
    super.onInit();
    selectedProjectId.value = Get.parameters['id'] ?? '';
    selectedProjectName.value = Get.parameters['name'] ?? '';
    if (selectedProjectId.value.isEmpty) {
      loadProjectsData();
    } else {
      loadPackingDetailsData(selectedProjectId.value);
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
          return ProjectPackingListSummaryModel(
            id:
                (item['packingListId'] ??
                        item['packingListPlanId'] ??
                        item['leadId'] ??
                        item['_id'] ??
                        lead['_id'] ??
                        '')
                    .toString(),
            projectName:
                (item['projectName'] ?? lead['projectName'] ?? 'Project')
                    .toString(),
            listGeneratedDate: _date(
              item['generatedAt'] ?? item['updatedAt'] ?? item['createdAt'],
            ),
            totalPackingList: _int(
              item['totalPackingLists'] ??
                  item['packingListCount'] ??
                  item['totalLists'],
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

  Future<void> loadPackingDetailsData(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.fetchPackingList(id);
      final trucks = data['trucks'] is List ? data['trucks'] as List : [data];
      packingItemsList.assignAll(
        trucks.whereType<Map>().map((raw) {
          final item = Map<String, dynamic>.from(raw);
          final bundles = item['bundles'] is List
              ? item['bundles'] as List
              : const [];
          return PackingListItemModel(
            packingId:
                (item['packingId'] ?? item['_id'] ?? data['_id'] ?? 'N/A')
                    .toString(),
            loadId:
                (item['loadId'] ??
                        item['truckId'] ??
                        item['truckNumber'] ??
                        'N/A')
                    .toString(),
            truck:
                (item['truck'] ??
                        item['truckType'] ??
                        item['vehicleNumber'] ??
                        'N/A')
                    .toString(),
            bundles: _int(
              item['bundleCount'] ??
                  (bundles.isNotEmpty ? bundles.length : null),
            ),
            weight: _weight(item['totalWeight'] ?? item['weight']),
            destination:
                (item['destination'] ?? item['deliveryAddress'] ?? 'N/A')
                    .toString(),
            date: _date(item['generatedAt'] ?? item['createdAt']),
            status: _status(item['status']),
          );
        }),
      );
      packingListTableItems.assignAll(
        packingItemsList.asMap().entries.map((entry) {
          final item = entry.value;
          return PackingListTableItemModel(
            id: entry.key + 1,
            loadId: item.loadId,
            truck: item.truck,
            bundles: item.bundles,
            weight: item.weight,
            destination: item.destination,
            status: item.status,
          );
        }),
      );
      final bundles = data['bundles'] is List
          ? data['bundles'] as List
          : const [];
      bundleListItems.assignAll(
        bundles.whereType<Map>().toList().asMap().entries.map((entry) {
          final item = Map<String, dynamic>.from(entry.value);
          return BundleListItemModel(
            id: entry.key + 1,
            bundleId: (item['bundleId'] ?? item['_id'] ?? 'N/A').toString(),
            profile:
                (item['profile'] ??
                        item['profileType'] ??
                        item['category'] ??
                        'N/A')
                    .toString(),
            items:
                (item['itemsDescription'] ??
                        item['partNumber'] ??
                        item['itemsCount'] ??
                        'N/A')
                    .toString(),
            length: (item['length'] ?? item['maxLength'] ?? 'N/A').toString(),
            unitWeight: _weight(
              item['unitWeight'] ?? item['totalWeight'] ?? item['weight'],
            ),
          );
        }),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      packingItemsList.clear();
      packingListTableItems.clear();
      bundleListItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void openProjectPackingList(ProjectPackingListSummaryModel item) {
    Get.toNamed(
      AppRoutes.projectPackingList,
      parameters: {'id': item.id, 'name': item.projectName},
    );
  }

  void openPackingListDetails(PackingListItemModel item) {
    Get.toNamed(
      AppRoutes.packingListDetails,
      parameters: {'id': item.packingId, 'name': selectedProjectName.value},
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
      value == null ? '0 lbs' : '${value.toString()} lbs';
  String _status(dynamic value) {
    final text = (value ?? 'Ready').toString().replaceAll('_', ' ');
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
