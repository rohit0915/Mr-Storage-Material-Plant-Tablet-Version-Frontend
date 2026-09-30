import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';
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
  final TextEditingController searchController = TextEditingController();
  final RxList<String> projectOptions = <String>[].obs;
  List<String> get availableProjects => projectOptions;

  final showingBundlesView = false.obs;
  final selectedPackingId = ''.obs;
  final packingListItems = <PackingListQrItemModel>[].obs;

  final currentPage = 1.obs;
  final rowsPerPage = 10.obs;
  final workers = <Worker>[];

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  bool matches(String text) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return true;
    return text.toLowerCase().contains(q);
  }

  List<ProjectQrLabelsSummaryModel> get filteredProjects => projectsList
      .where(
        (item) =>
            matches('${item.projectName} ${item.displayProjectId} ${item.id}') &&
            (selectedProjectFilter.value == 'Select Project' ||
                item.projectName == selectedProjectFilter.value),
      )
      .toList();

  List<PackingListQrItemModel> get filteredPacking {
    final rows = packingListItems
        .where(
          (item) {
            final bundlesContent = item.bundles
                .map((b) => '${b.bundleId} ${b.parts}')
                .join(' ');
            return matches(
              '${item.packingId} ${item.loadId} ${item.truck} ${item.status} ${item.shipper} $bundlesContent',
            );
          },
        )
        .toList();
    if (selectedSort.value == 'Oldest') return rows.reversed.toList();
    if (selectedSort.value == 'Bundle ID') {
      rows.sort((a, b) => a.packingId.compareTo(b.packingId));
    }
    return rows;
  }

  List<BundleQrLabelItemModel> get filteredBundles {
    final packing = packingListItems.where(
      (item) => item.packingId == selectedPackingId.value,
    );
    final assigned = packing.isNotEmpty
        ? packing.first.bundles
        : (selectedPackingId.value.isEmpty ? bundleLabelsList : <BundleQrLabelItemModel>[]);
    final source = assigned.isNotEmpty ? assigned : bundleLabelsList;
    final rows = source
        .where(
          (item) {
            final itemsContent = item.items
                .map((i) => '${i.partNumber} ${i.description}')
                .join(' ');
            return matches(
              '${item.bundleId} ${item.loadId} ${item.parts} ${item.status} ${item.shipper} $itemsContent',
            );
          },
        )
        .toList();
    if (selectedSort.value == 'Oldest') return rows.reversed.toList();
    if (selectedSort.value == 'Bundle ID') {
      rows.sort((a, b) => a.bundleId.compareTo(b.bundleId));
    }
    return rows;
  }

  List<T> pageItems<T>(List<T> rows) => rows
      .skip((currentPage.value - 1) * rowsPerPage.value)
      .take(rowsPerPage.value)
      .toList();
  List<ProjectQrLabelsSummaryModel> get visibleProjects =>
      pageItems(filteredProjects);
  List<PackingListQrItemModel> get visiblePacking => pageItems(filteredPacking);
  List<BundleQrLabelItemModel> get visibleBundles => pageItems(filteredBundles);
  int get filteredCount => selectedProjectId.value.isEmpty
      ? filteredProjects.length
      : showingBundlesView.value
      ? filteredBundles.length
      : filteredPacking.length;
  int get totalPages =>
      (filteredCount / rowsPerPage.value).ceil().clamp(1, 1000000);
  void changePage(int value) => currentPage.value = value;
  void changeRows(int value) {
    rowsPerPage.value = value;
    currentPage.value = 1;
  }

  void openBundles(PackingListQrItemModel item) {
    selectedPackingId.value = item.packingId;
    showingBundlesView.value = true;
    clearSearch();
    currentPage.value = 1;
  }

  @override
  void onClose() {
    searchController.dispose();
    for (final worker in workers) {
      worker.dispose();
    }
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    workers.add(
      everAll([
        searchQuery,
        selectedProjectFilter,
      ], (_) => currentPage.value = 1),
    );
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
            item['totalQrLabels'] ??
                item['totalPackingList'] ??
                item['bundleCount'] ??
                item['totalBundles'],
          );
          return ProjectQrLabelsSummaryModel(
            id:
                (item['packingListId'] ??
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
            totalQrLabels: rawTotal,
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
        if (p.id == targetId ||
            p.displayProjectId == targetId ||
            p.projectName.toLowerCase() == targetId.toLowerCase()) {
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
      final planNumber = (planInfo['planNumber'] ?? '').toString();

      if (projectInfo['projectName'] != null &&
          projectInfo['projectName'].toString().isNotEmpty) {
        selectedProjectName.value = projectInfo['projectName'].toString();
      }

      final rawBundlesList = planData['bundles'] is List
          ? planData['bundles'] as List
          : const [];
      final parsedBundles = rawBundlesList.whereType<Map>().map((raw) {
        final bMap = Map<String, dynamic>.from(raw);
        final rawItems = bMap['items'] is List
            ? bMap['items'] as List
            : const [];

        final parsedItems = rawItems.whereType<Map>().map((iRaw) {
          final item = Map<String, dynamic>.from(iRaw);
          final snapshot = _map(item['sourceLineSnapshot']);
          return BundleItemDetailModel(
            partNumber:
                (item['partCode'] ??
                        snapshot['partCode'] ??
                        item['description'] ??
                        '—')
                    .toString(),
            description: (item['description'] ?? snapshot['description'] ?? '')
                .toString(),
            quantity: _int(item['qty'] ?? item['pieceQty'] ?? snapshot['qty']),
            length: _formatLength(item['lengthFeet'] ?? snapshot['lengthFeet']),
            weight: _weight(
              item['totalWeight'] ??
                  item['weight'] ??
                  snapshot['resolvedWeight'],
            ),
            status: (bMap['status'] ?? '—').toString(),
          );
        }).toList();

        return BundleQrLabelItemModel(
          recordId: (bMap['_id'] ?? '').toString(),
          bundleId:
              (bMap['bundleNo'] ?? bMap['bundleId'] ?? bMap['_id'] ?? 'N/A')
                  .toString(),
          loadId: planNumber,
          parts:
              (bMap['bundleType'] ??
                      bMap['title'] ??
                      (parsedItems.isNotEmpty
                          ? parsedItems.first.partNumber
                          : '—'))
                  .toString(),
          weight: _weight(bMap['totalWeight'] ?? bMap['weight']),
          length: _formatLength(bMap['maxLengthFeet'] ?? bMap['lengthFeet']),
          status: (bMap['status'] ?? '—').toString(),
          shipper: planNumber,
          totalQty: _int(bMap['totalQty']),
          items: parsedItems,
        );
      }).toList();

      bundleLabelsList.assignAll(parsedBundles);

      final rawPackingLists = planData['packingLists'] is List
          ? planData['packingLists'] as List
          : const [];
      final parsedPackingLists = rawPackingLists.whereType<Map>().map((raw) {
        final plMap = Map<String, dynamic>.from(raw);
        final plNo = (plMap['packingListNo'] ?? plMap['packingId'] ?? '')
            .toString();
        final bIds = plMap['bundleIds'] is List
            ? plMap['bundleIds'] as List
            : const [];

        final plBundles = parsedBundles.where((b) {
          return bIds.contains(b.recordId) || bIds.contains(b.bundleId);
        }).toList();

        return PackingListQrItemModel(
          packingId: plNo,
          loadId: planNumber,
          truck: (plMap['truckLabel'] ?? plMap['truckType'] ?? '—').toString(),
          bundlesCount: _int(plMap['totalBundles'] ?? bIds.length),
          totalItemsCount: _int(
            plMap['totalItems'] ??
                plBundles.fold<int>(
                  0,
                  (sum, bundle) => sum + bundle.items.length,
                ),
          ),
          weight: _weight(plMap['totalWeight']),
          status: (plMap['status'] ?? '—').toString(),
          shipper: planNumber,
          qrUrl: (plMap['qrUrl'] ?? '').toString(),
          bundles: plBundles,
        );
      }).toList();

      packingListItems.assignAll(parsedPackingLists);
    } catch (e) {
      packingListItems.clear();
      bundleLabelsList.clear();
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
    if (selectedProjectId.value == id &&
        (isLoading.value || packingListItems.isNotEmpty)) {
      return;
    }
    selectedProjectId.value = id;
    clearSearch();
    currentPage.value = 1;
    showingBundlesView.value = false;
    if (name.isNotEmpty) selectedProjectName.value = name;
    if (id.isNotEmpty) {
      loadBundleLabelsData(id);
    }
  }

  Future<void> openProjectQrLabels(ProjectQrLabelsSummaryModel item) async {
    initProjectQrLabels(item.id, item.projectName);
    await Get.toNamed(
      AppRoutes.projectQrLabels,
      parameters: {'id': item.id, 'name': item.projectName},
    );
    selectedProjectId.value = '';
    selectedPackingId.value = '';
    showingBundlesView.value = false;
    clearSearch();
    currentPage.value = 1;
  }

  void showQrCodeDialog(BundleQrLabelItemModel item) {
    Get.dialog(
      QrCodeDialog(item: item, projectName: selectedProjectName.value),
      barrierDismissible: true,
    );
  }

  String packingPayload(PackingListQrItemModel item) => item.qrUrl.isNotEmpty
      ? item.qrUrl
      : Uri(
          queryParameters: {
            'project': selectedProjectName.value,
            'load_id': item.loadId,
            'packing_id': item.packingId,
            'bundle_ids': item.bundles
                .map((bundle) => bundle.bundleId)
                .join(','),
          },
        ).query;

  Future<void> exportPackingLabel(
    PackingListQrItemModel item, {
    bool excel = false,
  }) async {
    try {
      if (excel) {
        await FileExportService.saveExcel(
          fileName: 'packing_${item.packingId}',
          rows: [
            ['Packing ID', 'Load', 'Truck', 'Bundles', 'Weight', 'QR data'],
            [
              item.packingId,
              item.loadId,
              item.truck,
              item.bundlesCount,
              item.weight,
              packingPayload(item),
            ],
          ],
        );
      } else {
        final bytes = await FileExportService.qrPdf(
          title: 'Packing list ${item.packingId}',
          payload: packingPayload(item),
        );
        await FileExportService.savePdf(
          fileName: 'packing_${item.packingId}',
          bytes: bytes,
        );
      }
    } catch (e) {
      CommonSnackbar.showError(title: 'Export failed', message: e.toString());
    }
  }

  Future<void> exportVisibleData() async {
    try {
      final List<List<dynamic>> rows;
      if (selectedProjectId.isEmpty) {
        final selected = filteredProjects
            .where((item) => item.isSelected)
            .toList();
        final items = selected.isEmpty ? filteredProjects : selected;
        rows = [
          ['Project ID', 'Project', 'QR Generated Date', 'Total QR Labels'],
          ...items.map(
            (item) => [
              item.displayProjectId,
              item.projectName,
              item.qrGeneratedDate,
              item.totalQrLabels,
            ],
          ),
        ];
      } else if (showingBundlesView.value) {
        final selected = filteredBundles
            .where((item) => item.isSelected)
            .toList();
        final items = selected.isEmpty ? filteredBundles : selected;
        rows = [
          [
            'Bundle ID',
            'Load ID',
            'Parts',
            'Weight',
            'Length',
            'Status',
            'QR data',
          ],
          ...items.map(
            (item) => [
              item.bundleId,
              item.loadId,
              item.parts,
              item.weight,
              item.length,
              item.status,
              QrCodeDialog(
                item: item,
                projectName: selectedProjectName.value,
              ).payload,
            ],
          ),
        ];
      } else {
        final selected = filteredPacking
            .where((item) => item.isSelected)
            .toList();
        final items = selected.isEmpty ? filteredPacking : selected;
        rows = [
          [
            'Packing ID',
            'Load ID',
            'Truck',
            'Bundles',
            'Weight',
            'Status',
            'QR data',
          ],
          ...items.map(
            (item) => [
              item.packingId,
              item.loadId,
              item.truck,
              item.bundlesCount,
              item.weight,
              item.status,
              packingPayload(item),
            ],
          ),
        ];
      }
      await FileExportService.saveExcel(fileName: 'qr_labels', rows: rows);
    } catch (e) {
      CommonSnackbar.showError(title: 'Export failed', message: e.toString());
    }
  }

  Future<void> printBundle(BundleQrLabelItemModel item) async {
    try {
      final bytes = await FileExportService.qrPdf(
        title: 'QR Label — ${item.bundleId}',
        payload: QrCodeDialog(
          item: item,
          projectName: selectedProjectName.value,
        ).payload,
      );
      await FileExportService.printPdf(
        name: 'QR label ${item.bundleId}',
        bytes: bytes,
      );
    } catch (e) {
      CommonSnackbar.showError(title: 'Print failed', message: e.toString());
    }
  }

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

  void selectProjectFilter(String project) {
    selectedProjectFilter.value = project;
    if (selectedProjectId.isNotEmpty) {
      final matches = projectsList.where((item) => item.projectName == project);
      if (matches.isNotEmpty) initProjectQrLabels(matches.first.id, project);
    }
  }

  void selectSort(String sort) {
    selectedSort.value = sort;
    currentPage.value = 1;
  }

  void toggleSelectAllProjects(bool? val) {
    for (final item in filteredProjects) {
      item.isSelected = val ?? false;
    }
    projectsList.refresh();
  }

  void toggleSelectProject(int index, bool? val) {
    projectsList[index].isSelected = val ?? false;
    projectsList.refresh();
  }

  void toggleSelectAllBundles(bool? val) {
    for (final item in filteredBundles) {
      item.isSelected = val ?? false;
    }
    bundleLabelsList.refresh();
  }

  void toggleSelectBundle(int index, bool? val) {
    bundleLabelsList[index].isSelected = val ?? false;
    bundleLabelsList.refresh();
  }
}
