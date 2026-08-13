import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    final routeId = Get.parameters['id'];
    if (routeId != null && routeId.isNotEmpty) {
      selectedProjectId.value = routeId;
    }
    selectedProjectName.value = Get.parameters['name'] ?? '';
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (selectedProjectId.value.isNotEmpty) {
        await loadProjectRequests(selectedProjectId.value);
        return;
      }
      final results = await Future.wait([
        repository.fetchStats(),
        repository.fetchProjects(),
      ]);
      final stats = results[0];
      final data = results[1];
      totalProjects.value = _int(stats['totalProjects']);
      pendingComparison.value = _int(stats['pendingComparison']);
      approved.value = _int(stats['approved']);
      final projects = data['projects'] is List
          ? data['projects'] as List
          : const [];
      projectsList.assignAll(projects.whereType<Map>().map(_projectFromMap));
    } catch (e) {
      errorMessage.value = e.toString();
      projectsList.clear();
      shipperFiles.clear();
    } finally {
      isLoading.value = false;
    }
  }

  ProjectShipperFileModel _projectFromMap(Map raw) {
    final item = Map<String, dynamic>.from(raw);
    final lead = _map(item['lead']);
    return ProjectShipperFileModel(
      projectId:
          (item['leadId'] ??
                  item['_id'] ??
                  lead['_id'] ??
                  item['projectId'] ??
                  '')
              .toString(),
      projectName: (item['projectName'] ?? lead['projectName'] ?? 'Project')
          .toString(),
      fileReceived: _date(
        item['fileReceivedAt'] ?? item['updatedAt'] ?? item['createdAt'],
      ),
      totalShipperFiles: _int(
        item['totalShipperFiles'] ??
            item['totalRequests'] ??
            item['requestCount'],
      ),
    );
  }

  Future<void> openProject(ProjectShipperFileModel item) async {
    selectedProjectId.value = item.projectId;
    selectedProjectName.value = item.projectName;
    Get.toNamed(
      AppRoutes.projectShipperFiles,
      parameters: {'id': item.projectId, 'name': item.projectName},
    );
  }

  Future<void> loadProjectRequests(String leadId) async {
    final data = await repository.fetchProjectRequests(leadId);
    selectedProjectName.value =
        (data['projectName'] ?? selectedProjectName.value).toString();
    final rawRequests = data['shipperRequests'] ?? data['requests'];
    final requests = rawRequests is List ? rawRequests : const [];
    shipperFiles.assignAll(
      requests.whereType<Map>().map((raw) {
        final item = Map<String, dynamic>.from(raw);
        final vendor = _map(item['vendor'] ?? item['shipper']);
        final comparison = _map(item['amountComparison']);
        return ShipperFileItemModel(
          id: (item['requestId'] ?? item['_id'] ?? '').toString(),
          shipperName: (item['shipperName'] ?? vendor['name'] ?? 'Shipper')
              .toString(),
          fileName:
              (((item['fileName']?.toString().isNotEmpty ?? false)
                          ? item['fileName']
                          : null) ??
                      item['vendorCode'] ??
                      item['shipperReference'] ??
                      item['reference'] ??
                      'No file uploaded')
                  .toString(),
          uploadDate: _date(
            item['uploadedDate'] ?? item['uploadedAt'] ?? item['createdAt'],
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
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  String _money(dynamic value) =>
      value == null ? r'$0' : '\$${value.toString()}';
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
}
