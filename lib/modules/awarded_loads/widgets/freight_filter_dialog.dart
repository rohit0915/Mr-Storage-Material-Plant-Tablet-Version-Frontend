import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FreightFilterDialog extends StatefulWidget {
  final ValueChanged<String?>? onApplyStatus;
  final List<String> statuses;
  const FreightFilterDialog({super.key, this.onApplyStatus, this.statuses = const []});
  @override
  State<FreightFilterDialog> createState() => _FreightFilterDialogState();
}
class _FreightFilterDialogState extends State<FreightFilterDialog> {
  String? selected;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Filter loads'),
    content: DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Status'),
      items: <String>{'All', ...widget.statuses}.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
      onChanged: (value) => selected = value == 'All' ? null : value,
    ),
    actions: [
      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
      ElevatedButton(onPressed: () { widget.onApplyStatus?.call(selected); Get.back(); }, child: const Text('Apply')),
    ],
  );
}
