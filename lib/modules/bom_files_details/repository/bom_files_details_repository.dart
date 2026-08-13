import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class BomFilesDetailsRepository {
  final ApiClient apiClient;
  BomFilesDetailsRepository({required this.apiClient});
  Future<Map<String, dynamic>> fetch(String leadId) async {
    final response = await apiClient.get(
      ApiEndpoints.plantProjectBomFiles(leadId),
    );
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return {};
  }
}
