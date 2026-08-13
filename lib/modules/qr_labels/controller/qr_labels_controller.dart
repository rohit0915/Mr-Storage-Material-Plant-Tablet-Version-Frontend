import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../model/qr_labels_model.dart';
import '../repository/qr_labels_repository.dart';
import '../widgets/qr_code_dialog.dart';

class QrLabelsController extends GetxController {
  final QrLabelsRepository repository;
  QrLabelsController({required this.repository});

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ProjectQrLabelsSummaryModel> projectsList =
      <ProjectQrLabelsSummaryModel>[].obs;
  final RxList<BundleQrLabelItemModel> bundleLabelsList =
      <BundleQrLabelItemModel>[].obs;
  final RxString selectedProjectId = ''.obs;
  final RxString selectedProjectName = ''.obs;
  final RxString selectedProjectFilter = 'Select Project'.obs;
  final RxString selectedSort = 'Latest'.obs;
  final RxString searchQuery = ''.obs;
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
      loadBundleLabelsData(selectedProjectId.value);
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
          return ProjectQrLabelsSummaryModel(
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
            qrGeneratedDate: _date(
              item['generatedAt'] ?? item['updatedAt'] ?? item['createdAt'],
            ),
            totalQrLabels: _int(
              item['totalQrLabels'] ??
                  item['bundleCount'] ??
                  item['totalBundles'],
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

  Future<void> loadBundleLabelsData(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.fetchPackingList(id);
      final directBundles = data['bundles'] is List
          ? data['bundles'] as List
          : const [];
      final trucks = data['trucks'] is List ? data['trucks'] as List : const [];
      final truckBundles = <dynamic>[];
      for (final rawTruck in trucks.whereType<Map>()) {
        final truck = Map<String, dynamic>.from(rawTruck);
        if (truck['bundles'] is List) {
          for (final bundle in truck['bundles'] as List) {
            if (bundle is Map) truckBundles.add({...bundle, '_truck': truck});
          }
        }
      }
      final bundles = directBundles.isNotEmpty ? directBundles : truckBundles;
      bundleLabelsList.assignAll(
        bundles.whereType<Map>().map((raw) {
          final item = Map<String, dynamic>.from(raw);
          final truck = _map(item['_truck'] ?? item['truck']);
          final parts = item['items'] is List
              ? item['items'] as List
              : const [];
          return BundleQrLabelItemModel(
            bundleId: (item['bundleId'] ?? item['_id'] ?? 'N/A').toString(),
            loadId:
                (item['loadId'] ?? truck['loadId'] ?? truck['truckId'] ?? 'N/A')
                    .toString(),
            parts:
                (item['partNumber'] ??
                        item['parts'] ??
                        (parts.isNotEmpty ? parts.length : 0))
                    .toString(),
            weight: _weight(item['totalWeight'] ?? item['weight']),
            length: (item['length'] ?? item['maxLength'] ?? 'N/A').toString(),
            status: _status(item['qrStatus'] ?? item['status'] ?? 'Generated'),
            shipper:
                (item['shipperReference'] ??
                        item['shipper'] ??
                        data['shipperReference'] ??
                        'N/A')
                    .toString(),
          );
        }),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      bundleLabelsList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void openProjectQrLabels(ProjectQrLabelsSummaryModel item) {
    Get.toNamed(
      AppRoutes.projectQrLabels,
      parameters: {'id': item.id, 'name': item.projectName},
    );
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

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  String _weight(dynamic value) =>
      value == null ? '0 lbs' : '${value.toString()} lbs';
  String _status(dynamic value) {
    final text = (value ?? 'Generated').toString().replaceAll('_', ' ');
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
  void selectSort(String sort) => selectedSort.value = sort;
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

  void toggleSelectAllBundles(bool? val) {
    for (final item in bundleLabelsList) {
      item.isSelected = val ?? false;
    }
    bundleLabelsList.refresh();
  }

  void toggleSelectBundle(int index, bool? val) {
    bundleLabelsList[index].isSelected = val ?? false;
    bundleLabelsList.refresh();
  }
}
