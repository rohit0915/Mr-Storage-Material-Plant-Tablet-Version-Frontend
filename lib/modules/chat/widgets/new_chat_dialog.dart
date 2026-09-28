import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';

/// A direct conversation starts with a real user, as in the reference app.
class NewChatDialog extends StatefulWidget {
  const NewChatDialog({super.key});
  @override
  State<NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  final controller = Get.find<ChatController>();
  late Future<List<Map<String, dynamic>>> users = controller.repository.users();
  String search = '';

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New Direct Chat'),
    content: SizedBox(width: 420, height: 400, child: Column(children: [
      TextField(decoration: const InputDecoration(labelText: 'Search team members'),
        onChanged: (value) => setState(() => search = value.trim().toLowerCase())),
      Expanded(child: FutureBuilder<List<Map<String, dynamic>>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Column(children: [
            Text(snapshot.error.toString()),
            TextButton(onPressed: () => setState(() => users = controller.repository.users()), child: const Text('Retry')),
          ]);
          final rows = (snapshot.data ?? []).where((row) =>
            row['_id'] != controller.currentUser['_id'] &&
            '${row['name']} ${row['email']} ${row['role']}'.toLowerCase().contains(search)).toList();
          if (rows.isEmpty) return const Center(child: Text('No team members found'));
          return ListView.builder(itemCount: rows.length, itemBuilder: (context, index) {
            final row = rows[index];
            return ListTile(title: Text(row['name']?.toString() ?? ''),
              subtitle: Text(row['role']?.toString() ?? ''),
              onTap: () {
                final chat = controller.channelFromApi({...row, 'type': 'direct', 'userId': row['_id']});
                controller.activeTab.value = chat.type;
                if (!controller.directChats.any((item) => item.id == chat.id)) controller.directChats.add(chat);
                controller.selectChat(chat);
                Get.back();
              });
          });
        },
      )),
    ])),
    actions: [TextButton(onPressed: () => Get.back(), child: const Text('Close'))],
  );
}
