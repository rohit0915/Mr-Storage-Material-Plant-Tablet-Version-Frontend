import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../awarded_loads/widgets/freight_filter_dialog.dart';
import '../../delivery_details/widgets/in_transit_success_dialog.dart';
import '../../delivery_details/widgets/reschedule_delivery_dialog.dart';
import '../../freight_loads/repository/delivery_repository.dart';
import '../model/delivery_calendar_model.dart';

class DeliveryCalendarController extends GetxController {
  final DeliveryRepository repository;
  DeliveryCalendarController({required this.repository});

  final selectedView = 'Day'.obs;
  final selectedDateRange = ''.obs;
  final selectedDate = DateTime.now().obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final deliveriesList = <DeliveryCalendarItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDeliveriesData();
  }

  Future<void> loadDeliveriesData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final range = _range();
      selectedDateRange.value = _rangeLabel(range.$1, range.$2);
      final data = await repository.calendar(from: range.$1, to: range.$2);
      final raw = data['calendar'] is List
          ? data['calendar'] as List
          : const [];
      deliveriesList.assignAll(
        raw.whereType<Map>().map((entry) {
          final item = Map<String, dynamic>.from(entry);
          final project = _map(item['project'] ?? item['lead']);
          final customer = _map(item['customer']);
          final carrier = _map(item['carrier']);
          final date =
              DateTime.tryParse(
                (item['deliveryDate'] ?? item['date'] ?? '').toString(),
              )?.toLocal() ??
              selectedDate.value;
          return DeliveryCalendarItemModel(
            id: _text(item['deliveryNumber'] ?? item['_id']),
            title: _text(item['description'] ?? item['title']),
            project: _text(item['projectName'] ?? project['projectName']),
            customer: _text(
              item['customerName'] ?? customer['name'] ?? customer['firstName'],
            ),
            timeWindow: _text(item['timeWindow']),
            receivingContact: _text(item['receivingName'] ?? item['pocName']),
            vendor: _text(item['vendorName']),
            siteLocation: _text(
              item['deliveryLocation'] ?? item['siteLocation'],
            ),
            requiredEquipment: _text(item['requiredEquipment']),
            internalOwner: _text(
              item['internalOwnerName'] ?? item['internalOwner'],
            ),
            carrier: _text(
              item['carrierName'] ?? carrier['companyName'] ?? carrier['name'],
            ),
            freightLoadId: _text(item['freightLoadId']),
            status: _status(item['status']),
            isCriticalPath: item['isCriticalPath'] == true,
            isEquipmentConflict: item['isEquipmentConflict'] == true,
            date: date,
          );
        }),
      );
    } catch (error) {
      errorMessage.value = error.toString();
      deliveriesList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setView(String view) async {
    selectedView.value = view;
    await loadDeliveriesData();
  }

  Future<void> moveRange(int direction) async {
    final days = selectedView.value == 'Month'
        ? 30
        : selectedView.value == 'Week'
        ? 7
        : 1;
    selectedDate.value = selectedDate.value.add(
      Duration(days: days * direction),
    );
    await loadDeliveriesData();
  }

  (DateTime, DateTime) _range() {
    final day = selectedDate.value;
    if (selectedView.value == 'Month') {
      return (
        DateTime(day.year, day.month, 1),
        DateTime(day.year, day.month + 1, 0),
      );
    }
    if (selectedView.value == 'Week') {
      final from = day.subtract(Duration(days: day.weekday - 1));
      return (from, from.add(const Duration(days: 6)));
    }
    return (
      DateTime(day.year, day.month, day.day),
      DateTime(day.year, day.month, day.day),
    );
  }

  String _rangeLabel(DateTime from, DateTime to) => from == to
      ? '${from.day} ${_month(from.month)} ${from.year}'
      : '${from.day} ${_month(from.month)} ${from.year} - ${to.day} ${_month(to.month)} ${to.year}';
  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
  void openFilterDialog() => Get.dialog(const FreightFilterDialog());
  void openRescheduleDialog() => Get.dialog(const RescheduleDeliveryDialog());
  void openMarkDeliveredDialog() => Get.dialog(const InTransitSuccessDialog());
  void sendReminder() => Get.snackbar(
    'Reminder unavailable',
    'The delivery-reminder endpoint is not present in the current API collection.',
  );
  void goToDeliveryDetails() => Get.toNamed(AppRoutes.deliveryDetails);
  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  String _text(dynamic value) => (value ?? '-').toString();
  String _status(dynamic value) => (value ?? 'Unknown')
      .toString()
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
