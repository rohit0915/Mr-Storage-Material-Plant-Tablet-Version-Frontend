import 'package:get/get.dart';
import '../model/project_drawings_model.dart';

class ProjectDrawingsController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<DrawingItemModel> drawings = <DrawingItemModel>[].obs;
  final RxList<DrawingItemModel> photos = <DrawingItemModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'All'.obs;

  final List<String> statusOptions = [
    'All',
    'Approved',
    'Revision Requested',
    'Rejected',
    'Pending Review',
  ];

  @override
  void onInit() {
    super.onInit();
    loadDrawings();
  }

  void loadDrawings() {
    isLoading.value = true;

    drawings.assignAll([
      DrawingItemModel(
        id: 'd1',
        title: 'Architectural Plans.pdf',
        size: '15.2 MB',
        status: 'Pending Review',
        type: 'drawing',
      ),
      DrawingItemModel(
        id: 'd2',
        title: 'Structural Drawings.dwg',
        size: '15.2 MB',
        status: 'Approved',
        type: 'drawing',
      ),
      DrawingItemModel(
        id: 'd3',
        title: 'Specifications.docx',
        size: '15.2 MB',
        status: 'Revision Required',
        type: 'drawing',
      ),
    ]);

    photos.assignAll([
      DrawingItemModel(
        id: 'p1',
        title: 'Architectural Plans.pdf',
        size: '15.2 MB',
        status: 'Pending Review',
        type: 'photo',
      ),
      DrawingItemModel(
        id: 'p2',
        title: 'Structural Building.dwg',
        size: '15.2 MB',
        status: 'Approved',
        type: 'photo',
      ),
      DrawingItemModel(
        id: 'p3',
        title: 'Specifications.docx',
        size: '15.2 MB',
        status: 'Revision Required',
        type: 'photo',
      ),
    ]);

    isLoading.value = false;
  }

  List<DrawingItemModel> get filteredDrawings {
    return drawings.where((item) {
      final matchesSearch = searchQuery.value.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesStatus = selectedStatus.value == 'All' ||
          selectedStatus.value == 'Select Status' ||
          (selectedStatus.value == 'Revision Requested' && item.status == 'Revision Required') ||
          item.status.toLowerCase() == selectedStatus.value.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<DrawingItemModel> get filteredPhotos {
    return photos.where((item) {
      final matchesSearch = searchQuery.value.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesStatus = selectedStatus.value == 'All' ||
          selectedStatus.value == 'Select Status' ||
          (selectedStatus.value == 'Revision Requested' && item.status == 'Revision Required') ||
          item.status.toLowerCase() == selectedStatus.value.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }
}
