import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class ShipperRequestWorkflowRepository {
  final ApiClient apiClient;
  ShipperRequestWorkflowRepository({required this.apiClient});

  Future<Map<String, dynamic>> document(String requestId) =>
      _get(ApiEndpoints.plantShipperRequestDocument(requestId));
  Future<Map<String, dynamic>> consolidatedBomUrl(String projectId) =>
      _get(ApiEndpoints.plantConsolidatedBomUrl(projectId));
  Future<Map<String, dynamic>> startComparison(String requestId) =>
      _post(ApiEndpoints.plantShipperRequestCompare(requestId));
  Future<Map<String, dynamic>> jobStatus(String jobId) =>
      _get(ApiEndpoints.plantComparisonJobStatus(jobId));
  Future<Map<String, dynamic>> batchJobStatus(List<String> jobIds) =>
      _post(ApiEndpoints.plantComparisonJobsStatus, {'jobIds': jobIds});
  Future<Map<String, dynamic>> approve(String requestId) =>
      _post(ApiEndpoints.plantShipperRequestApprove(requestId));
  Future<Map<String, dynamic>> requestResubmit(
    String requestId, {
    required String note,
    bool includeComparisonExceptions = true,
  }) => _post(ApiEndpoints.plantShipperRequestResubmit(requestId), {
    'note': note,
    'includeComparisonExceptions': includeComparisonExceptions,
  });
  Future<Map<String, dynamic>> comparisonSummary(String requestId) =>
      _get(ApiEndpoints.plantComparisonSummary(requestId));
  Future<Map<String, dynamic>> comparisonResults(
    String requestId, {
    int page = 1,
    int limit = 50,
    String category = 'all',
  }) => _get(
    ApiEndpoints.plantComparisonResults(requestId),
    query: {'page': page, 'limit': limit, 'category': category},
  );
  Future<Map<String, dynamic>> generateBundlePlan(String requestId) =>
      _post(ApiEndpoints.plantGenerateBundlePlan(requestId));
  Future<Map<String, dynamic>> projectBundlePlan(String leadId) =>
      _get(ApiEndpoints.plantProjectBundlePlan(leadId));

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await apiClient.get(path, queryParameters: query);
    return _data(response.data);
  }

  Future<Map<String, dynamic>> _post(
    String path, [
    Map<String, dynamic>? payload,
  ]) async {
    final response = await apiClient.post(path, data: payload);
    return _data(response.data);
  }

  Map<String, dynamic> _data(dynamic body) {
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    throw Exception(body is Map ? body['message'] : 'Request failed.');
  }
}
