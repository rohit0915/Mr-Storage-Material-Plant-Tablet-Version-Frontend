import 'package:get/get.dart';
import '../model/home_model.dart';
import '../repository/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository repository;

  HomeController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxList<HomeModel> homeData = <HomeModel>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await repository.fetchHomeData();
      homeData.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
