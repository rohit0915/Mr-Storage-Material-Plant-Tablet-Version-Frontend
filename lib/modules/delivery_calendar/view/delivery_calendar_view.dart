import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
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

                      // Status Legend Bar
                      _buildStatusLegendCard(),
                      const SizedBox(height: 32),
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

        // Filters Button
        ElevatedButton(
          onPressed: () => controller.openFilterDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Filters',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),

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
                child: const Text(
                  "Today's Deliveries: 4 deliveries",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Weather: ☀️ Clear",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date Header
          const Text(
            'Tuesday, March 25, 2024',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Cards List
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
              Text(
                item.id,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
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
                  onPressed: () => controller.goToDeliveryDetails(),
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
                  onPressed: () => controller.openRescheduleDialog(),
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
                  onPressed: () => controller.openMarkDeliveredDialog(),
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
                  onPressed: () => controller.sendReminder(),
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
    final days = [
      {'day': 'MON', 'date': '24', 'month': 'Mar', 'isToday': false},
      {'day': 'TUE', 'date': '25', 'month': 'Mar', 'isToday': true},
      {'day': 'WED', 'date': '26', 'month': 'Mar', 'isToday': false},
      {'day': 'THU', 'date': '27', 'month': 'Mar', 'isToday': false},
      {'day': 'FRI', 'date': '28', 'month': 'Mar', 'isToday': false},
      {'day': 'SAT', 'date': '29', 'month': 'Mar', 'isToday': false},
      {'day': 'SUN', 'date': '30', 'month': 'Mar', 'isToday': false},
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Days Header Row
          Row(
            children: days.map((d) {
              final isToday = d['isToday'] as bool;
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      right: const BorderSide(color: AppColors.divider),
                      bottom: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        d['day'].toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d['date'].toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? const Color(0xFF2563EB)
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        d['month'].toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Days Content Grid Columns
          SizedBox(
            height: 450,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Container()), // Mon 24
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _buildWeekCard(
                          'Industrial Complex A',
                          'Acme Corp',
                          'Scheduled',
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildWeekCard(
                          'Storage Facility B',
                          'BuildTech LLC',
                          'Confirmed',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ), // Tue 25
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _buildWeekCard(
                          'Warehouse Complex',
                          'Steel Masters',
                          'Scheduled',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ), // Wed 26
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _buildWeekCard(
                          'Industrial Park C',
                          'Metro Build',
                          'Confirmed',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ), // Thu 27
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.divider),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.divider),
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(
    String project,
    String customer,
    String status,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        if (controller.deliveriesList.isNotEmpty) {
          Get.dialog(
            DeliveryCalendarDetailDialog(item: controller.deliveriesList.first),
          );
        }
      },
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
                    project,
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
              customer,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              status,
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
          // Month Selector Row
          Row(
            children: [
              const Text(
                'March 2024',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: const [
                    Text(
                      'Select Month',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Days Header
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((
              day,
            ) {
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

          // Calendar Days Grid (31 Days)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final dayNum = index + 1;
              final hasEvents = dayNum >= 23 && dayNum <= 25;

              return InkWell(
                onTap: () {
                  Get.dialog(
                    DayDeliveriesDialog(
                      dateTitle: 'Tuesday, March $dayNum, 2024',
                      items: controller.deliveriesList,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$dayNum',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (hasEvents) ...[
                        const SizedBox(height: 4),
                        Container(height: 2, color: const Color(0xFF2563EB)),
                        const SizedBox(height: 4),
                        const Text(
                          '2 Deliveries',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const Text(
                          '* Steel',
                          style: TextStyle(
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

  // STATUS LEGEND CARD (Image 1, 2, 3)
  Widget _buildStatusLegendCard() {
    final legendItems = [
      {'label': 'Draft', 'color': const Color(0xFFCBD5E1)},
      {'label': 'Scheduled', 'color': const Color(0xFF2563EB)},
      {'label': 'Confirmed', 'color': const Color(0xFF16A34A)},
      {'label': 'In Transit', 'color': const Color(0xFFF59E0B)},
      {'label': 'Delivered', 'color': const Color(0xFF059669)},
      {'label': 'Delayed', 'color': const Color(0xFFEA580C)},
      {'label': 'Cancelled', 'color': const Color(0xFFDC2626)},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Legend',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: legendItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
