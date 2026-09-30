import 'package:dio/dio.dart';
import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class LoadPlanningRepository {
  final ApiClient apiClient;
  LoadPlanningRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchProjects({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    return _get(
      ApiEndpoints.plantLoadPlanningProjects,
      query: {
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
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

  Future<Map<String, dynamic>> saveFreightDelivery(
    Map<String, dynamic> payload, {
    String? deliveryId,
  }) async {
    final response = deliveryId == null
        ? await apiClient.post('plant/deliveries', data: payload)
        : await apiClient.put('plant/deliveries/$deliveryId', data: payload);
    return _freightData(response.data);
  }

  Future<void> sendProjectFreightBids(
    String deliveryId,
    List<String> carriers,
    String deadline, {
    String? projectId,
  }) async {
    final payload = {'carrierIds': carriers, 'bidDeadline': deadline};
    if (projectId != null && projectId.isNotEmpty) {
      try {
        final response = await apiClient.post(
          ApiEndpoints.plantProjectFreightSendBids(projectId),
          data: payload,
        );
        _freightData(response.data);
        return;
      } catch (e) {
        final isNotFound = e is DioException &&
            (e.response?.statusCode == 404 || e.response?.statusCode == 405);
        if (!isNotFound || deliveryId.isEmpty) {
          rethrow;
        }
      }
    }
    final response = await apiClient.post(
      ApiEndpoints.plantDeliverySendBids(deliveryId),
      data: payload,
    );
    _freightData(response.data);
  }

  Map<String, dynamic> _freightData(dynamic body) {
    if (body is! Map || body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Freight request failed.'
            : 'Invalid freight response.',
      );
    }
    final data = body['data'];
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in ['_id', 'id', 'deliveryId', 'requestId', 'delivery', 'result', 'load']) {
        if (!map.containsKey(key) && body[key] != null) {
          map[key] = body[key];
        }
      }
      return map;
    }
    if (data is String && data.trim().isNotEmpty) {
      return <String, dynamic>{
        '_id': data.trim(),
        'id': data.trim(),
        'deliveryId': data.trim(),
        ...Map<String, dynamic>.from(body),
      };
    }
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    return Map<String, dynamic>.from(body);
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await apiClient.get(path, queryParameters: query);
    final body = response.data;
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    throw Exception(
      body is Map
          ? body['message'] ?? 'Unable to load planning data.'
          : 'Invalid planning response.',
    );
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
