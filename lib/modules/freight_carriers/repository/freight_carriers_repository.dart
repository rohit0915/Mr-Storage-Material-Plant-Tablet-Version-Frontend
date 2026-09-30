import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class FreightCarriersRepository {
  final ApiClient apiClient;
  FreightCarriersRepository({required this.apiClient});

  Future<Map<String, dynamic>> list({
    int page = 1,
    int limit = 100,
    String? status,
    String search = '',
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.plantCarriers,
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
    final response = await apiClient.get(ApiEndpoints.plantCarrier(id));
    return _data(response.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final response = await apiClient.post(
      ApiEndpoints.plantCarriers,
      data: payload,
    );
    return _data(response.data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.put(
      ApiEndpoints.plantCarrier(id),
      data: payload,
    );
    return _data(response.data);
  }

  Future<Map<String, dynamic>> toggleStatus(String id) async {
    final response = await apiClient.patch(
      ApiEndpoints.plantCarrierToggleStatus(id),
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
