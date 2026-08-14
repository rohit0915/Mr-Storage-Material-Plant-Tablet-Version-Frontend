import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonSnackbar {
  CommonSnackbar._();

  static void showSuccess({
    required String message,
    String title = 'Success',
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF065F46),
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF047857),
          height: 1.3,
        ),
      ),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFF10B981),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
      backgroundColor: const Color(0xFFECFDF5),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.only(top: 24, right: 24, left: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      borderWidth: 1,
      borderColor: const Color(0xFFA7F3D0),
      duration: duration,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void showError({
    required String message,
    String title = 'Error',
    Duration duration = const Duration(seconds: 4),
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF991B1B),
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFFB91C1C),
          height: 1.3,
        ),
      ),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
      backgroundColor: const Color(0xFFFEF2F2),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.only(top: 24, right: 24, left: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      borderWidth: 1,
      borderColor: const Color(0xFFFCA5A5),
      duration: duration,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
