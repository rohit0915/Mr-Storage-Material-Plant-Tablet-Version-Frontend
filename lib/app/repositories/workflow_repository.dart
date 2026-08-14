import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class WorkflowRepository {
  final ApiClient apiClient;
  WorkflowRepository({required this.apiClient});

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _put(ApiEndpoints.changePassword, {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<Map<String, dynamic>> customers({
    String search = '',
    int page = 1,
    int limit = 20,
  }) => _get(
    ApiEndpoints.customers,
    query: {'search': search, 'page': page, 'limit': limit},
  );

  Future<Map<String, dynamic>> consolidatedBom(String leadId) =>
      _get(ApiEndpoints.plantConsolidatedBom(leadId));
  Future<Map<String, dynamic>> projectBundlePlan(String leadId) =>
      _get(ApiEndpoints.plantProjectBundlePlan(leadId));
  Future<Map<String, dynamic>> projectFreightAutofill(String leadId) =>
      _get(ApiEndpoints.plantProjectFreightAutofill(leadId));

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await apiClient.get(path, queryParameters: query);
    return _data(response.data);
  }

  Future<Map<String, dynamic>> _put(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.put(path, data: payload);
    if (response.data is Map && response.data['success'] == true) {
      return _data(response.data);
    }
    throw Exception(response.data?['message'] ?? 'Request failed.');
  }

  Map<String, dynamic> _data(dynamic body) {
    if (body is Map && body['success'] == true) {
      return body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
    }
    throw Exception(body is Map ? body['message'] : 'Request failed.');
  }
}
