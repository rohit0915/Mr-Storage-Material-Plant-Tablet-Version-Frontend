import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class NotificationRepository {
  final ApiClient apiClient;
  NotificationRepository({required this.apiClient});
  Future<Map<String, dynamic>> list() async {
    final response = await apiClient.get(ApiEndpoints.notificationList);
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return {};
  }

  Future<void> markAllRead() => apiClient.put(ApiEndpoints.notificationReadAll);
  Future<void> markRead(String id) =>
      apiClient.put(ApiEndpoints.notificationRead(id));
  Future<void> delete(String id) =>
      apiClient.delete(ApiEndpoints.notificationDelete(id));
}
