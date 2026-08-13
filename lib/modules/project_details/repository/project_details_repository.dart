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
