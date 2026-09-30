import 'package:flutter/material.dart';

class AddMemberDialog extends StatelessWidget {
  const AddMemberDialog({super.key});
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Group members'),
    content: const Text('Group membership is managed by your administrator.'),
    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
  );
}
