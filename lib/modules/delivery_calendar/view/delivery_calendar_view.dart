import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/delivery_calendar_controller.dart';
import '../model/delivery_calendar_model.dart';
import '../widgets/delivery_calendar_detail_dialog.dart';
import '../widgets/day_deliveries_dialog.dart';

class DeliveryCalendarView extends GetView<DeliveryCalendarController> {
  const DeliveryCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Navigation Toolbar
                      _buildHeaderToolbar(),
                      const SizedBox(height: 20),

                      // Segment Content Based on Selected View (Day, Week, Month)
                      Obx(() {
                        switch (controller.selectedView.value) {
                          case 'Week':
                            return _buildWeekView();
                          case 'Month':
                            return _buildMonthView();
                          case 'Day':
                          default:
                            return _buildDayView();
                        }
                      }),
                      const SizedBox(height: 20),

                      const SizedBox(height: 12),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderToolbar() {
    return Row(
      children: [
        const AppBackButton(),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Delivery Calendar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Schedule and track deliveries in calendar view',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        const Spacer(),

        // Date Range Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Obx(
                () => IconButton(
                  tooltip: 'Previous range',
                  onPressed: controller.canMovePrevious
                      ? () => controller.moveRange(-1)
                      : null,
                  icon: const Icon(Icons.chevron_left, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              Obx(
                () => Text(
                  controller.selectedDateRange.value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              IconButton(
                tooltip: 'Next range',
                onPressed: () => controller.moveRange(1),
                icon: const Icon(Icons.chevron_right, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Segment Switcher (Day, Week, Month)
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Obx(
            () => Row(
              children: ['Day', 'Week', 'Month'].map((view) {
                final isSelected = controller.selectedView.value == view;
                return InkWell(
                  onTap: () => controller.setView(view),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      view,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // DAY VIEW CONTENT (Image 1, 4, 5)
  Widget _buildDayView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header Info Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(
                  () => Text(
                    'Total Deliveries: ${controller.totalDeliveries.value} deliveries',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date Header
          Obx(
            () => Text(
              _fullDate(controller.selectedDate.value),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cards List
          if (controller.deliveriesList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 42),
              child: Center(
                child: Text(
                  'No deliveries found for this date.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.deliveriesList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = controller.deliveriesList[index];
                return _buildDeliveryCard(item);
              },
            ),
        ],
      ),
    );
  }

  String _fullDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
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
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildDeliveryCard(DeliveryCalendarItemModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Status Badges
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.status == 'Confirmed'
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => controller.goToDeliveryDetails(item.rawId),
                child: Text(
                  item.id,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2563EB),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (item.isCriticalPath)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Critical Path Items',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ),
              if (item.isEquipmentConflict) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '⚠️ Equipment conflict',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
              const Spacer(),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details Grid (Row 1)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDetailCell(
                  'PROJECT',
                  item.project,
                  icon: Icons.business_outlined,
                ),
              ),
              Expanded(child: _buildDetailCell('CUSTOMER', item.customer)),
              Expanded(
                child: _buildDetailCell(
                  'TIME WINDOW',
                  item.timeWindow,
                  icon: Icons.access_time,
                ),
              ),
              Expanded(
                child: _buildDetailCell(
                  'RECEIVING CONTACT',
                  item.receivingContact,
                  icon: Icons.phone_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Details Grid (Row 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDetailCell(
                  'VENDOR',
                  item.vendor,
                  icon: Icons.local_shipping_outlined,
                ),
              ),
              Expanded(
                child: _buildDetailCell('SITE LOCATION', item.siteLocation),
              ),
              Expanded(
                child: _buildDetailCell(
                  'REQUIRED EQUIPMENT',
                  item.requiredEquipment,
                ),
              ),
              Expanded(
                child: _buildDetailCell('INTERNAL OWNER', item.internalOwner),
              ),
              Expanded(child: _buildDetailCell('CARRIER', item.carrier)),
            ],
          ),
          const SizedBox(height: 18),

          // 4 Action Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.goToDeliveryDetails(item.rawId),
                  icon: const Icon(
                    Icons.local_shipping_outlined,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  label: const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.openRescheduleDialog(item.rawId),
                  icon: const Icon(
                    Icons.event_repeat,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  label: const Text(
                    'Reschedule Delivery',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.openMarkDeliveredDialog(item.rawId),
                  icon: const Icon(
                    Icons.check_box_outlined,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  label: const Text(
                    'Mark Delivered',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.sendReminder(item.rawId),
                  icon: const Icon(
                    Icons.notifications_none,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  label: const Text(
                    'Send Reminder Now',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCell(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // WEEK VIEW CONTENT (Image 2)
  Widget _buildWeekView() {
    final selected = controller.selectedDate.value;
    final start = selected.subtract(Duration(days: selected.weekday % 7));
    final days = List.generate(7, (index) => start.add(Duration(days: index)));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalBadge(),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: days.map((day) {
              final isSelected = _sameDay(day, selected);
              final items = controller.deliveriesList
                  .where((item) => _sameDay(item.date, day))
                  .toList();
              return Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 440),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
                    border: Border(
                      right: const BorderSide(color: AppColors.divider),
                      left: days.first == day
                          ? const BorderSide(color: AppColors.divider)
                          : BorderSide.none,
                      top: const BorderSide(color: AppColors.divider),
                      bottom: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.divider),
                          ),
                        ),
                        child: Text(
                          '${_shortWeekday(day.weekday)}, ${_shortMonth(day.month)} ${day.day}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.fromLTRB(7, 8, 7, 0),
                          child: _buildWeekCard(item),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(DeliveryCalendarItemModel item) {
    final color = _statusColor(item.status);
    return InkWell(
      onTap: () => Get.dialog(DeliveryCalendarDetailDialog(item: item)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              item.customer,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MONTH VIEW CONTENT (Image 3)
  Widget _buildMonthView() {
    final selected = controller.selectedDate.value;
    final first = DateTime(selected.year, selected.month, 1);
    final gridStart = first.subtract(Duration(days: first.weekday % 7));
    final days = List.generate(
      42,
      (index) => gridStart.add(Duration(days: index)),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalBadge(),
          const SizedBox(height: 20),

          // Days Header
          Row(
            children:
                [
                  'Sunday',
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                ].map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 12),

          // Six complete calendar weeks, including adjacent-month days.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.35,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final inMonth = day.month == selected.month;
              final items = controller.deliveriesList
                  .where((item) => _sameDay(item.date, day))
                  .toList();

              return InkWell(
                onTap: () {
                  Get.dialog(
                    DayDeliveriesDialog(
                      dateTitle: _fullDate(day),
                      items: items,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: inMonth
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      if (items.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        ...items
                            .take(2)
                            .map(
                              (item) => Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 3),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    item.status,
                                  ).withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(item.status),
                                  ),
                                ),
                              ),
                            ),
                        if (items.length > 2)
                          Text(
                            '+${items.length - 2} more',
                            style: const TextStyle(
                              fontSize: 8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBadge() => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFF4169B8).withValues(alpha: .18),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      'Total Deliveries: ${controller.totalDeliveries.value} deliveries',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF02318C),
      ),
    ),
  );

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _shortWeekday(int weekday) =>
      const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][weekday - 1];

  String _shortMonth(int month) => const [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ][month - 1];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF16A34A);
      case 'in transit':
        return const Color(0xFFF59E0B);
      case 'delivered':
        return const Color(0xFF059669);
      case 'delayed':
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF2563EB);
    }
  }

}
