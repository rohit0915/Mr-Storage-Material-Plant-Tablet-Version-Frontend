import 'dart:async';

import 'package:get/get.dart';
import '../../../app/services/plant_socket_service.dart';
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
  final RxString selectedFilterProject = 'Filter All Projects'.obs;
  final RxInt selectedRowsPerPage = 10.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;

  final RxInt totalProjects = 0.obs;
  final RxInt pendingUpload = 0.obs;
  final RxInt readyForShipper = 0.obs;
  final RxInt issuesDetected = 0.obs;
  StreamSubscription<PlantSocketEvent>? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor({
        'project_assigned',
        'bom_extraction_complete',
        'bom_extraction_failed',
        'bom_review_complete',
      }, (_) => loadBomFiles());
    }
    loadBomFiles();
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadBomFiles() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        repository.fetchStats().catchError((_) => <String, dynamic>{}),
        repository
            .fetchProjects(
              page: currentPage.value,
              limit: selectedRowsPerPage.value,
            )
            .catchError((_) => <String, dynamic>{}),
      ]);
      final stats = results[0];
      final data = results[1];

      final tProjects = _toInt(
        stats['totalBomFilesUploaded'] ??
            stats['totalProjects'] ??
            stats['total'] ??
            stats['totalBomFiles'],
      );
      final pUpload = _toInt(
        stats['pendingUploads'] ??
            stats['pendingUpload'] ??
            stats['pendingExtraction'] ??
            stats['pending'],
      );
      final rShipper = _toInt(
        stats['readyForShipper'] ?? stats['readyForReview'] ?? stats['ready'],
      );
      final iDetected = _toInt(stats['issuesDetected'] ?? stats['issues'] ?? 0);

      totalProjects.value = tProjects;
      pendingUpload.value = pUpload;
      readyForShipper.value = rShipper;
      issuesDetected.value = iDetected;
      totalItems.value = _toInt(data['total']);

      final projects = data['projects'] is List
          ? data['projects'] as List
          : const [];

      if (projects.isNotEmpty) {
        bomFilesList.assignAll(
          projects.whereType<Map>().map((raw) {
            final item = Map<String, dynamic>.from(raw);
            final lead = _map(item['lead']);
            // The detail endpoint accepts the BOM extraction job id. The
            // project's `_id`/lead id is a different resource identifier.
            final id = (item['bomJobId'] ?? '').toString();
            final projectId =
                (item['leadId'] ??
                        lead['_id'] ??
                        item['projectId'] ??
                        item['_id'] ??
                        '')
                    .toString();

            final projectSnapshot = _map(item['projectSnapshot']);
            final pName =
                (item['projectName'] ??
                        projectSnapshot['projectName'] ??
                        projectSnapshot['name'] ??
                        lead['projectName'] ??
                        'Project')
                    .toString();
            final rawDate =
                item['uploadedAt'] ??
                item['updatedAt'] ??
                item['createdAt'] ??
                item['date'] ??
                lead['createdAt'];
            final rawStatus =
                (item['fileStatus'] ??
                        item['status'] ??
                        item['bomStatus'] ??
                        item['extractionStatus'] ??
                        'pending')
                    .toString();

            return UploadedBomFileModel(
              id: id,
              projectId: projectId,
              project: pName,
              uploadDate: _formatDate(rawDate),
              items: _toInt(
                item['itemCount'] ?? item['totalItems'] ?? item['itemsCount'],
              ),
              status: rawStatus,
            );
          }),
        );
      } else {
        bomFilesList.clear();
      }
    } catch (e) {
      bomFilesList.clear();
      totalItems.value = 0;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  String _formatDate(dynamic value) {
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
        return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
      }
      if (raw.contains('Jan') ||
          raw.contains('Feb') ||
          raw.contains('Mar') ||
          raw.contains('Apr') ||
          raw.contains('May') ||
          raw.contains('Jun') ||
          raw.contains('Jul') ||
          raw.contains('Aug') ||
          raw.contains('Sep') ||
          raw.contains('Oct') ||
          raw.contains('Nov') ||
          raw.contains('Dec')) {
        return raw;
      }
    }

    return '-';
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
