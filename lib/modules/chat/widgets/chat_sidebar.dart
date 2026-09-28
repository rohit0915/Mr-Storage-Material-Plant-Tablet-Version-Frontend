import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../controller/chat_controller.dart';
import '../model/chat_model.dart';

class ChatSidebar extends GetView<ChatController> {
  final VoidCallback onNewChatPressed;

  const ChatSidebar({
    super.key,
    required this.onNewChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        children: [
          // User Profile Header Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE2E8F0),
                        image: DecorationImage(
                          image: AssetImage('assets/images/user_placeholder.png'),
                          fit: BoxFit.cover,
                          onError: null,
                        ),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF64748B), size: 26),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentUser['name']?.toString() ?? '—',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        controller.currentUser['role']?.toString() ?? '—',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search chats Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                  prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tab Toggle: Departments vs Direct
          Obx(() {
            final activeTab = controller.activeTab.value;
            return Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.selectTab(ChatTab.departments),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Groups',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: activeTab == ChatTab.departments
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: activeTab == ChatTab.departments
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Container(
                            height: 2,
                            color: activeTab == ChatTab.departments
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.selectTab(ChatTab.direct),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Direct',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: activeTab == ChatTab.direct
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: activeTab == ChatTab.direct
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Container(
                            height: 2,
                            color: activeTab == ChatTab.direct
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Chat List Items
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.errorMessage.isNotEmpty) return Padding(
                padding: const EdgeInsets.all(12), child: Column(children: [
                  Text(controller.errorMessage.value),
                  TextButton(onPressed: controller.loadConversations, child: const Text('Retry')),
                ]));
              final chats = controller.currentChatList;

              if (chats.isEmpty) {
                return const Center(
                  child: Text(
                    'No chats found',
                    style: TextStyle(fontSize: 13, color: AppColors.textHint),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                physics: const BouncingScrollPhysics(),
                itemCount: chats.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return Obx(() {
                    final isSelected = controller.selectedChat.value?.id == chat.id;
                    return InkWell(
                      onTap: () => controller.selectChat(chat),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEFF6FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: const Color(0xFFBFDBFE))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: chat.iconBgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(chat.icon, color: chat.iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                chat.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (chat.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${chat.unreadCount}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),

          // Bottom New Chat Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: onNewChatPressed,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    Text(
                      'New Chat',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Bottom Sync & Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFAFAFA),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.circle, color: Color(0xFF22C55E), size: 10),
                    SizedBox(width: 6),
                    Text(
                      'Team Online',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Last sync: just now',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
