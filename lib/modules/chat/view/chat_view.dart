import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/chat_controller.dart';
import '../widgets/chat_empty_view.dart';
import '../widgets/chat_info_panel.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/chat_thread_view.dart';
import '../widgets/new_chat_dialog.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Fixed at top)
            const DashboardAppBar(),

            // Header Toolbar with Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: const [
                  AppBackButton(),
                  SizedBox(width: 12),
                  Text(
                    'Chat & Collaboration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Chat Split Layout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      // Left Sidebar
                      ChatSidebar(
                        onNewChatPressed: () {
                          Get.dialog(const NewChatDialog());
                        },
                      ),

                      // Center Chat Content & Right Side Panel Overlay
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            // Base Content
                            Positioned.fill(
                              child: Obx(() {
                                if (controller.selectedChat.value == null) {
                                  return const ChatEmptyView();
                                }
                                if (controller.isHistoryLoading.value) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (controller.historyError.isNotEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(controller.historyError.value),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: () => controller.loadHistory(controller.selectedChat.value!),
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const ChatThreadView();
                              }),
                            ),

                            // Overlay barrier
                            Obx(() {
                              if (controller.isSidePanelOpen.value &&
                                  controller.selectedChat.value != null) {
                                return Positioned.fill(
                                  child: GestureDetector(
                                    onTap: controller.closeSidePanel,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),

                            // Right Side Info Panel
                            Obx(() {
                              if (controller.isSidePanelOpen.value &&
                                  controller.selectedChat.value != null) {
                                return ChatInfoPanel(
                                  onAddMemberPressed: () {
                                    Get.snackbar('Group members', 'Group membership is managed by your administrator.');
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
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
    );
  }
}
