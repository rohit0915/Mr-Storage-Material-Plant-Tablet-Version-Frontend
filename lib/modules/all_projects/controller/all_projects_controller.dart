import 'dart:async';
import 'package:get/get.dart';
import '../model/all_projects_model.dart';
import '../../../app/network/api_client.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../projects/repository/projects_repository.dart';

class AllProjectsController extends GetxController {
  final RxBool isLoading = false.obs;

  final Rx<UserProfileHeaderModel?> userProfile = Rx<UserProfileHeaderModel?>(null);
  final RxList<AllProjectRowModel> projects = <AllProjectRowModel>[].obs;

  final RxBool selectAll = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSort = 'Latest'.obs;
  final List<String> sortOptions = ['Latest', 'Oldest', 'Name A-Z', 'Name Z-A'];

  final RxInt rowsPerPage = 10.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  StreamSubscription<PlantSocketEvent>? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor({
        'project_assigned',
        'new_project_assigned',
        'project_created',
      }, (_) => loadData());
    }
    loadData();
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    super.onClose();
  }

  final errorMessage = ''.obs;
  final repository = ProjectsRepository(apiClient: Get.find<ApiClient>());
  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.fetchProjects(page: currentPage.value, limit: rowsPerPage.value, search: searchQuery.value);
      if (data == null || data['projects'] is! List) throw StateError('Invalid projects response.');
      final raw = data['projects'] as List;
      totalPages.value = (((data['total'] as num?)?.toInt() ?? raw.length) / rowsPerPage.value).ceil().clamp(1, 1000000);
      projects.assignAll(raw.whereType<Map>().map((row) {
        final status = row['status']?.toString() ?? '—';
        return AllProjectRowModel(id: (row['leadId'] ?? row['_id'] ?? '').toString(),
          projectName: row['projectName']?.toString() ?? '—', buildingCount: row['numberOfBuildings']?.toString() ?? '—',
          startDate: row['createdAt']?.toString() ?? '—', stage: row['stage']?.toString() ?? '—',
          progress: row['progress']?.toString() ?? '—', status: status,
          statusType: status == 'completed' ? AllProjectStatusType.completed : status == 'cancelled' ? AllProjectStatusType.canceled : AllProjectStatusType.active);
      }));
    } catch (error) { projects.clear(); errorMessage.value = error.toString(); }
    finally { isLoading.value = false; }
  }

  void toggleSelectAll(bool? val) {
    final newValue = val ?? false;
    selectAll.value = newValue;
    for (var project in projects) {
      project.isSelected = newValue;
    }
    projects.refresh();
  }

  void toggleSelectRow(int index) {
    projects[index].isSelected = !projects[index].isSelected;
    selectAll.value = projects.every((p) => p.isSelected);
    projects.refresh();
  }
}
