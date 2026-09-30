import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logistics_form/view/logistics_form_view.dart';
import '../controller/shippers_controller.dart';

class EditShipperView extends GetView<ShippersController> {
  const EditShipperView({super.key});
  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedShipper.value;
    if (selected == null) {
      return const Scaffold(
        body: Center(child: Text('Select a shipper to edit.')),
      );
    }
    return LogisticsFormView(
      carrier: false,
      recordId: selected.id,
      onSaved: () async {
        await controller.loadShippersData();
        await controller.refreshVendorDetails(selected);
      },
    );
  }
}
