import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

class OrderVerificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString bomFileName = 'Test_Reconciliation_Data'.obs;
  final RxString bomFileSize = '5.3MB'.obs;
  final RxString shipperFileName = '1215-USB_SHIPPER'.obs;
  final RxString shipperFileSize = '5.3MB'.obs;

  void compareFiles() {
    Get.toNamed(AppRoutes.comparisonResult);
  }
}
