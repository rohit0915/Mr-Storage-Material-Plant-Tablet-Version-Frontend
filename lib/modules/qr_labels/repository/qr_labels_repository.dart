import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class QrLabelsRepository {
  final ApiClient apiClient;
  QrLabelsRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchProjects() =>
      _get(ApiEndpoints.plantPackingListProjects);
  Future<Map<String, dynamic>> fetchPackingList(String id) =>
      _get(ApiEndpoints.plantPackingList(id));
  Future<Map<String, dynamic>> fetchPackingListPlan(String planId) =>
      _get(ApiEndpoints.plantPackingListPlan(planId));

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await apiClient.get(path);
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return <String, dynamic>{};
  }
}
