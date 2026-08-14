import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class BomFilesDetailsRepository {
  final ApiClient apiClient;
  BomFilesDetailsRepository({required this.apiClient});
  Future<Map<String, dynamic>> fetch(String leadId) async {
    final responses = await Future.wait([
      apiClient.get(ApiEndpoints.plantProjectBomFiles(leadId)),
      apiClient.get(ApiEndpoints.plantConsolidatedBom(leadId)),
    ]);
    final buildingData = _data(responses[0].data);
    final consolidated = _data(responses[1].data);
    buildingData['consolidatedBom'] = consolidated;
    return buildingData;
  }

  Map<String, dynamic> _data(dynamic body) =>
      body is Map && body['success'] == true && body['data'] is Map
      ? Map<String, dynamic>.from(body['data'] as Map)
      : <String, dynamic>{};
}
