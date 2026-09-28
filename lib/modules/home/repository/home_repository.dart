import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';
import '../../../app/network/exceptions.dart';

class HomeRepository {
  final ApiClient apiClient;

  HomeRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await apiClient.get(ApiEndpoints.plantDashboard);
    final body = response.data;
    if (body is! Map || body['success'] != true || body['data'] is! Map) {
      throw ServerException(body is Map
          ? body['message']?.toString() ?? 'Invalid dashboard response.'
          : 'Invalid dashboard response.');
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  Future<Map<String, dynamic>?> fetchProjectStats({String? filter}) async {
    final Map<String, dynamic> params = {};
    if (filter != null && filter.isNotEmpty) params['filter'] = filter;
    final response = await apiClient.get(
      ApiEndpoints.plantProjectStats,
      queryParameters: params,
    );
    if (response.data != null && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchProjects({int page = 1, int limit = 10, String? filter}) async {
    final Map<String, dynamic> params = {'page': page, 'limit': limit};
    if (filter != null && filter.isNotEmpty) params['filter'] = filter;
    final response = await apiClient.get(
      ApiEndpoints.plantProjects,
      queryParameters: params,
    );
    if (response.data != null && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchShipperFilesStats({String? filter}) async {
    final Map<String, dynamic> params = {};
    if (filter != null && filter.isNotEmpty) params['filter'] = filter;
    final response = await apiClient.get(
      ApiEndpoints.plantShipperFilesStats,
      queryParameters: params,
    );
    if (response.data != null && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchBomStats({String? filter}) async {
    final Map<String, dynamic> params = {};
    if (filter != null && filter.isNotEmpty) params['filter'] = filter;
    final response = await apiClient.get(
      ApiEndpoints.plantBomStats,
      queryParameters: params,
    );
    if (response.data != null && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchDeliveriesStats({String? filter}) async {
    final Map<String, dynamic> params = {};
    if (filter != null && filter.isNotEmpty) params['filter'] = filter;
    final response = await apiClient.get(
      ApiEndpoints.plantDeliveriesStats,
      queryParameters: params,
    );
    if (response.data != null && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchNotifications({int page = 1, int limit = 10}) async {
    final response = await apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'limit': limit},
    );
    if (response.data != null && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>?;
    }
    return null;
  }
}
