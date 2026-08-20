import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class ShipperFilesRepository {
  final ApiClient apiClient;

  ShipperFilesRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchStats() =>
      _get(ApiEndpoints.plantShipperFilesStats);
  Future<Map<String, dynamic>> fetchProjects() =>
      _get(ApiEndpoints.plantShipperProjects);
  Future<Map<String, dynamic>> fetchProjectRequests(String leadId) =>
      _get(ApiEndpoints.plantProjectShipperRequests(leadId));

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await apiClient.get(path);
    final body = response.data;
    if (body is Map) {
      final data = body['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      if (data is List) {
        return <String, dynamic>{'requests': data, 'projects': data};
      }
      return Map<String, dynamic>.from(body);
    }
    return <String, dynamic>{};
  }
}
