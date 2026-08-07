import 'package:get/get.dart';
import '../controller/comparison_result_controller.dart';

class ComparisonResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComparisonResultController>(() => ComparisonResultController());
  }
}
