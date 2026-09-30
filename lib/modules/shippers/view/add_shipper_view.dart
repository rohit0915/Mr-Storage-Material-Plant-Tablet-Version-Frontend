import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logistics_form/view/logistics_form_view.dart';
import '../controller/shippers_controller.dart';

class AddShipperView extends GetView<ShippersController> {
  const AddShipperView({super.key});
  @override
  Widget build(BuildContext context) =>
      LogisticsFormView(carrier: false, onSaved: controller.loadShippersData);
}
