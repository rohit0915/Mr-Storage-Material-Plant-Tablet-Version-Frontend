import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class ShipperFilesRepository {
  final ApiClient apiClient;

  ShipperFilesRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchStats() =>
      _get(ApiEndpoints.plantShipperFilesStats);
  Future<Map<String, dynamic>> fetchProjects({
    int page = 1,
    int limit = 10,
    String search = '',
  }) => _get(
    ApiEndpoints.plantShipperProjects,
    query: {
      'page': page,
      'limit': limit,
      if (search.trim().isNotEmpty) 'search': search.trim(),
    },
  );
  Future<Map<String, dynamic>> fetchProjectRequests(String leadId) =>
      _get(ApiEndpoints.plantProjectShipperRequests(leadId));

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await apiClient.get(path, queryParameters: query);
    final body = response.data;
    if (body is Map && body['success'] == false) {
      throw Exception(body['message'] ?? 'Unable to load shipper files.');
    }
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
