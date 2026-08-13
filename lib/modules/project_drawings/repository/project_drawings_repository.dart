import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class ProjectDrawingsRepository {
  final ApiClient apiClient;
  ProjectDrawingsRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchDrawings(String leadId) async {
    final response = await apiClient.get(
      ApiEndpoints.plantProjectDrawings(leadId),
    );
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return {};
  }
}
