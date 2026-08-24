import 'dart:async';

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../utils/app_constants.dart';
import '../utils/app_logger.dart';
import '../widgets/common_snackbar.dart';
import '../widgets/shipper_file_received_dialog.dart';
import 'shared_pref_service.dart';

class PlantSocketEvent {
  final String name;
  final Map<String, dynamic> payload;

  const PlantSocketEvent(this.name, this.payload);
}

class PlantSocketService extends GetxService {
  static const plantEvents = <String>{
    'project_assigned',
    'bom_extraction_complete',
    'bom_extraction_failed',
    'bom_review_complete',
    'shipper_file_submitted',
    'all_shipper_files_submitted',
    'shipper_comparison_complete',
    'shipper_comparison_failed',
    'freight_bid_submitted',
    'all_freight_bids_submitted',
  };
  static const teamEvents = <String>{
    'new_team_message',
    'new_team_dm_notice',
    'team_typing',
    'team_chat_error',
  };

  final isConnected = false.obs;
  final connectionError = ''.obs;
  final _events = StreamController<PlantSocketEvent>.broadcast();
  final _activeTeamChannels = <String, Map<String, String>>{};
  io.Socket? _socket;

  Stream<PlantSocketEvent> get events => _events.stream;

  void connect() {
    if (!Get.isRegistered<SharedPrefService>()) return;
    final token = Get.find<SharedPrefService>().getToken();
    if (token == null || token.isEmpty) return;

    disconnect();
    final socket = io.io(
      '${AppConstants.serverOrigin}/admin',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      isConnected.value = true;
      connectionError.value = '';
      // The room is auto-joined by the server; this makes reconnect intent
      // explicit and is safe according to the backend handoff.
      socket.emit('join_user_room', <String, dynamic>{});
      for (final channel in _activeTeamChannels.values) {
        socket.emit('join_team_channel', channel);
      }
      AppLogger.debug('Plant socket connected');
    });
    socket.onDisconnect((_) {
      isConnected.value = false;
      AppLogger.debug('Plant socket disconnected');
    });
    socket.onConnectError((error) {
      isConnected.value = false;
      connectionError.value = error?.toString() ?? 'Socket connection failed';
      AppLogger.error('Plant socket connect error: $error');
    });
    socket.onError((error) {
      AppLogger.error('Plant socket error: $error');
    });
    for (final eventName in plantEvents) {
      socket.on(eventName, (data) => _handleEvent(eventName, data));
    }
    for (final eventName in teamEvents) {
      socket.on(eventName, (data) => _handleTeamEvent(eventName, data));
    }
    socket.connect();
  }

  void reconnectWithLatestToken() => connect();

  StreamSubscription<PlantSocketEvent> listenFor(
    Set<String> eventNames,
    FutureOr<void> Function(PlantSocketEvent event) listener,
  ) =>
      events.where((event) => eventNames.contains(event.name)).listen(listener);

  void joinTeamChannel(String channelType, String channelId) {
    final payload = {'channelType': channelType, 'channelId': channelId};
    _activeTeamChannels['$channelType:$channelId'] = payload;
    _socket?.emit('join_team_channel', payload);
  }

  void leaveTeamChannel(String channelType, String channelId) {
    _activeTeamChannels.remove('$channelType:$channelId');
    _socket?.emit('leave_team_channel', {
      'channelType': channelType,
      'channelId': channelId,
    });
  }

  bool sendTeamMessage(String channelType, String channelId, String content) {
    if (!isConnected.value || content.trim().isEmpty) return false;
    _socket?.emit('team_message', {
      'channelType': channelType,
      'channelId': channelId,
      'content': content.trim(),
    });
    return true;
  }

  void setTeamTyping(String channelType, String channelId, bool typing) =>
      _socket?.emit(typing ? 'team_typing_start' : 'team_typing_stop', {
        'channelType': channelType,
        'channelId': channelId,
      });

  void _handleEvent(String name, dynamic data) {
    final payload = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{'data': data};
    _events.add(PlantSocketEvent(name, payload));
    if (name == 'shipper_file_submitted') {
      final vendorName = (payload['vendorName'] ?? payload['shipperName'] ?? payload['name'] ?? 'Namra').toString();
      final quoteVal = (payload['quoteValue'] ?? payload['amount'] ?? payload['rate'] ?? '\$100,000').toString();
      final leadId = (payload['leadId'] ?? payload['projectId'] ?? '').toString();
      final requestId = (payload['requestId'] ?? payload['shipperFileId'] ?? payload['id'] ?? payload['_id'] ?? '').toString();
      ShipperFileReceivedDialog.show(
        vendorName: vendorName,
        quoteValue: quoteVal,
        leadId: leadId.isNotEmpty ? leadId : null,
        requestId: requestId.isNotEmpty ? requestId : null,
      );
    }
  }

  void _handleTeamEvent(String name, dynamic data) {
    final payload = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{'data': data};
    _events.add(PlantSocketEvent(name, payload));
    if (name == 'new_team_dm_notice') {
      CommonSnackbar.showSuccess(
        title: payload['fromName']?.toString() ?? 'New message',
        message: payload['content']?.toString() ?? 'New direct message.',
      );
    } else if (name == 'team_chat_error') {
      CommonSnackbar.showError(
        title: 'Chat error',
        message: payload['message']?.toString() ?? 'Unable to update chat.',
      );
    }
  }

  void disconnect() {
    final socket = _socket;
    if (socket != null) {
      for (final eventName in plantEvents) {
        socket.off(eventName);
      }
      for (final eventName in teamEvents) {
        socket.off(eventName);
      }
      socket.dispose();
    }
    _socket = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    _events.close();
    super.onClose();
  }
}
