import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../controller/chat_controller.dart';
import '../model/chat_model.dart';

class ChatInfoPanel extends GetView<ChatController> {
  final VoidCallback onAddMemberPressed;

  const ChatInfoPanel({
    super.key,
    required this.onAddMemberPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chat = controller.selectedChat.value;
      if (chat == null) return const SizedBox.shrink();

      return Container(
        width: 320,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel Header Matching Red Box (Row with X button + Icon + Channel Info)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: controller.closeSidePanel,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: chat.iconBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(chat.icon, color: chat.iconColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              chat.subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    chat.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: InkWell(
                      onTap: controller.toggleMute,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              chat.isMuted
                                  ? Icons.notifications_off_outlined
                                  : Icons.notifications_none_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              chat.isMuted ? 'Unmute' : 'Mute',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar: Members vs Files
            Obx(() {
              final activeTab = controller.activeSidePanelTab.value;
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
                        onTap: () => controller.selectSidePanelTab(SidePanelTab.members),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Members',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: activeTab == SidePanelTab.members
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: activeTab == SidePanelTab.members
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Container(
                              height: 2,
                              color: activeTab == SidePanelTab.members
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.selectSidePanelTab(SidePanelTab.files),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Files',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: activeTab == SidePanelTab.files
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: activeTab == SidePanelTab.files
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Container(
                              height: 2,
                              color: activeTab == SidePanelTab.files
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

            // Tab Content
            Expanded(
              child: Obx(() {
                final activeTab = controller.activeSidePanelTab.value;

                if (activeTab == SidePanelTab.members) {
                  return _buildMembersTab(chat);
                } else {
                  return _buildFilesTab(chat);
                }
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMembersTab(ChatChannel chat) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: chat.members.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final member = chat.members[index];
              return Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE2E8F0),
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF64748B), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.role,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (member.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: onAddMemberPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_add_alt_outlined, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text(
                    'Add member',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilesTab(ChatChannel chat) {
    if (chat.files.isEmpty) {
      return const Center(
        child: Text(
          'No shared files',
          style: TextStyle(fontSize: 13, color: AppColors.textHint),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: chat.files.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final file = chat.files[index];
        return Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF2563EB), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    file.uploaderName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.file_download_outlined, color: AppColors.textSecondary, size: 20),
              onPressed: () {
                Get.snackbar(
                  'Download',
                  'Downloading ${file.fileName}...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
