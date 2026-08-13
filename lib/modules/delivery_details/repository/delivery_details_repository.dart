import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class DeliveryDetailsRepository {
  final ApiClient apiClient;
  DeliveryDetailsRepository({required this.apiClient});
  Future<Map<String, dynamic>> fetchProjectDeliveries(String leadId) =>
      _get(ApiEndpoints.plantProjectDeliveries(leadId));
  Future<Map<String, dynamic>> fetchDetail(String id) =>
      _get(ApiEndpoints.plantDeliveryDetail(id));
  Future<Map<String, dynamic>> _get(String path) async {
    final response = await apiClient.get(path);
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return {};
  }
}
