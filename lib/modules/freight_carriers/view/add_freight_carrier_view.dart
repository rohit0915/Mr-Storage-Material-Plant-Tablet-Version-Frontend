import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logistics_form/view/logistics_form_view.dart';
import '../controller/freight_carriers_controller.dart';

class AddFreightCarrierView extends GetView<FreightCarriersController> {
  const AddFreightCarrierView({super.key, this.isEdit = false});
  final bool isEdit;
  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedCarrier.value;
    if (isEdit && selected == null) {
      return const Scaffold(
        body: Center(child: Text('Select a carrier to edit.')),
      );
    }
    return LogisticsFormView(
      carrier: true,
      recordId: isEdit ? selected!.id : null,
      onSaved: controller.loadCarriers,
    );
  }
}
