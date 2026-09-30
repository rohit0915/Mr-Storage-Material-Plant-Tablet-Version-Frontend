import 'dart:async';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../model/project_drawings_model.dart';
import '../repository/project_drawings_repository.dart';

class ProjectDrawingsController extends GetxController {
  final ProjectDrawingsRepository repository;
  ProjectDrawingsController({required this.repository});
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DrawingItemModel> drawings = <DrawingItemModel>[].obs;
  final RxList<DrawingItemModel> photos = <DrawingItemModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'All'.obs;
  final statusOptions = [
    'All',
    'Approved',
    'Revision Requested',
    'Rejected',
    'Pending Review',
  ];
  late final String projectId;
  StreamSubscription<PlantSocketEvent>? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    projectId = Get.parameters['id'] ?? '';
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor({
        'drawing_status_updated',
        'drawing_comment_added',
      }, (_) => loadDrawings());
    }
    loadDrawings();
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadDrawings() async {
    if (projectId.isEmpty) {
      errorMessage.value = 'Project id is missing.';
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.fetchDrawings(projectId);
      final buildings = data['buildings'] is List
          ? data['buildings'] as List
          : const [];
      final all = <DrawingItemModel>[];
      for (final rawBuilding in buildings.whereType<Map>()) {
        final building = Map<String, dynamic>.from(rawBuilding);
        final files =
            building['drawings'] ?? building['files'] ?? building['versions'];
        if (files is! List) continue;
        for (final raw in files.whereType<Map>()) {
          final item = Map<String, dynamic>.from(raw);
          final name = (item['fileName'] ?? item['name'] ?? 'Drawing')
              .toString();
          final mime = (item['mimeType'] ?? '').toString().toLowerCase();
          final isPhoto =
              mime.startsWith('image/') ||
              RegExp(
                r'\.(jpg|jpeg|png|webp)$',
                caseSensitive: false,
              ).hasMatch(name);
          all.add(
            DrawingItemModel(
              id: (item['_id'] ?? item['id'] ?? item['fileUrl'] ?? '')
                  .toString(),
              title: name,
              size: _size(item['fileSize'] ?? item['size']),
              status: _status(item['status']),
              type: isPhoto ? 'photo' : 'drawing',
              uploadedBy:
                  (item['uploadedByName'] ?? item['uploadedBy'] ?? 'N/A')
                      .toString(),
              location: (building['name'] ?? building['buildingName'] ?? 'N/A')
                  .toString(),
              date: _date(item['createdAt'] ?? item['uploadedAt']),
              pebCode: (building['pebCode'] ?? building['buildingNumber'] ?? '')
                  .toString(),
              fileUrl:
                  (item['fileUrl'] ?? item['url'] ?? item['signedUrl'] ?? '')
                      .toString(),
            ),
          );
        }
      }
      drawings.assignAll(all.where((item) => item.type == 'drawing'));
      photos.assignAll(all.where((item) => item.type == 'photo'));
    } catch (e) {
      errorMessage.value = e.toString();
      drawings.clear();
      photos.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String _size(dynamic value) {
    final bytes = value is num ? value.toDouble() : double.tryParse('$value');
    return bytes == null ? 'N/A' : '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  String _status(dynamic value) {
    final text = (value ?? 'Pending Review').toString().replaceAll('_', ' ');
    return text
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _date(dynamic value) {
    final d = DateTime.tryParse((value ?? '').toString())?.toLocal();
    return d == null ? 'N/A' : '${d.day}/${d.month}/${d.year}';
  }

  List<DrawingItemModel> get filteredDrawings => _filter(drawings);
  List<DrawingItemModel> get filteredPhotos => _filter(photos);

  Future<void> downloadFile(DrawingItemModel item) async {
    final uri = Uri.tryParse(item.fileUrl);
    if (uri == null || !uri.hasScheme) {
      CommonSnackbar.showError(
        title: 'Download unavailable',
        message: 'This file does not have a valid download URL.',
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      CommonSnackbar.showError(
        title: 'Download failed',
        message: 'Unable to open ${item.title}.',
      );
    }
  }

  List<DrawingItemModel> _filter(List<DrawingItemModel> source) => source
      .where(
        (item) =>
            (searchQuery.value.isEmpty ||
                item.title.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                )) &&
            (selectedStatus.value == 'All' ||
                item.status.toLowerCase() ==
                    selectedStatus.value.toLowerCase() ||
                (selectedStatus.value == 'Revision Requested' &&
                    item.status == 'Revision Required')),
      )
      .toList();
}
