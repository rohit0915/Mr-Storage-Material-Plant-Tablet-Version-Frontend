import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../awarded_loads/widgets/freight_filter_dialog.dart';
import '../../delivery_details/widgets/in_transit_success_dialog.dart';
import '../../delivery_details/widgets/reschedule_delivery_dialog.dart';
import '../model/delivery_calendar_model.dart';

class DeliveryCalendarController extends GetxController {
  final selectedView = 'Day'.obs; // 'Day', 'Week', 'Month'
  final selectedDateRange = '24 Mar 2025 - 31 Mar 2025'.obs;
  final isLoading = false.obs;

  final deliveriesList = <DeliveryCalendarItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDeliveriesData();
  }

  void loadDeliveriesData() {
    isLoading.value = true;
    deliveriesList.assignAll([
      DeliveryCalendarItemModel(
        id: 'DEL-001',
        title: 'Primary frame steel',
        project: 'Industrial Complex A',
        customer: 'Acme Corporation',
        timeWindow: '8:00 AM - 12:00 PM',
        receivingContact: 'POC: Austin McClume',
        vendor: 'Steel Supply Co',
        siteLocation: 'Industrial Complex A\nAustin, TX',
        requiredEquipment: 'Primary frame steel\nEquipment: Crane required',
        internalOwner: 'Owner: Mike Johnson',
        carrier: 'Fast Freight LLC\nFreight Load: FL-2031',
        freightLoadId: 'FL-2031',
        status: 'Scheduled',
        isCriticalPath: true,
        isEquipmentConflict: true,
        date: DateTime(2024, 3, 25),
      ),
      DeliveryCalendarItemModel(
        id: 'DEL-002',
        title: 'Roll-up doors',
        project: 'Storage Facility B',
        customer: 'BuildTech LLC',
        timeWindow: '1:00 PM - 5:00 PM',
        receivingContact: 'POC: Austin McClume',
        vendor: 'Door Masters Inc',
        siteLocation: 'Industrial Complex A\nAustin, TX',
        requiredEquipment: 'Primary frame steel\nEquipment: Crane required',
        internalOwner: 'Owner: Mike Johnson',
        carrier: 'Fast Freight LLC\nFreight Load: FL-2031',
        freightLoadId: 'FL-2031',
        status: 'Confirmed',
        isCriticalPath: true,
        isEquipmentConflict: false,
        date: DateTime(2024, 3, 25),
      ),
    ]);
    isLoading.value = false;
  }

  void setView(String view) {
    selectedView.value = view;
  }

  void openFilterDialog() {
    Get.dialog(const FreightFilterDialog());
  }

  void openRescheduleDialog() {
    Get.dialog(const RescheduleDeliveryDialog());
  }

  void openMarkDeliveredDialog() {
    Get.dialog(const InTransitSuccessDialog());
  }

  void sendReminder() {
    Get.snackbar(
      'Reminder Sent',
      'Notification reminder sent to carrier and site contact.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void goToDeliveryDetails() {
    Get.toNamed(AppRoutes.deliveryDetails);
  }
}
