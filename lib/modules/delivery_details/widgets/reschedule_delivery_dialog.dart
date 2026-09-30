import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/delivery_details_controller.dart';

class RescheduleDeliveryDialog extends StatefulWidget {
  const RescheduleDeliveryDialog({super.key});
  @override
  State<RescheduleDeliveryDialog> createState() => _RescheduleDeliveryDialogState();
}
class _RescheduleDeliveryDialogState extends State<RescheduleDeliveryDialog> {
  final controller = Get.find<DeliveryDetailsController>();
  final notes = TextEditingController();
  DateTime? date;
  TimeOfDay? start;
  TimeOfDay? end;
  String? reason;
  String error = '';
  String time(TimeOfDay value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  @override
  void dispose() { notes.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Reschedule Delivery'),
    content: SizedBox(width: 480, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(controller.delivery.description),
      TextButton(onPressed: () async {
        final today = DateUtils.dateOnly(DateTime.now());
        final picked = await showDatePicker(context: context, initialDate: date ?? today, firstDate: today, lastDate: DateTime(today.year + 5));
        if (mounted && picked != null) setState(() => date = picked);
      }, child: Text(date == null ? 'Select delivery date' : date!.toIso8601String().split('T').first)),
      Row(children: [
        TextButton(onPressed: () async { final value = await showTimePicker(context: context, initialTime: start ?? TimeOfDay.now()); if (mounted && value != null) setState(() => start = value); }, child: Text(start == null ? 'Start time' : time(start!))),
        TextButton(onPressed: () async { final value = await showTimePicker(context: context, initialTime: end ?? TimeOfDay.now()); if (mounted && value != null) setState(() => end = value); }, child: Text(end == null ? 'End time' : time(end!))),
      ]),
      DropdownButtonFormField<String>(initialValue: reason, decoration: const InputDecoration(labelText: 'Reason'),
        items: const ['Weather Delay', 'Site Not Ready', 'Carrier Delay', 'Customer Request'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => reason = value),
      TextField(controller: notes, decoration: const InputDecoration(labelText: 'Additional notes'), maxLines: 3),
      if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
      Obx(() => Text(controller.saveError.value, style: const TextStyle(color: Colors.red))),
    ]))),
    actions: [TextButton(onPressed: Get.back, child: const Text('Cancel')),
      Obx(() => FilledButton(onPressed: controller.isSaving.value ? null : () async {
        if (date == null || start == null || end == null || reason == null) {
          setState(() => error = 'Choose a date, time window, and reason.'); return;
        }
        final saved = await controller.saveDetails({
          'date': DateTime.utc(date!.year, date!.month, date!.day).toIso8601String(),
          'timeWindowStart': time(start!), 'timeWindowEnd': time(end!),
          'rescheduleReason': reason, 'additionalNotes': notes.text.trim(),
        }, reschedule: true);
        if (saved && mounted) Get.back();
      }, child: Text(controller.isSaving.value ? 'Saving…' : 'Reschedule Now'))),
    ],
  );
}
