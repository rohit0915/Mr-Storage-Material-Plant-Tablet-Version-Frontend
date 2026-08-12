import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/chat_model.dart';

class ChatController extends GetxController {
  final Rx<ChatTab> activeTab = ChatTab.departments.obs;
  final Rx<SidePanelTab> activeSidePanelTab = SidePanelTab.members.obs;
  final Rxn<ChatChannel> selectedChat = Rxn<ChatChannel>();
  final RxBool isSidePanelOpen = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedProject = 'All Projects'.obs;

  final TextEditingController messageInputController = TextEditingController();
  final ScrollController messageScrollController = ScrollController();

  final RxList<ChatChannel> departmentChannels = <ChatChannel>[].obs;
  final RxList<ChatChannel> directChats = <ChatChannel>[].obs;

  final List<String> projectList = [
    'All Projects',
    'Project Alpha',
    'Project Beta',
    'Project Texas Workshop',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Initial mock department channels
    departmentChannels.assignAll([
      ChatChannel(
        id: 'dept_1',
        name: 'Project Team',
        type: ChatTab.departments,
        icon: Icons.campaign_rounded,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFF2563EB),
        unreadCount: 3,
        subtitle: '2 members . Marketing',
        description: 'Marketing department discussions and campaigns',
        isMuted: false,
        members: [
          ChatMember(
            id: 'm1',
            name: 'John Doe',
            role: 'Marketing',
            department: 'Marketing',
            isAdmin: true,
          ),
          ChatMember(
            id: 'm2',
            name: 'James Wilson',
            role: 'Marketing',
            department: 'Marketing',
            isAdmin: false,
          ),
        ],
        files: [
          ChatFile(
            id: 'f1',
            fileName: 'Q1-Marketing-Budget-2025',
            uploaderName: 'Sarah Johnson',
            uploadDate: '2024-10-10',
            fileSize: '2.4 MB',
          ),
        ],
        messages: [
          ChatMessage(
            id: 'msg_1',
            senderId: 'm1',
            senderName: 'John Doe',
            text: 'Hi, I need a quote for a 40*60 workshop in Texas.',
            timestamp: '2024-10-10 09:30 pm',
            isMe: false,
          ),
          ChatMessage(
            id: 'msg_2',
            senderId: 'user_me',
            senderName: 'Sarah Lee',
            text:
                "Hello John! I'd be happy to help you with that. Can you tell me more about the intended use and any specific requirements?",
            timestamp: '2024-10-10 09:30 pm',
            isMe: true,
          ),
          ChatMessage(
            id: 'msg_3',
            senderId: 'ai_bot',
            senderName: 'Artificial Intelligence',
            text: 'Okay Sir, sending details to your inbox',
            timestamp: '2024-10-10 09:30 pm',
            isMe: false,
            isAi: true,
          ),
        ],
      ),
      ChatChannel(
        id: 'dept_2',
        name: 'Finance Team',
        type: ChatTab.departments,
        icon: Icons.calculate_rounded,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFF10B981),
        unreadCount: 0,
        subtitle: '4 members . Finance',
        description: 'Financial planning and budget allocations',
        isMuted: false,
        members: [
          ChatMember(
            id: 'm3',
            name: 'Sarah Johnson',
            role: 'Plant Lead',
            department: 'Finance',
            isAdmin: true,
          ),
          ChatMember(
            id: 'm4',
            name: 'Robert Vance',
            role: 'Financial Analyst',
            department: 'Finance',
            isAdmin: false,
          ),
        ],
        files: [],
        messages: [
          ChatMessage(
            id: 'msg_f1',
            senderId: 'm4',
            senderName: 'Robert Vance',
            text: 'Q3 budget report is ready for review.',
            timestamp: '2024-10-10 08:15 am',
            isMe: false,
          ),
        ],
      ),
      ChatChannel(
        id: 'dept_3',
        name: 'Construction Team',
        type: ChatTab.departments,
        icon: Icons.construction_rounded,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFFF59E0B),
        unreadCount: 1,
        subtitle: '5 members . Engineering',
        description: 'On-site construction and structural engineering updates',
        isMuted: false,
        members: [
          ChatMember(
            id: 'm5',
            name: 'David Miller',
            role: 'Site Supervisor',
            department: 'Construction',
            isAdmin: true,
          ),
        ],
        files: [],
        messages: [
          ChatMessage(
            id: 'msg_c1',
            senderId: 'm5',
            senderName: 'David Miller',
            text: 'Foundation pouring completed for Site B.',
            timestamp: '2024-10-10 11:45 am',
            isMe: false,
          ),
        ],
      ),
    ]);

    // Initial mock direct chats
    directChats.assignAll([
      ChatChannel(
        id: 'direct_1',
        name: 'Michael Chen (Project Lead)',
        type: ChatTab.direct,
        icon: Icons.person_rounded,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFF6366F1),
        unreadCount: 0,
        subtitle: 'Project Lead',
        description: 'Direct messages with Michael Chen',
        isMuted: false,
        members: [
          ChatMember(
            id: 'm_mc',
            name: 'Michael Chen',
            role: 'Project Lead',
            department: 'Engineering',
            isAdmin: false,
          ),
        ],
        files: [],
        messages: [
          ChatMessage(
            id: 'msg_d1',
            senderId: 'm_mc',
            senderName: 'Michael Chen',
            text: 'Hi, I need a quote for a 40*60 workshop in Texas.',
            timestamp: '2024-10-10 09:30 pm',
            isMe: false,
          ),
        ],
      ),
    ]);
  }

  List<ChatChannel> get currentChatList {
    final list = activeTab.value == ChatTab.departments
        ? departmentChannels
        : directChats;

    if (searchQuery.isEmpty) {
      return list;
    }

    return list
        .where((chat) =>
            chat.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  void selectTab(ChatTab tab) {
    activeTab.value = tab;
  }

  void selectChat(ChatChannel chat) {
    selectedChat.value = chat;
    // Mark as read when selected
    final list = chat.type == ChatTab.departments ? departmentChannels : directChats;
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
    final current = selectedChat.value;
    if (current == null) return;

    final updated = current.copyWith(isMuted: !current.isMuted);
    selectedChat.value = updated;

    final list = current.type == ChatTab.departments
        ? departmentChannels
        : directChats;
    final index = list.indexWhere((c) => c.id == current.id);
    if (index != -1) {
      list[index] = updated;
    }
  }

  void sendMessage() {
    final text = messageInputController.text.trim();
    if (text.isEmpty || selectedChat.value == null) return;

    final current = selectedChat.value!;
    final now = DateTime.now();
    final timeStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'pm' : 'am'}';

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'user_me',
      senderName: 'Sarah Lee',
      text: text,
      timestamp: timeStr,
      isMe: true,
    );

    final updatedMessages = List<ChatMessage>.from(current.messages)..add(newMessage);
    final updatedChat = current.copyWith(messages: updatedMessages);

    selectedChat.value = updatedChat;

    final list = current.type == ChatTab.departments
        ? departmentChannels
        : directChats;
    final index = list.indexWhere((c) => c.id == current.id);
    if (index != -1) {
      list[index] = updatedChat;
    }

    messageInputController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (messageScrollController.hasClients) {
        messageScrollController.animateTo(
          messageScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void addMemberToSelectedChat(String name, String role, bool isAdmin) {
    final current = selectedChat.value;
    if (current == null) return;

    final newMember = ChatMember(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      role: role,
      department: current.name,
      isAdmin: isAdmin,
    );

    final updatedMembers = List<ChatMember>.from(current.members)..add(newMember);
    final updatedChat = current.copyWith(members: updatedMembers);

    selectedChat.value = updatedChat;

    final list = current.type == ChatTab.departments
        ? departmentChannels
        : directChats;
    final index = list.indexWhere((c) => c.id == current.id);
    if (index != -1) {
      list[index] = updatedChat;
    }
  }

  void createNewChat(String name, ChatTab type, String description) {
    final newChat = ChatChannel(
      id: '${type == ChatTab.departments ? 'dept' : 'direct'}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      icon: type == ChatTab.departments
          ? Icons.campaign_rounded
          : Icons.person_rounded,
      iconColor: Colors.white,
      iconBgColor: type == ChatTab.departments
          ? const Color(0xFF2563EB)
          : const Color(0xFF8B5CF6),
      subtitle: type == ChatTab.departments ? '1 member' : 'Direct Message',
      description: description.isNotEmpty ? description : 'New channel',
      members: [
        ChatMember(
          id: 'me',
          name: 'Sarah Johnson',
          role: 'Plant Lead',
          department: 'Management',
          isAdmin: true,
        ),
      ],
      files: [],
      messages: [],
    );

    if (type == ChatTab.departments) {
      departmentChannels.add(newChat);
    } else {
      directChats.add(newChat);
    }

    activeTab.value = type;
    selectChat(newChat);
  }

  @override
  void onClose() {
    messageInputController.dispose();
    messageScrollController.dispose();
    super.onClose();
  }
}
