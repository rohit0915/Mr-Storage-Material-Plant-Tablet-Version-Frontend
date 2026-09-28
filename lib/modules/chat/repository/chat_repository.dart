import '../../../app/network/api_client.dart';
import '../../../app/network/exceptions.dart';

class ChatRepository {
  final ApiClient api;
  ChatRepository(this.api);

  Future<dynamic> _get(String path, {Map<String, dynamic>? query}) async {
    final response = await api.get(path, queryParameters: query);
    final body = response.data;
    if (body is Map && body['success'] == false) {
      throw ServerException(body['message']?.toString() ?? 'Unable to load chat.');
    }
    return body is Map && body.containsKey('data') ? body['data'] : body;
  }

  List<Map<String, dynamic>> _list(dynamic data, String key) {
    final list = data is Map ? data[key] : data;
    if (list is! List || list.any((row) => row is! Map)) {
      throw ServerException('Invalid chat response. Please retry.');
    }
    return list.map((row) => Map<String, dynamic>.from(row as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> conversations() async =>
      _list(await _get('team-chat/conversations'), 'conversations');

  Future<List<Map<String, dynamic>>> users({String search = ''}) async =>
      _list(await _get('team-chat/users', query: {'search': search}), 'users');

  Future<List<Map<String, dynamic>>> messages(String id, bool group) async {
    final result = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final data = await _get('team-chat/${group ? 'groups' : 'direct'}/${Uri.encodeComponent(id)}/messages',
          query: {'page': page, 'limit': 50});
      final rows = _list(data, 'messages');
      result.addAll(rows);
      if (data is! Map || data['hasMore'] != true || rows.isEmpty) break;
      page++;
    }
    return result;
  }

  Future<Map<String, dynamic>> group(String id) async {
    final data = await _get('team-chat/groups/${Uri.encodeComponent(id)}');
    final group = data is Map && data['group'] is Map ? data['group'] : data;
    if (group is! Map) throw ServerException('Invalid group response.');
    return Map<String, dynamic>.from(group);
  }
}
