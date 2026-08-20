import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class LoadPlanningRepository {
  final ApiClient apiClient;
  LoadPlanningRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchProjects({
    int page = 1,
    int limit = 10,
  }) async {
    return _get(
      ApiEndpoints.plantLoadPlanningProjects,
      query: {'page': page, 'limit': limit},
    );
  }

  Future<Map<String, dynamic>> fetchProjectPlanning(String leadId) async {
    return _get(ApiEndpoints.plantProjectLoadPlanning(leadId));
  }

  Future<Map<String, dynamic>> fetchProjectTruckPlan(String leadId) async {
    return _get(ApiEndpoints.plantProjectTruckPlan(leadId));
  }

  Future<Map<String, dynamic>> fetchPackingListPlan(String id) =>
      _get(ApiEndpoints.plantPackingListPlan(id));

  Future<Map<String, dynamic>> confirmPackingListPlan(String id) =>
      _post(ApiEndpoints.plantPackingListPlanConfirm(id));

  Future<Map<String, dynamic>> confirmProjectBundles(String leadId) =>
      _post(ApiEndpoints.plantProjectConfirmBundles(leadId));

  Future<Map<String, dynamic>> generateProjectTruckPlan(String leadId) =>
      _post(ApiEndpoints.plantProjectGenerateTruckPlan(leadId));

  Future<Map<String, dynamic>> confirmProjectTruckPlan(String leadId) =>
      _post(ApiEndpoints.plantProjectConfirmTruckPlan(leadId));

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

  Future<Map<String, dynamic>> _post(String path) async {
    final response = await apiClient.post(path);
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map && body['success'] == true) return <String, dynamic>{};
    throw Exception(body is Map ? body['message'] : 'Request failed.');
  }
}
