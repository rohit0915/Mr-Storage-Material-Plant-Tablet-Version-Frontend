import 'package:get/get.dart';
import '../model/uploaded_bom_files_model.dart';
import '../repository/uploaded_bom_files_repository.dart';

class UploadedBomFilesController extends GetxController {
  final UploadedBomFilesRepository repository;

  UploadedBomFilesController({required this.repository});

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<UploadedBomFileModel> bomFilesList =
      <UploadedBomFileModel>[].obs;
  final RxString selectedSort = 'Latest'.obs;
  final RxInt selectedRowsPerPage = 10.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalProjects = 0.obs;
  final RxInt pendingExtraction = 0.obs;
  final RxInt readyForReview = 0.obs;
  final RxInt allConfirmed = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadBomFiles();
  }

  Future<void> loadBomFiles() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        repository.fetchStats(),
        repository.fetchProjects(
          page: currentPage.value,
          limit: selectedRowsPerPage.value,
        ),
      ]);
      final stats = results[0];
      final data = results[1];
      totalProjects.value = _toInt(stats['totalProjects']);
      pendingExtraction.value = _toInt(stats['pendingExtraction']);
      readyForReview.value = _toInt(stats['readyForReview']);
      allConfirmed.value = _toInt(stats['allConfirmed']);
      totalItems.value = _toInt(data['total']);

      final projects = data['projects'] is List
          ? data['projects'] as List
          : const [];
      bomFilesList.assignAll(
        projects.whereType<Map>().map((raw) {
          final item = Map<String, dynamic>.from(raw);
          final lead = _map(item['lead']);
          final id =
              (item['_id'] ??
                      item['leadId'] ??
                      lead['_id'] ??
                      item['projectId'] ??
                      '')
                  .toString();
          return UploadedBomFileModel(
            id: id,
            project: (item['projectName'] ?? lead['projectName'] ?? 'Project')
                .toString(),
            uploadDate: _formatDate(
              item['uploadedAt'] ?? item['updatedAt'] ?? item['createdAt'],
            ),
            items: _toInt(
              item['totalItems'] ?? item['itemCount'] ?? item['itemsCount'],
            ),
            status: _formatStatus(
              item['status'] ?? item['bomStatus'] ?? item['extractionStatus'],
            ),
          );
        }),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      bomFilesList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  String _formatStatus(dynamic value) {
    final text = (value ?? 'Pending').toString().replaceAll('_', ' ');
    return text
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatDate(dynamic value) {
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

  void toggleSelectAll(bool? val) {
    for (final item in bomFilesList) {
      item.isSelected = val ?? false;
    }
    bomFilesList.refresh();
  }

  void toggleSelectItem(int index, bool? val) {
    bomFilesList[index].isSelected = val ?? false;
    bomFilesList.refresh();
  }
}
