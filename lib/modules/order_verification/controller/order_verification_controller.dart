import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';

class OrderVerificationController extends GetxController {
  final ShipperRequestWorkflowRepository repository;
  OrderVerificationController({required this.repository});
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString requestId = ''.obs;
  final RxString projectId = ''.obs;
  final RxString bomFileName = ''.obs;
  final RxString bomFileSize = ''.obs;
  final RxString shipperFileName = ''.obs;
  final RxString shipperFileSize = ''.obs;

  @override
  void onInit() {
    super.onInit();
    requestId.value = Get.parameters['id'] ?? '';
    projectId.value = Get.parameters['projectId'] ?? '';
    loadFiles();
  }

  bool get canCompare =>
      bomFileName.value.isNotEmpty && shipperFileName.value.isNotEmpty;

  Future<void> loadFiles() async {
    if (requestId.value.isEmpty) {
      errorMessage.value = 'Shipper request id is missing.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.document(requestId.value);
      final request = _map(data['request']);
      final document = _map(data['document']);
      projectId.value =
          (data['projectId'] ??
                  request['projectId'] ??
                  document['projectId'] ??
                  projectId.value)
              .toString();
      shipperFileName.value =
          (data['fileName'] ??
                  document['fileName'] ??
                  request['fileName'] ??
                  '')
              .toString();
      shipperFileSize.value = (data['fileSize'] ?? document['fileSize'] ?? '')
          .toString();

      if (projectId.value.isNotEmpty) {
        final bom = await repository.consolidatedBomUrl(projectId.value);
        final fileUrl = (bom['fileUrl'] ?? '').toString();
        bomFileName.value = (bom['fileName'] ?? _fileNameFromUrl(fileUrl))
            .toString();
        bomFileSize.value = (bom['fileSize'] ?? '').toString();
      }
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> compareFiles() async {
    if (requestId.value.isEmpty || !canCompare) return;
    isLoading.value = true;
    try {
      final started = await repository.startComparison(requestId.value);
      final jobId = (started['jobId'] ?? '').toString();
      if (jobId.isNotEmpty) {
        await repository.batchJobStatus([jobId]);
        await repository.jobStatus(jobId);
      }
      Get.toNamed(
        AppRoutes.comparisonResult,
        parameters: {'id': requestId.value, 'jobId': jobId},
      );
    } catch (error) {
      Get.snackbar('Comparison failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};

  String _fileNameFromUrl(String url) {
    if (url.isEmpty) return '';
    final path = Uri.tryParse(url)?.pathSegments;
    return path == null || path.isEmpty ? '' : Uri.decodeComponent(path.last);
  }
}
