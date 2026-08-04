import '../../../app/network/api_client.dart';
import '../api/home_api.dart';
import '../model/home_model.dart';

class HomeRepository {
  final ApiClient apiClient;

  HomeRepository({required this.apiClient});

  Future<List<HomeModel>> fetchHomeData() async {
    // In a real app, this would use apiClient
    // final response = await apiClient.get(HomeApi.getHomeData);
    // return (response.data as List).map((e) => HomeModel.fromJson(e)).toList();

    // Mock delay for demonstration
    await Future.delayed(const Duration(seconds: 1));
    return [
      HomeModel(title: 'Item 1', description: 'Description 1'),
      HomeModel(title: 'Item 2', description: 'Description 2'),
    ];
  }
}
