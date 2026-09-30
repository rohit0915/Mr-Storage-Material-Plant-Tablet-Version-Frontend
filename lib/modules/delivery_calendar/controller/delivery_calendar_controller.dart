import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
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
  final totalDeliveries = 0.obs;

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
      final dateGroups = data['dates'] is List
          ? data['dates'] as List
          : data['deliveries'] is List
              ? data['deliveries'] as List
              : data['calendar'] is List
                  ? data['calendar'] as List
                  : data['items'] is List
                      ? data['items'] as List
                      : const [];
      final raw = <Map<String, dynamic>>[];
      var total = 0;
      for (final groupValue in dateGroups.whereType<Map>()) {
        final group = Map<String, dynamic>.from(groupValue);
        final groupDate = group['date'] ?? group['deliveryDate'] ?? group['createdAt'];
        final groupDeliveries = group['deliveries'] is List
            ? group['deliveries'] as List
            : null;
        if (groupDeliveries != null) {
          total += _integer(group['totalDeliveries'], groupDeliveries.length);
          for (final deliveryValue in groupDeliveries.whereType<Map>()) {
            raw.add({
              ...Map<String, dynamic>.from(deliveryValue),
              '_calendarDate': groupDate,
            });
          }
        } else {
          raw.add({
            ...group,
            '_calendarDate': groupDate,
          });
        }
      }
      if (total == 0) total = raw.length;
      totalDeliveries.value = total;
      deliveriesList.assignAll(
        raw.map((item) {
          final project = _map(item['project'] ?? item['lead']);
          final customer = _map(item['customer']);
          final carrier = _map(item['carrier']);
          final delivery = _map(item['delivery']);
          final poc = _map(item['poc']);
          final shipperVendor = _map(item['shipperVendor']);
          final date =
              DateTime.tryParse(
                (item['_calendarDate'] ??
                        item['deliveryDate'] ??
                        item['date'] ??
                        '')
                    .toString(),
              )?.toLocal() ??
              selectedDate.value;
          return DeliveryCalendarItemModel(
            rawId: item['_id']?.toString() ?? delivery['_id']?.toString() ?? item['id']?.toString() ?? '',
            id: _text(item['_id'] ?? delivery['_id'] ?? item['requestId']),
            title: _text(
              project['projectName'] ??
                  delivery['description'] ??
                  delivery['loadDescription'] ??
                  'Shipment',
            ),
            project: _text(
              item['deliveryNumber'] ??
                  delivery['deliveryNumber'] ??
                  item['requestId'],
            ),
            customer: _text(
              item['customerName'] ?? customer['name'] ?? customer['firstName'],
            ),
            timeWindow: _text(
              delivery['timings'] ??
                  item['deliveryTime'] ??
                  delivery['deliveryTime'],
            ),
            receivingContact: _text(
              poc['receivingPoc'] ??
                  delivery['receivingPoc'] ??
                  customer['name'],
            ),
            vendor: _text(
              carrier['carrierName'] ?? shipperVendor['vendorName'],
            ),
            siteLocation: _text(
              item['deliveryLocation'] ??
                  delivery['deliveryLocation'] ??
                  item['siteLocation'],
            ),
            requiredEquipment: _listText(
              item['equipment'] ?? delivery['loadingEquipment'],
              fallback: 'None',
            ),
            internalOwner: 'N/A',
            carrier: _text(
              carrier['carrierName'] ??
                  item['carrierName'] ??
                  carrier['companyName'] ??
                  carrier['name'],
            ),
            freightLoadId: _text(item['requestId'] ?? item['freightLoadId']),
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
      totalDeliveries.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setView(String view) async {
    selectedView.value = view;
    await loadDeliveriesData();
  }

  Future<void> moveRange(int direction) async {
    if (direction < 0 && !canMovePrevious) return;
    if (selectedView.value == 'Month') {
      selectedDate.value = DateTime(
        selectedDate.value.year,
        selectedDate.value.month + direction,
        1,
      );
    } else {
      final days = selectedView.value == 'Week' ? 7 : 1;
      selectedDate.value = selectedDate.value.add(
        Duration(days: days * direction),
      );
    }
    await loadDeliveriesData();
  }

  bool get canMovePrevious {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (selectedView.value == 'Month') {
      return DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        1,
      ).isAfter(DateTime(today.year, today.month, 1));
    }
    if (selectedView.value == 'Week') {
      return _weekStart(selectedDate.value).isAfter(_weekStart(today));
    }
    return DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    ).isAfter(today);
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
      final from = _weekStart(day);
      return (from, from.add(const Duration(days: 6)));
    }
    return (
      DateTime(day.year, day.month, day.day),
      DateTime(day.year, day.month, day.day),
    );
  }

  DateTime _weekStart(DateTime date) =>
      date.subtract(Duration(days: date.weekday % 7));

  String _rangeLabel(DateTime from, DateTime to) {
    if (selectedView.value == 'Month') {
      return '${_longMonth(from.month)} ${from.year}';
    }
    if (_sameDay(from, to)) {
      return '${from.day} ${_month(from.month)} ${from.year}';
    }
    return '${from.day} - ${to.day} ${_month(to.month)} ${to.year}';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _longMonth(int month) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
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
  void openRescheduleDialog(String id) => Get.dialog(const RescheduleDeliveryDialog());
  void openMarkDeliveredDialog(String id) => Get.dialog(const InTransitSuccessDialog());
  void sendReminder(String id) => Get.snackbar(
    'Reminder unavailable',
    'The delivery-reminder endpoint is not present in the current API collection.',
  );
  void goToDeliveryDetails(String id) => Get.toNamed(AppRoutes.deliveryDetails, parameters: {'deliveryId': id});
  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  String _text(dynamic value) => (value ?? '-').toString();
  int _integer(dynamic value, int fallback) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  String _listText(dynamic value, {required String fallback}) => value is List
      ? value.isEmpty
            ? fallback
            : value.join(', ')
      : value == null
      ? fallback
      : value.toString();
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
