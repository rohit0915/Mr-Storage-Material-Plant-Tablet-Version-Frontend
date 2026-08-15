import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class ItemCostRepository {
  final ApiClient apiClient;
  ItemCostRepository({required this.apiClient});

  Future<Map<String, dynamic>> stats() => _get(ApiEndpoints.smdtStats);
  Future<Map<String, dynamic>> list({
    String search = '',
    int page = 1,
    int limit = 100,
  }) => _get(
    ApiEndpoints.smdtItems,
    query: {'page': page, 'limit': limit, 'search': search},
  );
  Future<Map<String, dynamic>> add(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiEndpoints.smdtItems, data: data);
    return _data(response.data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(ApiEndpoints.smdtItem(id), data: data);
    return _data(response.data);
  }

  Future<Uint8List> export({String search = '', String category = ''}) async {
    final response = await apiClient.get(
      ApiEndpoints.smdtExport,
      queryParameters: {
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (category.trim().isNotEmpty) 'category': category.trim(),
      },
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    throw Exception('Excel file was not returned.');
  }

  Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    final response = await apiClient.get(endpoint, queryParameters: query);
    return _data(response.data);
  }

  Map<String, dynamic> _data(dynamic body) {
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    return {};
  }
}
