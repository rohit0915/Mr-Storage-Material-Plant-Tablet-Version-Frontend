import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class ProjectDetailsRepository {
  final ApiClient apiClient;

  ProjectDetailsRepository({required this.apiClient});

  Future<Map<String, dynamic>?> fetchProjectDetail(String leadId) async {
    final response = await apiClient.get(
      ApiEndpoints.plantProjectDetail(leadId),
    );
    if (response.data != null && response.data['success'] == true) {
      final data = response.data['data'];
      return data is Map ? Map<String, dynamic>.from(data) : null;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchLifecycle(String leadId) async {
    final response = await apiClient.get(
      ApiEndpoints.plantProjectLifecycle(leadId),
    );
    if (response.data != null && response.data['success'] == true) {
      final data = response.data['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      if (data is List) return <String, dynamic>{'steps': data};
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchBuildings(String leadId) async {
    final response = await apiClient.get(
      ApiEndpoints.plantProjectBuildings(leadId),
    );
    final data = response.data?['data'];
    final buildings = data is List
        ? data
        : (data is Map ? data['buildings'] : null);
    if (buildings is! List) return const [];
    return buildings
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> fetchExistingDrawings(String leadId) async {
    final response = await apiClient.get(
      ApiEndpoints.plantProjectDrawings(leadId),
    );
    final data = response.data?['data'];
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  Future<Map<String, dynamic>> createPresignedUpload({
    required String fileName,
    required String fileType,
    required String folder,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.uploadPresignedUrl,
      data: {'fileName': fileName, 'fileType': fileType, 'folder': folder},
    );
    final data = response.data?['data'];
    if (response.data?['success'] != true || data is! Map) {
      throw Exception(response.data?['message'] ?? 'Unable to prepare upload.');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
    void Function(int, int)? onProgress,
  }) async {
    await apiClient.putExternal(
      uploadUrl,
      data: bytes,
      contentType: contentType,
      onSendProgress: onProgress,
    );
  }

  Future<void> registerDrawings({
    required String leadId,
    required List<Map<String, dynamic>> drawings,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.plantProjectDrawings(leadId),
      data: {'drawings': drawings},
    );
    if (response.data?['success'] != true) {
      throw Exception(
        response.data?['message'] ?? 'Unable to register drawings.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> registerBomFiles({
    required String leadId,
    required List<Map<String, dynamic>> bomFiles,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.plantProjectBom(leadId),
      data: {'bomFiles': bomFiles},
    );
    if (response.data?['success'] != true) {
      throw Exception(
        response.data?['message'] ?? 'Unable to register BOM files.',
      );
    }
    final data = response.data?['data'];
    final jobs = data is Map ? data['jobs'] : null;
    if (jobs is! List) return const [];
    return jobs
        .whereType<Map>()
        .map((job) => Map<String, dynamic>.from(job))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchBomJobStatuses(
    List<String> jobIds,
  ) async {
    if (jobIds.isEmpty) return const [];
    final response = await apiClient.post(
      ApiEndpoints.plantBomJobsStatus,
      data: {'jobIds': jobIds},
    );
    final data = response.data?['data'];
    final jobs = data is Map ? data['jobs'] : null;
    if (jobs is! List) return const [];
    return jobs
        .whereType<Map>()
        .map((job) => Map<String, dynamic>.from(job))
        .toList();
  }

  Future<Map<String, dynamic>> generateConsolidatedBom(String leadId) async {
    final response = await apiClient.post(
      ApiEndpoints.plantGenerateConsolidatedBom(leadId),
    );
    final data = response.data?['data'];
    if (response.data?['success'] != true || data is! Map) {
      throw Exception(
        response.data?['message'] ?? 'Unable to generate consolidated BOM.',
      );
    }
    return Map<String, dynamic>.from(data);
  }

  Future<List<dynamic>?> fetchInvoices(String leadId) async {
    final response = await apiClient.get(
      ApiEndpoints.plantProjectInvoices(leadId),
    );
    if (response.data != null && response.data['success'] == true) {
      return _extractList(response.data['data'], const [
        'invoices',
        'items',
        'results',
      ]);
    }
    return null;
  }

  Future<List<dynamic>?> fetchNotes(String leadId) async {
    final response = await apiClient.get(
      ApiEndpoints.plantProjectNotes(leadId),
    );
    if (response.data != null && response.data['success'] == true) {
      return _extractList(response.data['data'], const [
        'notes',
        'leadNotes',
        'items',
        'results',
      ]);
    }
    return null;
  }

  Future<void> updateLifecycle({
    required String leadId,
    required String lifecycleStatus,
    String? note,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.plantProjectLifecycle(leadId),
      data: {
        'lifecycleStatus': lifecycleStatus,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    if (response.data == null || response.data['success'] != true) {
      throw Exception(
        response.data?['message'] ?? 'Unable to update lifecycle.',
      );
    }
  }

  Future<void> addNote({required String leadId, required String note}) async {
    final response = await apiClient.post(
      ApiEndpoints.plantProjectNotes(leadId),
      data: {'note': note.trim()},
    );
    if (response.data == null || response.data['success'] != true) {
      throw Exception(response.data?['message'] ?? 'Unable to add note.');
    }
  }

  List<dynamic>? _extractList(dynamic data, List<String> wrapperKeys) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in wrapperKeys) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return null;
  }
}
