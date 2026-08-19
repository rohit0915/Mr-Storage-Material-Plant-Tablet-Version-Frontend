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
      final lead = _map(data['lead'] ?? request['lead']);

      projectId.value = (data['leadId'] ??
              data['projectId'] ??
              request['leadId'] ??
              request['projectId'] ??
              document['leadId'] ??
              document['projectId'] ??
              lead['_id'] ??
              lead['id'] ??
              Get.parameters['projectId'] ??
              Get.parameters['leadId'] ??
              Get.parameters['id'] ??
              projectId.value)
          .toString();

      shipperFileName.value = (data['fileName'] ??
              document['fileName'] ??
              request['fileName'] ??
              '')
          .toString();
      shipperFileSize.value = (data['fileSize'] ?? document['fileSize'] ?? '')
          .toString();

      // Check if document contains consolidated BOM info
      final docBom = (data['consolidatedBom'] ??
              data['bomFile'] ??
              data['bomFileName'] ??
              request['consolidatedBom'] ??
              request['bomFile'] ??
              request['bomFileName'])
          .toString();

      if (docBom.isNotEmpty && docBom != 'null') {
        bomFileName.value = docBom;
      } else if (projectId.value.isNotEmpty) {
        try {
          final bom = await repository.consolidatedBomUrl(projectId.value);
          final fileUrl = (bom['fileUrl'] ?? bom['url'] ?? '').toString();
          bomFileName.value = (bom['fileName'] ??
                  bom['originalName'] ??
                  bom['name'] ??
                  _fileNameFromUrl(fileUrl))
              .toString();
          bomFileSize.value = (bom['fileSize'] ?? '').toString();
        } catch (_) {
          // If 404 or failed, fallback to auto-generated project BOM name
        }
      }

      // If bomFileName is still empty, automatically get and set project BOM File name
      if (bomFileName.value.isEmpty) {
        final pName = (data['projectName'] ?? request['projectName'] ?? '').toString();
        final pCode = (data['projectId'] ?? request['projectId'] ?? '').toString();
        if (pCode.isNotEmpty) {
          bomFileName.value = '${pCode}_Consolidated_BOM.xlsx';
        } else if (pName.isNotEmpty) {
          final sanitized = pName.replaceAll(' ', '_');
          bomFileName.value = '${sanitized}_Consolidated_BOM.xlsx';
        } else {
          bomFileName.value = 'BOM_Consolidated_File.xlsx';
        }
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
