import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/services/shared_pref_service.dart';
import '../../../app/utils/app_colors.dart';

class GreetingHeaderSection extends StatelessWidget {
  const GreetingHeaderSection({super.key});

  String _getUserName() {
    if (Get.isRegistered<SharedPrefService>()) {
      final jsonStr = Get.find<SharedPrefService>().getUserData();
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final data = jsonDecode(jsonStr);
          final name = data['name'];
          if (name != null && name.toString().trim().isNotEmpty) {
            return name.toString().trim();
          }
        } catch (_) {}
      }
    }
    return 'Operator';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getTimeString() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _getDateString() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final monthStr = months[now.month - 1];
    final dayStr = weekdays[now.weekday - 1];
    return '$monthStr ${now.day}, ${now.year} - $dayStr';
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserName();
    final greeting = _getGreeting();
    final timeStr = _getTimeString();
    final dateStr = _getDateString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $userName 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Plant Panel Operator',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
