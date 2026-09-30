import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/delivery_details_controller.dart';

class EditDeliveryDialog extends StatefulWidget {
  const EditDeliveryDialog({super.key});
  @override
  State<EditDeliveryDialog> createState() => _EditDeliveryDialogState();
}
class _EditDeliveryDialogState extends State<EditDeliveryDialog> {
  final controller = Get.find<DeliveryDetailsController>();
  late final address = TextEditingController(text: controller.delivery.siteAddress);
  late final notes = TextEditingController(text: controller.delivery.specialNotes == 'N/A' ? '' : controller.delivery.specialNotes);
  @override
  void dispose() { address.dispose(); notes.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit Delivery Details'),
    content: SizedBox(width: 480, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(controller.delivery.projectName),
      TextField(controller: address, decoration: const InputDecoration(labelText: 'Delivery address')),
      TextField(controller: notes, decoration: const InputDecoration(labelText: 'Additional notes'), maxLines: 3),
      Obx(() => Text(controller.saveError.value, style: const TextStyle(color: Colors.red))),
    ])),
    actions: [TextButton(onPressed: Get.back, child: const Text('Cancel')),
      Obx(() => FilledButton(onPressed: controller.isSaving.value ? null : () async {
        if (address.text.trim().isEmpty) { controller.saveError.value = 'Delivery address is required.'; return; }
        final saved = await controller.saveDetails({'deliveryLocation': address.text.trim(), 'additionalNotes': notes.text.trim()});
        if (saved && mounted) Get.back();
      }, child: Text(controller.isSaving.value ? 'Saving…' : 'Save Changes'))),
    ],
  );
}
