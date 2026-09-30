import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class ShippersRepository {
  final ApiClient apiClient;
  ShippersRepository({required this.apiClient});

  Future<Map<String, dynamic>> list({
    int page = 1,
    int limit = 100,
    String? status,
    String search = '',
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.plantVendors,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search.isNotEmpty) 'search': search,
      },
    );
    return _data(response.data);
  }

  Future<Map<String, dynamic>> detail(String id) async {
    final response = await apiClient.get(ApiEndpoints.plantVendor(id));
    return _data(response.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final response = await apiClient.post(
      ApiEndpoints.plantVendors,
      data: payload,
    );
    return _data(response.data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.put(
      ApiEndpoints.plantVendor(id),
      data: payload,
    );
    return _data(response.data);
  }

  Future<Map<String, dynamic>> toggleStatus(String id) async {
    final response = await apiClient.patch(
      ApiEndpoints.plantVendorToggleStatus(id),
    );
    return _data(response.data);
  }

  Map<String, dynamic> _data(dynamic body) {
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map && body['success'] == true) return {};
    throw Exception(
      body is Map
          ? body['message'] ?? 'Request failed.'
          : 'Invalid server response.',
    );
  }
}
