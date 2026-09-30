import 'dart:async';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../comparison_result/controller/comparison_result_controller.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';

class OrderVerificationController extends GetxController {
  final ShipperRequestWorkflowRepository repository;
  OrderVerificationController({required this.repository});
  final RxBool isLoading = false.obs;
  final isComparing = false.obs;
  final comparisonComplete = false.obs;
  String _comparisonJobId = '';
  bool _closed = false;

  @override
  void onClose() {
    _closed = true;
    super.onClose();
  }

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
    bomFileName.value = '';
    shipperFileName.value = '';
    try {
      final data = await repository.document(requestId.value);
      final request = _map(data['request']);
      final document = _map(data['document']);
      final lead = _map(data['lead'] ?? request['lead']);

      projectId.value =
          (data['leadId'] ??
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

      shipperFileName.value =
          (data['fileName'] ??
                  document['fileName'] ??
                  request['fileName'] ??
                  '')
              .toString();
      shipperFileSize.value = (data['fileSize'] ?? document['fileSize'] ?? '')
          .toString();

      // Check if document contains consolidated BOM info
      final docBom =
          (data['consolidatedBom'] ??
          data['bomFile'] ??
          data['bomFileName'] ??
          request['consolidatedBom'] ??
          request['bomFile'] ??
          request['bomFileName']);

      final bomName = docBom is Map
          ? (docBom['fileName'] ??
                    docBom['originalName'] ??
                    _fileNameFromUrl(
                      (docBom['fileUrl'] ?? docBom['url'] ?? '').toString(),
                    ))
                .toString()
          : (docBom ?? '').toString();
      if (bomName.isNotEmpty) {
        bomFileName.value = bomName;
      } else if (projectId.value.isNotEmpty) {
        try {
          final bom = await repository.consolidatedBomUrl(projectId.value);
          final fileUrl = (bom['fileUrl'] ?? bom['url'] ?? '').toString();
          bomFileName.value =
              (bom['fileName'] ??
                      bom['originalName'] ??
                      bom['name'] ??
                      _fileNameFromUrl(fileUrl))
                  .toString();
          bomFileSize.value = (bom['fileSize'] ?? '').toString();
        } catch (_) {
          errorMessage.value =
              'BOM file is unavailable. Retry after it is uploaded.';
        }
      }
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> compareFiles() async {
    if (isLoading.value ||
        isComparing.value ||
        requestId.value.isEmpty ||
        !canCompare) {
      return;
    }
    isComparing.value = true;
    comparisonComplete.value = false;
    errorMessage.value = '';
    _comparisonJobId = '';
    StreamSubscription<PlantSocketEvent>? subscription;
    String? socketError;
    if (Get.isRegistered<PlantSocketService>()) {
      subscription = Get.find<PlantSocketService>().listenFor(
        {'shipper_comparison_complete', 'shipper_comparison_failed'},
        (event) {
          if (_closed || event.requestId != requestId.value) return;
          if (_comparisonJobId.isNotEmpty &&
              event.jobId != null &&
              event.jobId != _comparisonJobId) {
            return;
          }
          if (event.name == 'shipper_comparison_complete') {
            if (_comparisonJobId.isEmpty && event.jobId != null && event.jobId!.isNotEmpty) {
              _comparisonJobId = event.jobId!;
            }
            comparisonComplete.value = true;
          } else {
            socketError = (event.payload['error'] ?? 'Comparison failed.')
                .toString();
          }
        },
      );
    }
    try {
      final started = await repository.startComparison(requestId.value);
      final startedJob = _map(started['job']);
      _comparisonJobId =
          (started['jobId'] ??
                  startedJob['jobId'] ??
                  startedJob['_id'] ??
                  startedJob['id'] ??
                  '')
              .toString();
      var result = started;
      final timeout = DateTime.now().add(const Duration(minutes: 2));
      while (!_closed) {
        if (socketError != null) throw StateError(socketError!);
        if (comparisonComplete.value) break;
        final job = _map(result['job']);
        final status =
            (job['status'] ?? result['status'] ?? result['jobStatus'] ?? '')
                .toString()
                .toLowerCase();
        if ([
          'completed',
          'comparison_completed',
          'succeeded',
          'done',
        ].contains(status)) {
          comparisonComplete.value = true;
          break;
        }
        if (['failed', 'error', 'cancelled'].contains(status)) {
          throw StateError(
            (job['error'] ??
                    result['error'] ??
                    result['message'] ??
                    'Comparison failed. Please retry.')
                .toString(),
          );
        }
        if (_comparisonJobId.isEmpty && subscription == null) {
          throw StateError(
            'Unable to track the comparison. Please retry after reconnecting.',
          );
        }
        if (DateTime.now().isAfter(timeout)) {
          throw TimeoutException(
            'Comparison is still processing. Check its result later.',
          );
        }
        await Future<void>.delayed(const Duration(seconds: 2));
        if (_closed) return;
        if (socketError != null) throw StateError(socketError!);
        if (comparisonComplete.value) break;
        if (_comparisonJobId.isNotEmpty) {
          result = await repository.jobStatus(_comparisonJobId);
        }
      }
    } catch (error) {
      if (!_closed) {
        comparisonComplete.value = false;
        errorMessage.value = error is StateError
            ? error.message.toString()
            : error is TimeoutException
            ? error.message ?? 'Comparison timed out. Please retry.'
            : error.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      await subscription?.cancel();
      if (!_closed) isComparing.value = false;
    }
  }

  void openComparisonResults() {
    if (!comparisonComplete.value || isComparing.value) return;
    if (Get.isRegistered<ComparisonResultController>()) {
      Get.find<ComparisonResultController>().updateRequestIdAndReload(
        requestId.value,
      );
    }
    Get.offNamed(
      AppRoutes.comparisonResult,
      parameters: {
        'id': requestId.value,
        if (_comparisonJobId.isNotEmpty) 'jobId': _comparisonJobId,
        if (projectId.value.isNotEmpty) 'projectId': projectId.value,
        if (projectId.value.isNotEmpty) 'leadId': projectId.value,
      },
    );
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};

  String _fileNameFromUrl(String url) {
    if (url.isEmpty) return '';
    final path = Uri.tryParse(url)?.pathSegments;
    return path == null || path.isEmpty ? '' : Uri.decodeComponent(path.last);
  }
}
