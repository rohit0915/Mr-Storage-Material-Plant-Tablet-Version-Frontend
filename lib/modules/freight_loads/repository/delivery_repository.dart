import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';

class DeliveryRepository {
  final ApiClient apiClient;
  DeliveryRepository({required this.apiClient});

  Future<Map<String, dynamic>> freightStats() =>
      _getMap(ApiEndpoints.plantFreightStats);

  Future<Map<String, dynamic>> freightLoads({
    int page = 1,
    int limit = 100,
    String? search,
    String? status,
  }) => _getMap(
    ApiEndpoints.plantFreightLoads,
    query: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty && status != 'All')
        'status': _apiStatus(status),
    },
  );

  Future<Map<String, dynamic>> awardedStats() =>
      _getMap(ApiEndpoints.plantAwardedStats);

  Future<Map<String, dynamic>> awardedLoads({
    int page = 1,
    int limit = 100,
    String? search,
    String? status,
  }) => _getMap(
    ApiEndpoints.plantAwardedLoads,
    query: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty && status != 'All')
        'status': _apiStatus(status),
    },
  );

  Future<Map<String, dynamic>> calendar({
    required DateTime from,
    required DateTime to,
  }) => _getMap(
    ApiEndpoints.plantDeliveryCalendar,
    query: {'fromDate': _date(from), 'toDate': _date(to)},
  );

  Future<Map<String, dynamic>> allStats() =>
      _getMap(ApiEndpoints.plantDeliveriesStats);

  Future<Map<String, dynamic>> freightDetail(String deliveryId) async {
    try {
      return await _getMap(ApiEndpoints.plantDeliveryDetail(deliveryId));
    } catch (_) {
      return await _getMap('${ApiEndpoints.plantFreightLoads}/$deliveryId');
    }
  }

  Future<Map<String, dynamic>> bids(String deliveryId) => _getMap(
    ApiEndpoints.plantDeliveryBids(deliveryId),
    query: const {'sort': 'low_to_high'},
  );

  Future<void> selectBid(String bidId) async {
    final response = await apiClient.post(
      ApiEndpoints.plantFreightBidSelect(bidId),
    );
    if (response.data?['success'] != true) {
      throw Exception(response.data?['message'] ?? 'Unable to award bid.');
    }
  }

  Future<void> requestBidResubmit(
    String bidId, {
    required double targetAmount,
    required String message,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.plantFreightBidResubmit(bidId),
      data: {'targetAmount': targetAmount, 'message': message},
    );
    if (response.data?['success'] != true) {
      throw Exception(
        response.data?['message'] ?? 'Unable to request resubmit.',
      );
    }
  }

  Future<Map<String, dynamic>> allDeliveries({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) => _getMap(
    ApiEndpoints.plantAllDeliveries,
    query: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty && status != 'All Status')
        'status': _apiStatus(status),
    },
  );

  Future<Map<String, dynamic>> _getMap(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    final response = await apiClient.get(endpoint, queryParameters: query);
    final body = response.data;
    if (body is Map) {
      final mapBody = Map<String, dynamic>.from(body);
      final dataField = mapBody['data'];
      if (dataField is Map) {
        return Map<String, dynamic>.from(dataField);
      } else if (dataField is List) {
        return {'dates': dataField, 'calendar': dataField, 'deliveries': dataField, 'items': dataField, ...mapBody};
      }
      return mapBody;
    } else if (body is List) {
      return {'dates': body, 'calendar': body, 'deliveries': body, 'items': body};
    }
    return {};
  }

  String _date(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _apiStatus(String status) =>
      status.trim().toLowerCase().replaceAll(' ', '_');
}
