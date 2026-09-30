import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class BomFilesDetailsRepository {
  final ApiClient apiClient;
  BomFilesDetailsRepository({required this.apiClient});

  Future<Map<String, dynamic>> fetchJob(
    String jobId, {
    required String filter,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.plantBomDetails(jobId),
      queryParameters: {'filter': filter, 'page': page, 'limit': limit},
    );
    final data = _data(response.data);
    if (data.isEmpty) throw Exception('BOM details were not returned.');
    return data;
  }

  Future<void> updateItemPrice(String itemId, double cost) async {
    final response = await apiClient.put('plant/bom/items/$itemId/price', data: {'manualUnitCost': cost, 'saveToSMDT': false});
    if (response.data is! Map || response.data['success'] != true) {
      throw Exception(response.data is Map ? response.data['message'] ?? 'Unable to save item price.' : 'Invalid price response.');
    }
  }

  Future<void> confirmBuilding(String buildingId) async {
    final response = await apiClient.post(
      ApiEndpoints.plantConfirmBuildingBom(buildingId),
    );
    if (response.data is Map && response.data['success'] == false) {
      throw Exception(response.data['message'] ?? 'Unable to confirm BOM.');
    }
  }

  Future<Map<String, dynamic>> fetch(String leadId) async {
    final responses = await Future.wait([
      apiClient.get(ApiEndpoints.plantConsolidatedBom(leadId)),
      apiClient.get(ApiEndpoints.plantProjectDetail(leadId)),
    ]);
    final consolidated = _data(responses[0].data);
    final projectDetail = _data(responses[1].data);

    return {
      'bomFiles': <String, dynamic>{},
      'consolidatedBom': consolidated,
      'projectDetail': projectDetail,
    };
  }

  Map<String, dynamic> _data(dynamic body) =>
      body is Map && body['success'] == true && body['data'] is Map
      ? Map<String, dynamic>.from(body['data'] as Map)
      : <String, dynamic>{};
}
