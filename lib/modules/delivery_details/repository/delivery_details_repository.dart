import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class DeliveryDetailsRepository {
  final ApiClient apiClient;
  DeliveryDetailsRepository({required this.apiClient});
  Future<Map<String, dynamic>> fetchProjectDeliveries(String leadId) =>
      _get(ApiEndpoints.plantProjectDeliveries(leadId));
  Future<Map<String, dynamic>> fetchDetail(String id) =>
      _get(ApiEndpoints.plantDeliveryDetail(id));
  Future<Map<String, dynamic>> sendBids(
    String deliveryId, {
    required List<String> carrierIds,
    required DateTime bidDeadline,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.plantDeliverySendBids(deliveryId),
      data: {
        'carrierIds': carrierIds,
        'bidDeadline': bidDeadline.toUtc().toIso8601String(),
      },
    );
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    throw Exception(body is Map ? body['message'] : 'Unable to send bids.');
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await apiClient.get(path);
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return {};
  }
}
