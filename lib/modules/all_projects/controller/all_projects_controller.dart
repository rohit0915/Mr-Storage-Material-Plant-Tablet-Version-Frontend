import 'package:get/get.dart';
import '../model/all_projects_model.dart';

class AllProjectsController extends GetxController {
  final RxBool isLoading = false.obs;

  final Rx<UserProfileHeaderModel?> userProfile = Rx<UserProfileHeaderModel?>(null);
  final RxList<AllProjectRowModel> projects = <AllProjectRowModel>[].obs;

  final RxBool selectAll = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSort = 'Latest'.obs;
  final List<String> sortOptions = ['Latest', 'Oldest', 'Name A-Z', 'Name Z-A'];

  final RxInt rowsPerPage = 10.obs;
  final RxInt currentPage = 4.obs;
  final RxInt totalPages = 15.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    isLoading.value = true;

    userProfile.value = UserProfileHeaderModel(
      name: 'John Doe',
      id: 'ID-2025-1047',
      status: 'Active',
      joinedDate: 'Joined January 15, 2023',
      phone: '(163) 2459 315',
      email: 'darlee@example.com',
      address: '1861 Bayonne Ave, Manchester, NJ, 08759',
    );

    projects.assignAll([
      AllProjectRowModel(
        id: '1',
        projectName: 'ABC Warehouse',
        buildingCount: '2',
        startDate: '22 Feb 2025',
        stage: 'Shipment',
        progress: '75%',
        status: 'Work in Progress',
        statusType: AllProjectStatusType.workInProgress,
      ),
      AllProjectRowModel(
        id: '2',
        projectName: 'Tech Park Dev',
        buildingCount: '1',
        startDate: '07 Feb 2025',
        stage: 'Engineering',
        progress: '30%',
        status: 'Active',
        statusType: AllProjectStatusType.active,
      ),
      AllProjectRowModel(
        id: '3',
        projectName: 'Downtown Plaza',
        buildingCount: '3',
        startDate: '30 Jan 2025',
        stage: 'Completed',
        progress: '100%',
        status: 'Completed',
        statusType: AllProjectStatusType.completed,
      ),
      AllProjectRowModel(
        id: '4',
        projectName: 'Riverside Complex',
        buildingCount: '1',
        startDate: '17 Jan 2025',
        stage: 'Canceled',
        progress: '0%',
        status: 'Canceled',
        statusType: AllProjectStatusType.canceled,
      ),
    ]);

    isLoading.value = false;
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
