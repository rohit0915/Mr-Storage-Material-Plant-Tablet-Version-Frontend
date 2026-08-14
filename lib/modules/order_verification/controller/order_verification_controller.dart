import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';

class OrderVerificationController extends GetxController {
  final ShipperRequestWorkflowRepository repository;
  OrderVerificationController({required this.repository});
  final RxBool isLoading = false.obs;
  final RxString requestId = ''.obs;
  final RxString bomFileName = 'Consolidated BOM'.obs;
  final RxString bomFileSize = ''.obs;
  final RxString shipperFileName = 'Shipper document'.obs;
  final RxString shipperFileSize = ''.obs;

  @override
  void onInit() {
    super.onInit();
    requestId.value = Get.parameters['id'] ?? '';
  }

  Future<void> compareFiles() async {
    if (requestId.value.isEmpty) return;
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
}
