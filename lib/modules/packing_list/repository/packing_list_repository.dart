import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class PackingListRepository {
  final ApiClient apiClient;
  PackingListRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchProjects({int page = 1, int limit = 10}) =>
      _get(
        ApiEndpoints.plantPackingListProjects,
        query: {'page': page, 'limit': limit},
      );
  Future<Map<String, dynamic>> fetchPackingList(String id) =>
      _get(ApiEndpoints.plantPackingList(id));

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await apiClient.get(path, queryParameters: query);
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return <String, dynamic>{};
  }
}
