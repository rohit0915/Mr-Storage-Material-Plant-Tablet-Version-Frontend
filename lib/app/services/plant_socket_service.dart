import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../routes/app_routes.dart';
import '../utils/app_constants.dart';
import '../utils/app_logger.dart';
import '../widgets/common_snackbar.dart';
import '../widgets/project_assigned_dialog.dart';
import '../widgets/shipper_file_received_dialog.dart';
import '../widgets/freight_bid_submitted_dialog.dart';
import 'shared_pref_service.dart';

class PlantSocketEvent {
  final String name;
  final Map<String, dynamic> payload;

  const PlantSocketEvent(this.name, this.payload);

  String? get leadId => (payload['leadId'] ?? payload['projectId'] ?? payload['id'])?.toString();
  String? get requestId => (payload['requestId'] ?? payload['shipperFileId'])?.toString();
  String? get jobId => payload['jobId']?.toString();
  String? get deliveryId => payload['deliveryId']?.toString();
}

class PlantSocketService extends GetxService {
  /// Core plant operational events
  static const plantEvents = <String>{
    'project_assigned',
    'new_project_assigned',
    'project_created',
    'lead_assigned',
    'bom_extraction_complete',
    'bom_extraction_failed',
    'bom_review_complete',
    'shipper_file_submitted',
    'all_shipper_files_submitted',
    'shipper_comparison_complete',
    'shipper_comparison_failed',
    'freight_bid_submitted',
    'all_freight_bids_submitted',
    'drawing_status_updated',
    'drawing_comment_added',
    'new_po_order',
    'payment_proof_submitted',
    'new_escalation',
    'followup:reminder',
  };

  /// Lead and pipeline realtime events
  static const leadEvents = <String>{
    'lead_list_created',
    'lead_list_updated',
    'lead_score_updated',
    'lead_quote_ready',
    'lead_no_sales_available',
    'customer_online_status',
    'new_customer_message',
    'staff_online_status',
    'lead_handed_to_sales',
  };

  /// Chat room & messaging events
  static const chatEvents = <String>{
    'chat_status',
    'chat_ended',
    'chat_reopened',
    'new_message',
    'ai_typing',
    'sales_typing',
    'customer_typing',
    'staff_chat_active',
    'chat_error',
  };

  /// Team internal chat events
  static const teamEvents = <String>{
    'new_team_message',
    'new_team_dm_notice',
    'team_typing',
    'team_chat_error',
    'new_team_group_message_notice',
    'new_team_group',
    'group_members_updated',
  };

  /// AI script coaching events
  static const aiScriptEvents = <String>{
    'ai_script:sessions',
    'ai_script:session',
    'ai_script:typing',
    'ai_script:chunk',
    'ai_script:done',
    'ai_script:error',
  };

  /// Auth and server error events
  static const authEvents = <String>{
    'auth:deactivated',
    'error',
  };

  /// Complete set of all supported socket events from frontend-socket-api-reference.md
  static const allSupportedEvents = <String>{
    ...plantEvents,
    ...leadEvents,
    ...chatEvents,
    ...teamEvents,
    ...aiScriptEvents,
    ...authEvents,
  };

  final isConnected = false.obs;
  final connectionError = ''.obs;
  final _events = StreamController<PlantSocketEvent>.broadcast();
  final _activeTeamChannels = <String, Map<String, String>>{};
  final _activeLeadChats = <String>{};
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
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .setQuery({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      isConnected.value = true;
      connectionError.value = '';
      // The room is auto-joined by the server; this makes reconnect intent explicit
      socket.emit('join_user_room', <String, dynamic>{});
      for (final channel in _activeTeamChannels.values) {
        socket.emit('join_team_channel', channel);
      }
      for (final leadId in _activeLeadChats) {
        socket.emit('join_lead_chat', {'leadId': leadId});
      }
      AppLogger.debug('Plant socket connected to /admin');
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

    // Register listeners for all supported events
    for (final eventName in allSupportedEvents) {
      socket.on(eventName, (data) => _handleEvent(eventName, data));
    }

    socket.connect();
  }

  void reconnectWithLatestToken() => connect();

  StreamSubscription<PlantSocketEvent> listenFor(
    Set<String> eventNames,
    FutureOr<void> Function(PlantSocketEvent event) listener,
  ) =>
      events.where((event) => eventNames.contains(event.name)).listen(listener);

  // Client -> Server Emitters (from Section 3 & 5 of frontend-socket-api-reference.md)

  void joinUserRoom() {
    _socket?.emit('join_user_room', <String, dynamic>{});
  }

  void joinLeadChat(String leadId) {
    if (leadId.isEmpty) return;
    _activeLeadChats.add(leadId);
    _socket?.emit('join_lead_chat', {'leadId': leadId});
  }

  void leaveLeadChat(String leadId) {
    _activeLeadChats.remove(leadId);
    _socket?.emit('leave_lead_chat', {'leadId': leadId});
  }

  void endLeadChat(String leadId) {
    if (leadId.isEmpty) return;
    _socket?.emit('end_lead_chat', {'leadId': leadId});
  }

  void reopenLeadChat(String leadId) {
    if (leadId.isEmpty) return;
    _socket?.emit('reopen_lead_chat', {'leadId': leadId});
  }

  bool sendSalesMessage(String leadId, String content) {
    if (!isConnected.value || content.trim().isEmpty || leadId.isEmpty) return false;
    _socket?.emit('sales_message', {
      'leadId': leadId,
      'content': content.trim(),
    });
    return true;
  }

  void markMessagesRead(String leadId) {
    if (leadId.isEmpty) return;
    _socket?.emit('mark_messages_read', {'leadId': leadId});
  }

  void setSalesTyping(String leadId, bool isTyping) {
    if (leadId.isEmpty) return;
    _socket?.emit(isTyping ? 'sales_typing_start' : 'sales_typing_stop', {
      'leadId': leadId,
    });
  }

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

  bool sendTeamMessage(String channelType, String channelId, String content, [List<Map<String, dynamic>>? attachments]) {
    if (!isConnected.value || (content.trim().isEmpty && (attachments == null || attachments.isEmpty))) return false;
    final payload = <String, dynamic>{
      'channelType': channelType,
      'channelId': channelId,
      'content': content.trim(),
    };
    if (attachments != null && attachments.isNotEmpty) {
      payload['attachments'] = attachments;
    }
    _socket?.emit('team_message', payload);
    return true;
  }

  void setTeamTyping(String channelType, String channelId, bool typing) =>
      _socket?.emit(typing ? 'team_typing_start' : 'team_typing_stop', {
        'channelType': channelType,
        'channelId': channelId,
      });

  void aiScriptList() {
    _socket?.emit('ai_script:list', <String, dynamic>{});
  }

  void aiScriptStart({String? leadId, String? sessionId}) {
    _socket?.emit('ai_script:start', {
      if (leadId != null && leadId.isNotEmpty) 'leadId': leadId,
      if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
    });
  }

  void aiScriptMessage(String content, {String? sessionId, String? leadId}) {
    if (content.trim().isEmpty) return;
    _socket?.emit('ai_script:message', {
      'content': content.trim(),
      if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
      if (leadId != null && leadId.isNotEmpty) 'leadId': leadId,
    });
  }

  void aiScriptEnd(String sessionId) {
    if (sessionId.isEmpty) return;
    _socket?.emit('ai_script:end', {'sessionId': sessionId});
  }

  // Server -> Client Event Handler
  void _handleEvent(String name, dynamic data) {
    final payload = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{'data': data};
    _events.add(PlantSocketEvent(name, payload));
    AppLogger.debug('Plant socket received event: $name with data: $payload');

    switch (name) {
      // 1. Account Deactivation
      case 'auth:deactivated':
        disconnect();
        if (Get.isRegistered<SharedPrefService>()) {
          Get.find<SharedPrefService>().clearSession();
        }
        if (Get.context != null) {
          Get.dialog(
            PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text('Account Deactivated'),
                content: Text(payload['message']?.toString() ??
                    'Your account is deactivated. Please contact support.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.offAllNamed(AppRoutes.login);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            barrierDismissible: false,
          );
        }
        break;

      // 2. Project Assignment
      case 'project_assigned':
      case 'new_project_assigned':
      case 'project_created':
      case 'lead_assigned':
        final projectMap = payload['project'] is Map
            ? Map<String, dynamic>.from(payload['project'] as Map)
            : (payload['data'] is Map
                ? Map<String, dynamic>.from(payload['data'] as Map)
                : (payload['lead'] is Map
                    ? Map<String, dynamic>.from(payload['lead'] as Map)
                    : null));
        final projectName = (payload['projectName'] ??
                payload['title'] ??
                payload['name'] ??
                projectMap?['projectName'] ??
                projectMap?['name'] ??
                projectMap?['title'] ??
                'New Project')
            .toString();
        final poNumber = (payload['poNumber'] ??
                payload['po'] ??
                payload['jobId'] ??
                projectMap?['poNumber'] ??
                projectMap?['po'] ??
                projectMap?['jobId'] ??
                '')
            .toString();
        final projectId = (payload['projectId'] ??
                payload['leadId'] ??
                payload['id'] ??
                payload['_id'] ??
                projectMap?['projectId'] ??
                projectMap?['leadId'] ??
                projectMap?['_id'] ??
                projectMap?['id'] ??
                '')
            .toString();

        ProjectAssignedDialog.show(
          projectName: projectName,
          poNumber: poNumber.isNotEmpty ? poNumber : null,
          projectId: projectId.isNotEmpty ? projectId : null,
        );
        break;

      // 3. Shipper Vendor Uploads
      case 'shipper_file_submitted':
        final vendorName = (payload['vendorName'] ?? payload['shipperName'] ?? payload['name'] ?? 'Shipper').toString();
        final quoteVal = (payload['quoteValue'] ?? payload['amount'] ?? payload['rate'] ?? 'Not provided').toString();
        final leadId = (payload['leadId'] ?? payload['projectId'] ?? '').toString();
        final requestId = (payload['requestId'] ?? payload['shipperFileId'] ?? payload['id'] ?? payload['_id'] ?? '').toString();
        ShipperFileReceivedDialog.show(
          vendorName: vendorName,
          quoteValue: quoteVal,
          leadId: leadId.isNotEmpty ? leadId : null,
          requestId: requestId.isNotEmpty ? requestId : null,
        );
        break;

      case 'all_shipper_files_submitted':
        final vendorCount = payload['vendorCount'] ?? 'All';
        CommonSnackbar.showSuccess(
          title: 'All Shipper Quotes Received',
          message: '$vendorCount vendor quote(s) have been submitted.',
        );
        break;

      case 'shipper_comparison_complete':
        // The comparison screen handles the result after validating the job.
        break;

      case 'shipper_comparison_failed':
        final err = payload['error']?.toString() ?? 'Comparison engine error.';
        CommonSnackbar.showError(
          title: 'Comparison Failed',
          message: err,
        );
        break;

      // 4. Freight Bids
      case 'freight_bid_submitted':
        final carrierName = (payload['carrierName'] ??
                payload['carrier']?['companyName'] ??
                payload['carrier']?['name'] ??
                'Carrier')
            .toString();
        final quotedAmount =
            payload['quotedAmount'] ?? payload['amount'] ?? payload['bidAmount'] ?? '';
        final deliveryNumber =
            (payload['deliveryNumber'] ?? payload['delivery_number'] ?? '').toString();
        final pName = (payload['projectName'] ??
                payload['project_name'] ??
                payload['project']?['name'] ??
                '')
            .toString();
        final deliveryId = (payload['deliveryId'] ??
                payload['delivery_id'] ??
                payload['id'] ??
                payload['_id'] ??
                '')
            .toString();
        final bidId = (payload['bidId'] ?? payload['bid_id'] ?? '').toString();
        final leadId = (payload['leadId'] ?? payload['lead_id'] ?? '').toString();

        FreightBidSubmittedDialog.show(
          carrierName: carrierName,
          quotedAmount: quotedAmount,
          deliveryNumber: deliveryNumber,
          projectName: pName,
          deliveryId: deliveryId.isNotEmpty ? deliveryId : null,
          bidId: bidId.isNotEmpty ? bidId : null,
          leadId: leadId.isNotEmpty ? leadId : null,
        );
        break;

      case 'all_freight_bids_submitted':
        final bidCount = payload['bidCount'] ?? 'All';
        final deliveryNumber = payload['deliveryNumber']?.toString() ?? '';
        CommonSnackbar.showSuccess(
          title: 'All Freight Bids Received',
          message: 'All $bidCount bids received for delivery $deliveryNumber. Ready to award.',
        );
        break;

      // 5. BOM Processing
      case 'bom_extraction_complete':
        final bNum = payload['buildingNumber'] ?? '1';
        final matched = payload['matchedItems'] ?? '0';
        final total = payload['totalItems'] ?? '0';
        CommonSnackbar.showSuccess(
          title: 'BOM Extraction Complete',
          message: 'Building #$bNum: $matched/$total items matched successfully.',
        );
        break;

      case 'bom_extraction_failed':
        final bNum = payload['buildingNumber'] ?? '1';
        final err = payload['error']?.toString() ?? 'Parse failed';
        CommonSnackbar.showError(
          title: 'BOM Extraction Failed',
          message: 'Building #$bNum: $err',
        );
        break;

      case 'bom_review_complete':
        final bNum = payload['buildingNumber'] ?? '1';
        final action = payload['action']?.toString() ?? 'reviewed';
        CommonSnackbar.showSuccess(
          title: 'BOM Review Complete',
          message: 'Building #$bNum has been $action.',
        );
        break;

      // 6. Project Drawings
      case 'drawing_status_updated':
        final status = payload['status']?.toString() ?? 'updated';
        CommonSnackbar.showSuccess(
          title: 'Drawing Status Updated',
          message: 'Project drawing status has been updated to $status.',
        );
        break;

      case 'drawing_comment_added':
        final commentMap = payload['comment'] is Map ? payload['comment'] as Map : null;
        final author = commentMap?['authorName']?.toString() ?? 'Staff';
        final text = commentMap?['text']?.toString() ?? 'New comment added';
        CommonSnackbar.showSuccess(
          title: 'Drawing Comment',
          message: '$author: $text',
        );
        break;

      // 7. Follow-Up Reminders
      case 'followup:reminder':
        final msg = payload['message']?.toString() ?? 'Follow-up reminder due.';
        CommonSnackbar.showWarning(
          title: 'Follow-Up Reminder',
          message: msg,
        );
        break;

      // 8. Purchase Orders & Payments
      case 'new_po_order':
        final orderMap = payload['order'] is Map ? payload['order'] as Map : null;
        final poNum = orderMap?['poNumber']?.toString() ?? '';
        CommonSnackbar.showSuccess(
          title: 'New Purchase Order',
          message: poNum.isNotEmpty ? 'Purchase Order $poNum has been created.' : 'New purchase order created.',
        );
        break;

      case 'payment_proof_submitted':
        final invNum = payload['invoiceNumber']?.toString() ?? '';
        CommonSnackbar.showSuccess(
          title: 'Payment Proof Submitted',
          message: invNum.isNotEmpty ? 'Payment proof uploaded for invoice $invNum.' : 'Payment proof uploaded.',
        );
        break;

      case 'new_escalation':
        final raisedBy = payload['raisedBy']?.toString() ?? 'Staff';
        CommonSnackbar.showWarning(
          title: 'New Escalation',
          message: 'An escalation was raised by $raisedBy.',
        );
        break;

      // 9. Team Chat Notices
      case 'new_team_dm_notice':
        CommonSnackbar.showSuccess(
          title: payload['fromName']?.toString() ?? 'New message',
          message: payload['content']?.toString() ?? 'New direct message.',
        );
        break;

      case 'new_team_group_message_notice':
        CommonSnackbar.showSuccess(
          title: 'Group Message',
          message: '${payload['fromName'] ?? 'Member'}: ${payload['content'] ?? 'New message.'}',
        );
        break;

      case 'team_chat_error':
      case 'chat_error':
        CommonSnackbar.showError(
          title: 'Chat Error',
          message: payload['message']?.toString() ?? 'Unable to process chat.',
        );
        break;

      case 'error':
        AppLogger.error('Socket server error: ${payload['message']}');
        break;

      default:
        // Other events (lead_list_*, chat_*, ai_script:*, etc.) broadcasted through stream
        break;
    }
  }

  void disconnect() {
    final socket = _socket;
    if (socket != null) {
      for (final eventName in allSupportedEvents) {
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
