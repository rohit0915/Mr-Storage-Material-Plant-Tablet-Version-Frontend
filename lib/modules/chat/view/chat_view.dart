import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/chat_controller.dart';
import '../widgets/add_member_dialog.dart';
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

                      // Center Chat Content (Empty View or Active Chat Thread)
                      Expanded(
                        child: Obx(() {
                          if (controller.selectedChat.value == null) {
                            return const ChatEmptyView();
                          }
                          return const ChatThreadView();
                        }),
                      ),

                      // Right Side Info Panel (Collapsible)
                      Obx(() {
                        if (controller.isSidePanelOpen.value &&
                            controller.selectedChat.value != null) {
                          return ChatInfoPanel(
                            onAddMemberPressed: () {
                              Get.dialog(const AddMemberDialog());
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }),
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
