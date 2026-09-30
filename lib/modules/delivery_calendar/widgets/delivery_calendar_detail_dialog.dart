import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../model/delivery_calendar_model.dart';

class DeliveryCalendarDetailDialog extends StatelessWidget {
  final DeliveryCalendarItemModel item;

  const DeliveryCalendarDetailDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 860,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status Badges
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.id,
                  style: const TextStyle(
                    fontSize: 13,
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
                        fontSize: 11,
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
                        fontSize: 11,
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
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Grid Row 1
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
                    iconColor: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Grid Row 2
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
            const SizedBox(height: 28),

            // 4 Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.deliveryDetails, parameters: {'deliveryId': item.rawId});
                    },
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.deliveryDetails, parameters: {'deliveryId': item.rawId});
                    },
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.deliveryDetails, parameters: {'deliveryId': item.rawId});
                    },
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Reminder Sent',
                        'Notification reminder sent to carrier and site contact.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF2563EB),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                    },
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  Widget _buildDetailCell(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
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
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: iconColor ?? AppColors.textSecondary),
              const SizedBox(width: 6),
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
}
