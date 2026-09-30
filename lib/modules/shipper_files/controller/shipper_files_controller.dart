import 'dart:async';

import 'package:get/get.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../../app/routes/app_routes.dart';
import '../model/shipper_files_model.dart';
import '../repository/shipper_files_repository.dart';
import '../widgets/file_status_changed_dialog.dart';

class ShipperFilesController extends GetxController {
  final ShipperFilesRepository repository;

  ShipperFilesController({required this.repository});

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ProjectShipperFileModel> projectsList =
      <ProjectShipperFileModel>[].obs;
  final RxList<ShipperFileItemModel> shipperFiles =
      <ShipperFileItemModel>[].obs;
  final RxString selectedProjectId = ''.obs;
  final RxString selectedProjectName = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSort = 'Latest'.obs;
  final RxString selectedStatus = 'Select Status'.obs;
  final RxInt currentPage = 1.obs;
  final RxInt rowsPerPage = 10.obs;
  final RxInt totalProjects = 0.obs;
  final RxInt pendingComparison = 0.obs;
  final RxInt approved = 0.obs;

  final RxInt projectTotalFiles = 0.obs;
  final RxInt projectFilesReceived = 0.obs;
  final RxInt projectOrdersSent = 0.obs;
  final RxInt projectRevisionsSent = 0.obs;
  StreamSubscription<PlantSocketEvent>? _socketSubscription;

  final paginationTotal = 0.obs;
  Worker? _projectSearchWorker;
  int get projectPages =>
      (paginationTotal.value / rowsPerPage.value).ceil().clamp(1, 1000000);
  void changeProjectPage(int page) {
    currentPage.value = page;
    loadData();
  }

  void changeProjectRows(int rows) {
    rowsPerPage.value = rows;
    changeProjectPage(1);
  }

  @override
  void onInit() {
    super.onInit();
    _projectSearchWorker = debounce(searchQuery, (_) {
      if (selectedProjectId.isEmpty) changeProjectPage(1);
    }, time: const Duration(milliseconds: 350));
    final routeId = Get.parameters['id'];
    if (routeId != null && routeId.isNotEmpty) {
      selectedProjectId.value = routeId;
    }
    final routeName = Get.parameters['name'];
    if (routeName != null && routeName.isNotEmpty) {
      selectedProjectName.value = routeName;
    }
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor({
        'shipper_file_submitted',
        'all_shipper_files_submitted',
        'shipper_comparison_complete',
        'shipper_comparison_failed',
      }, (_) => loadData(silent: true));
    }
    loadData();
  }

  @override
  void onClose() {
    _projectSearchWorker?.dispose();
    _socketSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadData({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = '';
    try {
      if (selectedProjectId.value.isNotEmpty) {
        await loadProjectRequests(selectedProjectId.value, silent: silent);
        return;
      }
      final results = await Future.wait([
        repository.fetchStats().catchError((_) => <String, dynamic>{}),
        repository.fetchProjects(
          page: currentPage.value,
          limit: rowsPerPage.value,
          search: searchQuery.value,
        ),
      ]);
      final stats = results[0];
      final data = results[1];
      paginationTotal.value = _int(data['total']);
      totalProjects.value = _int(stats['totalFiles']);
      pendingComparison.value = _int(stats['filesReceived']);
      approved.value = _int(stats['ordersSent']);

      final projects = data['projects'] is List
          ? data['projects'] as List
          : const [];

      projectsList.assignAll(projects.whereType<Map>().map(_projectFromMap));
    } catch (e) {
      if (!silent) projectsList.clear();
      errorMessage.value = e.toString();
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  ProjectShipperFileModel _projectFromMap(Map raw) {
    final item = Map<String, dynamic>.from(raw);
    final lead = _map(item['lead']);
    final pName = (item['projectName'] ?? lead['projectName'] ?? 'Project')
        .toString();

    final leadId = (item['leadId'] ?? lead['_id'] ?? item['_id'] ?? '')
        .toString();
    final pId = (item['projectId'] ?? item['jobId'] ?? lead['jobId'] ?? '-')
        .toString();

    final rawDate =
        item['latestSubmittedAt'] ??
        item['fileReceivedAt'] ??
        item['updatedAt'] ??
        item['createdAt'] ??
        lead['createdAt'];

    final total = _int(
      item['totalShipperFiles'] ??
          item['shipperFileCount'] ??
          item['totalFiles'] ??
          item['numberOfBuildings'],
    );

    return ProjectShipperFileModel(
      leadId: leadId,
      projectId: pId,
      projectName: pName,
      fileReceived: _formatReceivedDate(rawDate),
      totalShipperFiles: total,
    );
  }

  String _formatReceivedDate(dynamic value) {
    if (value != null &&
        value.toString().isNotEmpty &&
        value.toString() != 'null') {
      final raw = value.toString();
      final dt = DateTime.tryParse(raw)?.toLocal();
      if (dt != null) {
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
        return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
      }
      if (raw.contains('Aug') ||
          raw.contains('Jul') ||
          raw.contains('Jan') ||
          raw.contains('Feb') ||
          raw.contains('Mar') ||
          raw.contains('Apr') ||
          raw.contains('May') ||
          raw.contains('Jun') ||
          raw.contains('Sep') ||
          raw.contains('Oct') ||
          raw.contains('Nov') ||
          raw.contains('Dec')) {
        return raw;
      }
    }

    return '-';
  }

  Future<void> openProject(ProjectShipperFileModel item) async {
    await openProjectShipperFiles(item);
  }

  Future<void> openProjectShipperFiles(ProjectShipperFileModel project) async {
    final targetId = project.leadId.isNotEmpty
        ? project.leadId
        : project.projectId;
    selectedProjectId.value = targetId;
    selectedProjectName.value = project.projectName;
    shipperFiles.clear();
    errorMessage.value = '';
    isLoading.value = true;
    Get.toNamed(
      AppRoutes.projectShipperFiles,
      parameters: {'id': targetId, 'name': project.projectName},
    )?.then((_) {
      if (isClosed) return;
      selectedProjectId.value = '';
      selectedProjectName.value = '';
      searchQuery.value = '';
      loadData();
    });
    try {
      await loadProjectRequests(targetId);
    } catch (error) {
      shipperFiles.clear();
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProjectRequests(String leadId, {bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final data = await repository.fetchProjectRequests(leadId);
      selectedProjectName.value =
          (data['projectName'] ?? data['name'] ?? selectedProjectName.value)
              .toString();
      final rawRequests =
          data['shipperRequests'] ?? data['requests'] ?? data['files'];
      final requests = rawRequests is List ? rawRequests : const [];
      shipperFiles.assignAll(
        requests.whereType<Map>().map((raw) {
          final item = Map<String, dynamic>.from(raw);
          final vendor = _map(item['vendor'] ?? item['shipper']);
          final comparison = _map(item['amountComparison']);
          return ShipperFileItemModel(
            id: (item['requestId'] ?? item['_id'] ?? '').toString(),
            shipperName:
                (item['vendorName'] ??
                        item['shipperName'] ??
                        vendor['name'] ??
                        '-')
                    .toString(),
            fileName: (item['fileName'] ?? item['file_name'] ?? '-').toString(),
            uploadDate: _date(
              item['uploadedDate'] ??
                  item['uploadedAt'] ??
                  item['createdAt'] ??
                  item['uploadDate'],
            ),
            items: _int(item['totalItems'] ?? item['itemCount']),
            rate: _money(
              item['rates'] ??
                  item['rate'] ??
                  item['totalAmount'] ??
                  item['quotedAmount'] ??
                  comparison['shipperSubmittedAmount'],
            ),
            status: _status(
              item['fileStatus'] ?? item['status'] ?? item['comparisonStatus'],
            ),
            avatarUrl: (vendor['photo'] ?? vendor['logo'] ?? '').toString(),
          );
        }),
      );

      // Compute project stats for summary cards
      final stats = _map(data['stats']);
      final tFiles = _int(
        stats['totalFiles'] ??
            stats['totalShipperFiles'] ??
            data['totalShipperFiles'],
      );
      projectTotalFiles.value = tFiles > 0 ? tFiles : shipperFiles.length;

      final fRec = _int(stats['filesReceived'] ?? stats['fileReceived']);
      projectFilesReceived.value = fRec > 0
          ? fRec
          : shipperFiles.where((f) {
              final st = f.status.toLowerCase();
              return st.contains('received') ||
                  st.contains('compared') ||
                  st.contains('pending');
            }).length;

      final oSent = _int(stats['ordersSent'] ?? stats['orderSent']);
      projectOrdersSent.value = oSent > 0
          ? oSent
          : shipperFiles.where((f) {
              final st = f.status.toLowerCase();
              return st.contains('order') || st.contains('approved');
            }).length;

      final rSent = _int(stats['revisionsSent'] ?? stats['revisionSent']);
      projectRevisionsSent.value = rSent > 0
          ? rSent
          : shipperFiles
                .where((f) => f.status.toLowerCase().contains('revision'))
                .length;
    } catch (error) {
      if (!silent) shipperFiles.clear();
      errorMessage.value = error.toString();
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  List<ShipperFileItemModel> get filteredShipperFiles {
    var list = shipperFiles.toList();
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (item) =>
                item.shipperName.toLowerCase().contains(q) ||
                item.fileName.toLowerCase().contains(q) ||
                item.status.toLowerCase().contains(q),
          )
          .toList();
    }
    if (selectedStatus.value != 'Select Status') {
      list = list
          .where(
            (item) =>
                item.status.toLowerCase() == selectedStatus.value.toLowerCase(),
          )
          .toList();
    }
    return list;
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  String _money(dynamic value) {
    if (value == null || value == 0 || value == '0' || value == '0.0') {
      return '-';
    }
    if (value is num) {
      final str = value
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '\$$str';
    }
    final raw = value.toString().trim();
    if (raw.isEmpty || raw == '-') return '-';
    if (raw.startsWith('\$')) return raw;
    final parsed = num.tryParse(raw);
    if (parsed != null) {
      final str = parsed
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '\$$str';
    }
    return '\$$raw';
  }

  String _status(dynamic value) {
    final text = (value ?? 'File Received').toString().replaceAll('_', ' ');
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
    if (date == null) return '-';
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

  void updateFileStatus(int index, String newStatus) {
    shipperFiles[index].status = newStatus;
    shipperFiles.refresh();
    Get.dialog(const FileStatusChangedDialog());
  }

  void toggleSelectProject(int index, bool? val) {
    projectsList[index].isSelected = val ?? false;
    projectsList.refresh();
  }

  void toggleSelectFile(int index, bool? val) {
    shipperFiles[index].isSelected = val ?? false;
    shipperFiles.refresh();
  }

  void openShipperFileDetails(ShipperFileItemModel item) {
    Get.toNamed(AppRoutes.shipperFileDetails, parameters: {'id': item.id});
  }
}
