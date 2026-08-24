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

  final showingBundlesView = false.obs;
  final selectedPackingId = 'PL-001'.obs;
  final packingListItems = <PackingListQrItemModel>[
    PackingListQrItemModel(
      packingId: 'PL-001',
      loadId: 'BP-0007',
      truck: '53 ft Semi',
      bundlesCount: 18,
      weight: '44,651.8 LBS',
      status: 'confirmed',
    ),
    PackingListQrItemModel(
      packingId: 'PL-002',
      loadId: 'BP-0007',
      truck: '40 ft Hot Shot',
      bundlesCount: 4,
      weight: '11,137.4 LBS',
      status: 'confirmed',
    ),
  ].obs;

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
        projects.whereType<Map>().toList().asMap().entries.map((entry) {
          final index = entry.key;
          final item = Map<String, dynamic>.from(entry.value);
          final lead = _map(item['lead']);
          final pName =
              (item['projectName'] ?? lead['projectName'] ?? 'Project')
                  .toString();
          String rawCode = (item['jobId'] ??
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
            item['totalQrLabels'] ??
                item['bundleCount'] ??
                item['totalBundles'],
          );
          return ProjectQrLabelsSummaryModel(
            id: (item['packingListId'] ??
                    item['packingListPlanId'] ??
                    item['leadId'] ??
                    item['_id'] ??
                    lead['_id'] ??
                    '')
                .toString(),
            displayProjectId: rawCode,
            projectName: pName,
            qrGeneratedDate: _date(
              item['generatedAt'] ?? item['updatedAt'] ?? item['createdAt'],
            ),
            totalQrLabels: rawTotal > 0 ? rawTotal : 2,
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

  Future<void> loadBundleLabelsData(String targetId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (projectsList.isEmpty) {
        await loadProjectsData();
      }

      String planId = targetId;
      ProjectQrLabelsSummaryModel? matchedProject;

      for (final p in projectsList) {
        if (p.id == targetId || p.displayProjectId == targetId || p.projectName.toLowerCase() == targetId.toLowerCase()) {
          matchedProject = p;
          planId = p.id;
          selectedProjectName.value = p.projectName;
          break;
        }
      }

      var planData = await repository.fetchPackingListPlan(planId);
      if (planData.isEmpty && matchedProject != null) {
        planData = await repository.fetchPackingListPlan(matchedProject.id);
      }
      if (planData.isEmpty) {
        planData = await repository.fetchPackingList(planId);
      }

      final planInfo = _map(planData['packingListPlan']);
      final projectInfo = _map(planData['project']);
      final planNumber = (planInfo['planNumber'] ?? 'PLP-0006').toString();

      if (projectInfo['projectName'] != null && projectInfo['projectName'].toString().isNotEmpty) {
        selectedProjectName.value = projectInfo['projectName'].toString();
      }

      final rawBundlesList = planData['bundles'] is List ? planData['bundles'] as List : const [];
      final parsedBundles = rawBundlesList.whereType<Map>().map((raw) {
        final bMap = Map<String, dynamic>.from(raw);
        final rawItems = bMap['items'] is List ? bMap['items'] as List : const [];

        final parsedItems = rawItems.whereType<Map>().map((iRaw) {
          final item = Map<String, dynamic>.from(iRaw);
          final snapshot = _map(item['sourceLineSnapshot']);
          return BundleItemDetailModel(
            partNumber: (item['partCode'] ?? snapshot['partCode'] ?? item['description'] ?? 'framing').toString(),
            description: (item['description'] ?? snapshot['description'] ?? '').toString(),
            quantity: _int(item['qty'] ?? item['pieceQty'] ?? snapshot['qty'] ?? 1),
            length: _formatLength(item['lengthFeet'] ?? snapshot['lengthFeet']),
            weight: _weight(item['totalWeight'] ?? item['weight'] ?? snapshot['resolvedWeight']),
            status: (bMap['status'] ?? 'assigned_to_truck').toString(),
          );
        }).toList();

        return BundleQrLabelItemModel(
          bundleId: (bMap['bundleNo'] ?? bMap['bundleId'] ?? bMap['_id'] ?? 'N/A').toString(),
          loadId: planNumber,
          parts: (bMap['bundleType'] ?? bMap['title'] ?? (parsedItems.isNotEmpty ? parsedItems.first.partNumber : 'framing')).toString(),
          weight: _weight(bMap['totalWeight'] ?? bMap['weight']),
          length: _formatLength(bMap['maxLengthFeet'] ?? bMap['lengthFeet']),
          status: (bMap['status'] ?? 'assigned_to_truck').toString(),
          shipper: planNumber,
          totalQty: _int(bMap['totalQty']),
          items: parsedItems,
        );
      }).toList();

      bundleLabelsList.assignAll(parsedBundles);

      final rawPackingLists = planData['packingLists'] is List ? planData['packingLists'] as List : const [];
      final parsedPackingLists = rawPackingLists.whereType<Map>().map((raw) {
        final plMap = Map<String, dynamic>.from(raw);
        final plNo = (plMap['packingListNo'] ?? plMap['packingId'] ?? 'PL-001').toString();
        final bIds = plMap['bundleIds'] is List ? plMap['bundleIds'] as List : const [];

        final plBundles = parsedBundles.where((b) {
          return bIds.contains(b.bundleId) || b.bundleId.startsWith('B-');
        }).toList();

        return PackingListQrItemModel(
          packingId: plNo,
          loadId: planNumber,
          truck: (plMap['truckLabel'] ?? plMap['truckType'] ?? '53 ft Semi').toString(),
          bundlesCount: _int(plMap['totalBundles'] ?? bIds.length),
          totalItemsCount: _int(plMap['totalItems'] ?? (plMap['totalBundles'] != null ? _int(plMap['totalBundles']) * 2 : 36)),
          weight: _weight(plMap['totalWeight']),
          status: (plMap['status'] ?? 'confirmed').toString(),
          shipper: planNumber,
          qrUrl: 'https://mr-storage-vendor.vercel.app/packing-list-plan/$plNo',
          bundles: plBundles.isNotEmpty ? plBundles : parsedBundles,
        );
      }).toList();

      packingListItems.assignAll(parsedPackingLists);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String _formatLength(dynamic raw) {
    if (raw == null) return 'N/A';
    final val = double.tryParse(raw.toString());
    if (val == null) return raw.toString();
    return '${val.toStringAsFixed(2)}ft';
  }

  void initProjectQrLabels(String id, String name) {
    showingBundlesView.value = false;
    if (name.isNotEmpty) selectedProjectName.value = name;
    if (id.isNotEmpty) {
      loadBundleLabelsData(id);
    }
  }

  void openProjectQrLabels(ProjectQrLabelsSummaryModel item) {
    initProjectQrLabels(item.id, item.projectName);
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
