import 'package:get/get.dart';
import '../model/delivery_details_model.dart';
import '../repository/delivery_details_repository.dart';

class DeliveryDetailsController extends GetxController {
  final DeliveryDetailsRepository repository;
  DeliveryDetailsController({required this.repository});
  final RxBool isLoading = true.obs;
  final RxBool hasNoDeliveries = false.obs;
  final RxString errorMessage = ''.obs;

  late final DeliveryDetailsModel delivery;
  final RxList<StatusHistoryItem> statusHistory = <StatusHistoryItem>[].obs;
  final RxList<NotificationHistoryItem> notificationHistory =
      <NotificationHistoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDeliveryDetails();
  }

  Future<void> loadDeliveryDetails() async {
    isLoading.value = true;
    hasNoDeliveries.value = false;
    errorMessage.value = '';
    try {
      final routeId = Get.parameters['id'] ?? '';
      if (routeId.isEmpty) throw Exception('Project id is missing.');
      final projectData = await repository.fetchProjectDeliveries(routeId);
      
      final deliveries = projectData['requests'] is List
          ? projectData['requests'] as List
          : (projectData['deliveries'] is List ? projectData['deliveries'] as List : const []);
      
      if (deliveries.isEmpty) {
        hasNoDeliveries.value = true;
        return;
      }
      final first = Map<String, dynamic>.from(
        deliveries.whereType<Map>().first,
      );
      final deliveryId = (first['_id'] ?? first['deliveryId'] ?? '').toString();
      final detailData = deliveryId.isEmpty
          ? <String, dynamic>{'delivery': first}
          : await repository.fetchDetail(deliveryId);
      final raw = detailData['delivery'] is Map
          ? Map<String, dynamic>.from(detailData['delivery'] as Map)
          : first;
      final project = detailData['project'] is Map
          ? Map<String, dynamic>.from(detailData['project'] as Map)
          : <String, dynamic>{};
      final customer = detailData['customer'] is Map
          ? Map<String, dynamic>.from(detailData['customer'] as Map)
          : <String, dynamic>{};
      final carrier = detailData['carrier'] is Map
          ? Map<String, dynamic>.from(detailData['carrier'] as Map)
          : <String, dynamic>{};
      delivery = DeliveryDetailsModel(
        deliveryId: (raw['deliveryNumber'] ?? raw['_id'] ?? 'N/A').toString(),
        title: (raw['title'] ?? raw['description'] ?? 'Material Delivery')
            .toString(),
        status: _status(raw['status']),
        projectName: (project['projectName'] ?? raw['projectName'] ?? 'N/A')
            .toString(),
        customer: (customer['name'] ?? customer['firstName'] ?? 'N/A')
            .toString(),
        deliveryDate: _text(raw['deliveryDate']),
        timeWindow: (raw['timeWindow'] ?? 'N/A').toString(),
        siteAddress: (raw['deliveryLocation'] ?? raw['siteAddress'] ?? 'N/A')
            .toString(),
        description: (raw['description'] ?? 'N/A').toString(),
        materialCategory: (raw['materialCategory'] ?? 'Steel').toString(),
        pickupDate: _text(raw['pickupDate']),
        vendorName: (raw['vendorName'] ?? 'N/A').toString(),
        vendorContact: (raw['vendorContact'] ?? 'N/A').toString(),
        vendorPhone: (raw['vendorPhone'] ?? 'N/A').toString(),
        vendorEmail: (raw['vendorEmail'] ?? 'N/A').toString(),
        deliveryCompany: (carrier['companyName'] ?? carrier['name'] ?? 'N/A')
            .toString(),
        carrierContact: (carrier['contactName'] ?? 'N/A').toString(),
        carrierPhone: (carrier['phone'] ?? 'N/A').toString(),
        internalOwner: (raw['internalOwner'] ?? 'N/A').toString(),
        internalContact: (raw['internalContact'] ?? 'N/A').toString(),
        priority: _status(raw['priority']),
        deliveryType: (raw['deliveryType'] ?? 'Material').toString(),
        quantity: (raw['packageCount'] ?? raw['quantity'] ?? 'N/A').toString(),
        siteInstructions: (raw['siteInstructions'] ?? 'N/A').toString(),
        requiredEquipment: (raw['requiredEquipment'] ?? 'N/A').toString(),
        equipmentStatus: _status(raw['equipmentStatus']),
        specialNotes: (raw['specialNotes'] ?? 'N/A').toString(),
        freightLoadId: (raw['freightLoadId'] ?? 'N/A').toString(),
        awardedCarrier: (carrier['name'] ?? 'N/A').toString(),
        price: raw['price'] == null ? r'$0' : '\$${raw['price']}',
        receivingName: (raw['receivingName'] ?? customer['firstName'] ?? 'N/A')
            .toString(),
        receivingPhone: (raw['receivingPhone'] ?? customer['phone'] ?? 'N/A')
            .toString(),
        receivingEmail: (raw['receivingEmail'] ?? customer['email'] ?? 'N/A')
            .toString(),
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
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String _status(dynamic value) {
    final text = (value ?? 'N/A').toString().replaceAll('_', ' ');
    return text
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _text(dynamic value) => value == null ? 'N/A' : value.toString();
}
