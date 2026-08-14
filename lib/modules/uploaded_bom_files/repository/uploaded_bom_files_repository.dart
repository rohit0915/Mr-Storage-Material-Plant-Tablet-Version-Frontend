import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class UploadedBomFilesRepository {
  final ApiClient apiClient;

  UploadedBomFilesRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchStats() async {
    final response = await apiClient.get(ApiEndpoints.plantBomStats);
    return _dataMap(response.data);
  }

  Future<Map<String, dynamic>> fetchProjects({
    required int page,
    required int limit,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.plantBomProjects,
      queryParameters: {'page': page, 'limit': limit},
    );
    return _dataMap(response.data);
  }

  Map<String, dynamic> _dataMap(dynamic response) {
    if (response is Map &&
        response['success'] == true &&
        response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    return <String, dynamic>{};
  }
}
