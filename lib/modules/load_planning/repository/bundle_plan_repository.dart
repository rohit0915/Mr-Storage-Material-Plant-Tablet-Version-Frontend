import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class BundlePlanRepository {
  final ApiClient apiClient;
  BundlePlanRepository({required this.apiClient});

  Future<Map<String, dynamic>> detail(String id) =>
      _get(ApiEndpoints.plantBundlePlan(id));
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> payload,
  ) => _put(ApiEndpoints.plantBundlePlan(id), payload);
  Future<Map<String, dynamic>> coverage(String id) =>
      _get(ApiEndpoints.plantBundlePlanCoverage(id));
  Future<Map<String, dynamic>> confirm(String id) =>
      _post(ApiEndpoints.plantBundlePlanConfirm(id));
  Future<Map<String, dynamic>> createBundle(
    String id,
    Map<String, dynamic> payload,
  ) => _post(ApiEndpoints.plantBundlePlanBundles(id), payload);
  Future<Map<String, dynamic>> freightAutofill(String id) =>
      _get(ApiEndpoints.plantBundlePlanFreightAutofill(id));
  Future<Map<String, dynamic>> generatePackingList(String id) =>
      _post(ApiEndpoints.plantBundlePlanGeneratePackingList(id));

  Future<Map<String, dynamic>> _get(String path) async =>
      _data((await apiClient.get(path)).data);
  Future<Map<String, dynamic>> _put(
    String path,
    Map<String, dynamic> payload,
  ) async => _data((await apiClient.put(path, data: payload)).data);
  Future<Map<String, dynamic>> _post(
    String path, [
    Map<String, dynamic>? payload,
  ]) async => _data((await apiClient.post(path, data: payload)).data);

  Map<String, dynamic> _data(dynamic body) {
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    throw Exception(body is Map ? body['message'] : 'Request failed.');
  }
}
