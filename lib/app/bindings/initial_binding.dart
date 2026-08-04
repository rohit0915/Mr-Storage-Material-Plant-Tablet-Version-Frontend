import 'package:get/get.dart';
import '../network/api_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Inject core dependencies here (e.g., ApiClient)
    Get.put<ApiClient>(ApiClient(), permanent: true);
  }
}
