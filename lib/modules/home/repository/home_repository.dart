import '../../../app/network/api_client.dart';
import '../model/home_model.dart';

class HomeRepository {
  final ApiClient apiClient;

  HomeRepository({required this.apiClient});

  Future<List<HomeModel>> fetchHomeData() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      HomeModel(title: 'Item 1', description: 'Description 1'),
      HomeModel(title: 'Item 2', description: 'Description 2'),
    ];
  }
}
