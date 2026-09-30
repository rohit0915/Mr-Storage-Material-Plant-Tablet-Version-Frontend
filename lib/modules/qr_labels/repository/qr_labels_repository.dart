import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class QrLabelsRepository {
  final ApiClient apiClient;
  QrLabelsRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchProjects() async {
    final projects = <dynamic>[];
    for (var page = 1; ; page++) {
      final response = await apiClient.get(
        ApiEndpoints.plantPackingListProjects,
        queryParameters: {'page': page, 'limit': 100},
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        throw Exception('Unable to load QR projects.');
      }
      final data = body['data'] as Map;
      final rows = data['projects'] as List? ?? [];
      projects.addAll(rows);
      final total = int.tryParse('${data['total']}');
      if (rows.isEmpty ||
          (total != null ? projects.length >= total : rows.length < 100)) {
        break;
      }
    }
    return {'projects': projects};
  }

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
    throw Exception(
      body is Map
          ? body['message'] ?? 'Invalid QR label response.'
          : 'Invalid QR label response.',
    );
  }
}
