import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class NotificationRepository {
  final ApiClient apiClient;
  NotificationRepository({required this.apiClient});
  Future<Map<String, dynamic>> deliveryHistory(
    Map<String, dynamic> query,
  ) async {
    final response = await apiClient.get(
      'plant/notification-details',
      queryParameters: query,
    );
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data']);
    }
    throw Exception(
      body is Map
          ? body['message'] ?? 'Unable to load notification history.'
          : 'Invalid notification history response.',
    );
  }

  Future<Map<String, dynamic>> list({
    int page = 1,
    int limit = 20,
    String filter = 'All',
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.notificationList,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (filter == 'Unread') 'read': 'false',
        if (filter == 'High Priority') 'priority': 'high',
        if (filter != 'All' && filter != 'Unread' && filter != 'High Priority')
          'type': filter,
      },
    );
    final body = response.data;
    _check(body);
    if (body is Map) {
      final mapBody = Map<String, dynamic>.from(body);
      final dataField = mapBody['data'];
      if (dataField is Map) {
        return Map<String, dynamic>.from(dataField);
      } else if (dataField is List) {
        return {'notifications': dataField, ...mapBody};
      }
      return mapBody;
    } else if (body is List) {
      return {'notifications': body};
    }
    return {};
  }

  Future<void> markAllRead() async =>
      _check((await apiClient.put(ApiEndpoints.notificationReadAll)).data);
  Future<void> markRead(String id) async =>
      _check((await apiClient.put(ApiEndpoints.notificationRead(id))).data);
  Future<void> delete(String id) async => _check(
    (await apiClient.delete(ApiEndpoints.notificationDelete(id))).data,
  );
  void _check(dynamic body) {
    if (body is Map && body['success'] == false) {
      throw Exception(body['message'] ?? 'Notification action failed.');
    }
  }
}
