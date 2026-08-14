import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../controller/qr_labels_controller.dart';
import '../repository/qr_labels_repository.dart';

class QrLabelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrLabelsRepository>(
      () => QrLabelsRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<QrLabelsController>(
      () => QrLabelsController(repository: Get.find<QrLabelsRepository>()),
    );
  }
}
