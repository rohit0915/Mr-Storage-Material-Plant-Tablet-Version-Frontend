import 'package:get/get.dart';
import '../../modules/home/controller/home_controller.dart';
import '../../modules/home/repository/home_repository.dart';
import '../network/api_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Inject core dependencies here
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.lazyPut<HomeRepository>(
      () => HomeRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(repository: Get.find<HomeRepository>()),
      fenix: true,
    );
  }
}
