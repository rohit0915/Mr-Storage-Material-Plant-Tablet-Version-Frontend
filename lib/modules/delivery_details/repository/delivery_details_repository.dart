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

  Future<void> update(String id, Map<String, dynamic> body) async {
    final response = await apiClient.put('plant/deliveries/$id', data: body);
    _requireSuccess(response.data);
  }
  Future<void> reschedule(String id, Map<String, dynamic> body) async {
    final response = await apiClient.patch('plant/deliveries/$id/reschedule', data: body);
    _requireSuccess(response.data);
  }
  Future<void> updateStatus(String id, String status) async {
    final response = await apiClient.patch('plant/deliveries/$id/status', data: {'status': status});
    _requireSuccess(response.data);
  }
  void _requireSuccess(dynamic body) {
    if (body is! Map || body['success'] != true) throw Exception(body is Map ? body['message'] ?? 'Delivery update failed.' : 'Invalid delivery response.');
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
