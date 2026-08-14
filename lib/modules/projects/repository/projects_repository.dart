import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class ProjectsRepository {
  final ApiClient apiClient;

  ProjectsRepository({required this.apiClient});

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

  Future<Map<String, dynamic>?> fetchProjects({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? buildingType,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null && status.isNotEmpty && status != 'All' && !status.startsWith('Select')) {
      params['status'] = status.toLowerCase();
    }
    if (buildingType != null && buildingType.isNotEmpty && !buildingType.startsWith('Building')) {
      params['buildingType'] = buildingType.toLowerCase();
    }

    final response = await apiClient.get(
      ApiEndpoints.plantProjects,
      queryParameters: params,
    );
    if (response.data != null && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>?;
    }
    return null;
  }
}
