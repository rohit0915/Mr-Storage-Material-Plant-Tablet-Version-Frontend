import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../../app/services/shared_pref_service.dart';
import '../model/chat_model.dart';
import '../repository/chat_repository.dart';
import '../../../app/network/api_client.dart';
import '../../../app/widgets/common_snackbar.dart';

class ChatController extends GetxController {
  final Rx<ChatTab> activeTab = ChatTab.departments.obs;
  final Rx<SidePanelTab> activeSidePanelTab = SidePanelTab.members.obs;
  final Rxn<ChatChannel> selectedChat = Rxn<ChatChannel>();
  final RxBool isSidePanelOpen = false.obs;
  final RxBool isTeamTyping = false.obs;
  final RxString typingUserName = ''.obs;
  StreamSubscription<PlantSocketEvent>? _socketSubscription;
  Timer? _typingTimer;
  bool _typingSent = false;

  final RxString searchQuery = ''.obs;
  final RxString selectedProject = 'All Projects'.obs;

  final TextEditingController messageInputController = TextEditingController();
  final ScrollController messageScrollController = ScrollController();

  final RxList<ChatChannel> departmentChannels = <ChatChannel>[].obs;
  final RxList<ChatChannel> directChats = <ChatChannel>[].obs;

  final isLoading = false.obs;
  final isHistoryLoading = false.obs;
  final errorMessage = ''.obs;
  final historyError = ''.obs;
  late final ChatRepository repository = ChatRepository(Get.find<ApiClient>());
  Map<String, dynamic> get currentUser {
    final raw = Get.find<SharedPrefService>().getUserData();
    try { return Map<String, dynamic>.from(jsonDecode(raw ?? '{}') as Map); }
    catch (_) { return {}; }
  }

  @override
  void onInit() {
    super.onInit();
    loadConversations();
    if (Get.isRegistered<PlantSocketService>()) {
      _socketSubscription = Get.find<PlantSocketService>().listenFor(
        PlantSocketService.teamEvents,
        _handleSocketEvent,
      );
    }
  }

  ChatChannel channelFromApi(Map<String, dynamic> row) {
    final group = row['type'] == 'group';
    return ChatChannel(
      id: (group ? row['groupId'] : row['userId'] ?? row['_id']).toString(),
      name: row['name']?.toString() ?? '', type: group ? ChatTab.departments : ChatTab.direct,
      icon: group ? Icons.groups : Icons.person, iconColor: Colors.white,
      iconBgColor: const Color(0xFF2563EB), unreadCount: (row['unreadCount'] as num?)?.toInt() ?? 0,
      subtitle: row['lastMessage']?.toString() ?? row['role']?.toString() ?? '',
      description: row['description']?.toString() ?? '', members: [], files: [], messages: [],
    );
  }

  Future<void> loadConversations() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final rows = await repository.conversations();
      if (isClosed) return;
      departmentChannels.assignAll(rows.where((row) => row['type'] == 'group' && row['groupId'] != null).map(channelFromApi));
      directChats.assignAll(rows.where((row) => row['type'] == 'direct' && row['userId'] != null).map(channelFromApi));
    } catch (error) {
      departmentChannels.clear(); directChats.clear();
      errorMessage.value = error.toString();
    } finally { isLoading.value = false; }
  }

  Future<void> loadHistory(ChatChannel chat) async {
    isHistoryLoading.value = true;
    historyError.value = '';
    try {
      final rows = await repository.messages(chat.id, chat.type == ChatTab.departments);
      final members = <ChatMember>[];
      if (chat.type == ChatTab.departments) {
        final group = await repository.group(chat.id);
        for (final row in (group['members'] as List? ?? []).whereType<Map>()) {
          final id = (row['_id'] ?? row['id'] ?? '').toString();
          members.add(ChatMember(id: id, name: row['name']?.toString() ?? '',
            role: row['role']?.toString() ?? '', department: '',
            isAdmin: (group['admins'] as List? ?? []).contains(id), isOnline: row['isOnline'] == true));
        }
      }
      if (selectedChat.value?.id != chat.id || isClosed) return;
      final messages = rows.map(_message).toList()..sort((a,b) => a.timestamp.compareTo(b.timestamp));
      final live = selectedChat.value!.messages;
      for (final message in live) {
        if (!messages.any((item) => item.id == message.id)) messages.add(message);
      }
      messages.sort((a,b) => a.timestamp.compareTo(b.timestamp));
      selectedChat.value = selectedChat.value!.copyWith(messages: messages, members: members);
    } catch (error) {
      if (selectedChat.value?.id == chat.id) historyError.value = error.toString();
    } finally {
      if (selectedChat.value?.id == chat.id) isHistoryLoading.value = false;
    }
  }

  ChatMessage _message(Map<String, dynamic> row) => ChatMessage(
    id: row['_id']?.toString() ?? '', senderId: row['senderId']?.toString() ?? '',
    senderName: row['senderName']?.toString() ?? '', text: row['content']?.toString() ?? '',
    timestamp: row['createdAt']?.toString() ?? '', isMe: row['senderId']?.toString() == _currentUserId(),
  );

  List<ChatChannel> get currentChatList {
    final list = activeTab.value == ChatTab.departments
        ? departmentChannels
        : directChats;

    if (searchQuery.isEmpty) {
      return list;
    }

    return list
        .where(
          (chat) =>
              chat.name.toLowerCase().contains(searchQuery.value.toLowerCase()),
        )
        .toList();
  }

  void selectTab(ChatTab tab) {
    activeTab.value = tab;
  }

  void selectChat(ChatChannel chat) {
    final previous = selectedChat.value;
    if (previous != null && Get.isRegistered<PlantSocketService>()) {
      Get.find<PlantSocketService>().leaveTeamChannel(
        _channelType(previous),
        _channelId(previous),
      );
    }
    selectedChat.value = chat.copyWith(messages: []);
    isTeamTyping.value = false;
    loadHistory(chat);
    if (Get.isRegistered<PlantSocketService>()) {
      Get.find<PlantSocketService>().joinTeamChannel(
        _channelType(chat),
        _channelId(chat),
      );
    }
    // Mark as read when selected
    final list = chat.type == ChatTab.departments
        ? departmentChannels
        : directChats;
    final index = list.indexWhere((c) => c.id == chat.id);
    if (index != -1 && list[index].unreadCount > 0) {
      list[index] = list[index].copyWith(unreadCount: 0);
      selectedChat.value = list[index];
    }
  }

  void toggleSidePanel() {
    isSidePanelOpen.value = !isSidePanelOpen.value;
  }

  void closeSidePanel() {
    isSidePanelOpen.value = false;
  }

  void selectSidePanelTab(SidePanelTab tab) {
    activeSidePanelTab.value = tab;
  }

  void toggleMute() {
    CommonSnackbar.showInfo(title: 'Unavailable', message: 'Notification muting is not supported by the current chat service.');
  }

  void sendMessage() {
    final text = messageInputController.text.trim();
    final chat = selectedChat.value;
    if (text.isEmpty || chat == null) return;
    final sent = Get.isRegistered<PlantSocketService>() &&
        Get.find<PlantSocketService>().sendTeamMessage(_channelType(chat), chat.id, text);
    if (!sent) {
      CommonSnackbar.showError(title: 'Message not sent', message: 'Chat is disconnected. Your message has been kept; reconnect and try again.');
      return;
    }
    messageInputController.clear();
    setTyping(false);
  }

  void setTyping(bool typing) {
    final chat = selectedChat.value;
    if (chat == null || !Get.isRegistered<PlantSocketService>()) return;
    Get.find<PlantSocketService>().setTeamTyping(
      _channelType(chat),
      _channelId(chat),
      typing,
    );
  }

  void handleTypingChanged(String value) {
    if (!_typingSent && value.trim().isNotEmpty) {
      _typingSent = true;
      setTyping(true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 900), () {
      if (_typingSent) setTyping(false);
      _typingSent = false;
    });
  }

  void _handleSocketEvent(PlantSocketEvent event) {
    if ({'new_team_dm_notice', 'new_team_group_message_notice', 'new_team_group', 'group_members_updated'}.contains(event.name)) {
      loadConversations();
      return;
    }
    if (event.name == 'team_typing') {
      if (event.payload['channelId']?.toString() != selectedChat.value?.id && event.payload['userId']?.toString() != selectedChat.value?.id) return;
      isTeamTyping.value = event.payload['isTyping'] == true;
      typingUserName.value = event.payload['name']?.toString() ?? '';
      return;
    }
    if (event.name != 'new_team_message') return;
    final chat = selectedChat.value;
    if (chat == null || !_matchesChannel(chat, event.payload)) return;
    final message = _message(event.payload);
    if (message.id.isEmpty) return;
    if (chat.messages.any((item) => item.id == message.id)) return;
    final updated = chat.copyWith(
      messages: List<ChatMessage>.from(chat.messages)..add(message),
    );
    selectedChat.value = updated;
    final list = chat.type == ChatTab.departments
        ? departmentChannels
        : directChats;
    final index = list.indexWhere((item) => item.id == chat.id);
    if (index != -1) list[index] = updated;
  }

  bool _matchesChannel(ChatChannel chat, Map<String, dynamic> payload) {
    if (chat.type == ChatTab.departments) {
      return payload['channelType'] == 'group' &&
          payload['groupId']?.toString() == chat.id;
    }
    final participants = payload['participants'];
    return payload['channelType'] == 'direct' &&
        participants is List &&
        participants.map((item) => item.toString()).contains(_channelId(chat));
  }

  String _channelType(ChatChannel chat) =>
      chat.type == ChatTab.departments ? 'group' : 'direct';

  String _channelId(ChatChannel chat) => chat.id;

  String _currentUserId() {
    if (!Get.isRegistered<SharedPrefService>()) return '';
    final raw = Get.find<SharedPrefService>().getUserData();
    if (raw == null || raw.isEmpty) return '';
    try {
      final user = jsonDecode(raw);
      return user is Map ? (user['_id'] ?? user['id'] ?? '').toString() : '';
    } catch (_) {
      return '';
    }
  }

  @override
  void onClose() {
    final chat = selectedChat.value;
    if (chat != null && Get.isRegistered<PlantSocketService>()) {
      Get.find<PlantSocketService>().leaveTeamChannel(
        _channelType(chat),
        _channelId(chat),
      );
    }
    _socketSubscription?.cancel();
    _typingTimer?.cancel();
    messageInputController.dispose();
    messageScrollController.dispose();
    super.onClose();
  }
}
