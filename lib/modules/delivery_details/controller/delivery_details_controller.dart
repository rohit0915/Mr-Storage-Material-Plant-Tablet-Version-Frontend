import 'package:get/get.dart';
import '../model/delivery_details_model.dart';

class DeliveryDetailsController extends GetxController {
  final RxBool isLoading = false.obs;

  late final DeliveryDetailsModel delivery;
  final RxList<StatusHistoryItem> statusHistory = <StatusHistoryItem>[].obs;
  final RxList<NotificationHistoryItem> notificationHistory = <NotificationHistoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDeliveryDetails();
  }

  void loadDeliveryDetails() {
    isLoading.value = true;

    delivery = DeliveryDetailsModel(
      deliveryId: 'DEL-001',
      title: 'Primary frame steel',
      status: 'Scheduled',
      projectName: 'Industrial Complex A',
      customer: 'Acme Corporation',
      deliveryDate: '2024-03-25',
      timeWindow: '8:00 AM - 12:00 PM',
      siteAddress: '1234 Industrial Blvd, Austin, TX 78701',
      description: 'Primary frame steel',
      materialCategory: 'Steel',
      pickupDate: '2024-03-24',
      vendorName: 'Steel Supply Co',
      vendorContact: 'John Miller',
      vendorPhone: '+1 555-0101',
      vendorEmail: 'john@steelsupply.com',
      deliveryCompany: 'Fast Freight LLC',
      carrierContact: 'Sarah Transport',
      carrierPhone: '+1 555-0202',
      internalOwner: 'Mike Johnson - Logistics',
      internalContact: 'John Johnson',
      priority: 'Critical',
      deliveryType: 'Primary Steel',
      quantity: '2 pallets',
      siteInstructions: 'Deliver to rear entrance, mud-free zone required',
      requiredEquipment: '5,000 lb forklift required',
      equipmentStatus: 'Confirmed',
      specialNotes: 'Call 30 minutes before arrival',
      freightLoadId: 'FL 2031',
      awardedCarrier: 'Fast Freight LLC',
      price: '\$1,250',
      receivingName: 'Austin McClure',
      receivingPhone: '+1 555-0303',
      receivingEmail: 'austin@acmecorp.com',
    );

    statusHistory.assignAll([
      StatusHistoryItem(
        title: 'Created',
        timestamp: '2024-03-15 10:30 AM',
        description: 'Delivery created and scheduled by John Smith',
      ),
      StatusHistoryItem(
        title: 'Scheduled',
        timestamp: '2024-03-16 2:15 PM',
        description: 'Auto-notifications scheduled by System',
        isCurrent: true,
      ),
      StatusHistoryItem(
        title: 'Confirmed',
        timestamp: '2024-03-16 2:15 PM',
        description: 'Delivery confirmed by vendor by System',
      ),
      StatusHistoryItem(
        title: 'Rescheduled',
        timestamp: '2024-04-01 2:15 PM',
        description: 'Delivery confirmed by vendor by System',
      ),
      StatusHistoryItem(
        title: 'In Transit',
        timestamp: '2024-04-01 2:15 PM',
        description: 'Delivery confirmed by vendor by System',
      ),
      StatusHistoryItem(
        title: 'Delivered',
        timestamp: '2024-04-01 2:15 PM',
        description: 'Delivery confirmed by vendor by System',
      ),
    ]);

    notificationHistory.assignAll([
      NotificationHistoryItem(
        title: 'Email Confirmation',
        subtitle: 'austin@acmecorp.com',
        timestamp: '2024-03-15 10:30 AM',
        status: 'Sent',
      ),
      NotificationHistoryItem(
        title: '48-Hour SMS Reminder, Email ✓ SMS ✓',
        subtitle: '+1 555-0303',
        timestamp: '2024-03-23 8:00 AM',
        status: 'Scheduled',
      ),
      NotificationHistoryItem(
        title: '24-Hour SMS Reminder, Email ✓ SMS ✓',
        subtitle: '+1 555-0303',
        timestamp: '2024-03-24 8:00 AM',
        status: 'Scheduled',
      ),
      NotificationHistoryItem(
        title: 'Delivery Day Email, Email ✓ SMS ✓',
        subtitle: 'austin@acmecorp.com',
        timestamp: '2024-03-25 6:00 AM',
        status: 'Scheduled',
      ),
    ]);

    isLoading.value = false;
  }
}
