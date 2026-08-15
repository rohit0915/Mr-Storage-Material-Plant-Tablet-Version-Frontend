import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

/// App-wide Toast Notification helper using [toastification] package.
/// Formatted specifically with [ToastificationStyle.flatColored] for clean Tablet layout.
class CommonSnackbar {
  CommonSnackbar._();

  /// Recommended style for the Tablet Application view.
  /// [ToastificationStyle.flatColored] provides soft background tints, readable text, 
  /// clean borders, progress indicator, and action close buttons.
  static const ToastificationStyle defaultStyle = ToastificationStyle.flatColored;
  static const Alignment defaultAlignment = Alignment.topRight;

  static void showSuccess({
    required String message,
    String title = 'Success',
    Duration duration = const Duration(seconds: 4),
    ToastificationStyle style = defaultStyle,
    Alignment alignment = defaultAlignment,
  }) {
    final BuildContext? context = Get.context;
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: style,
      alignment: alignment,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      boxShadow: lowModeShadow,
      showProgressBar: true,
      dragToClose: true,
    );
  }

  static void showError({
    required String message,
    String title = 'Error',
    Duration duration = const Duration(seconds: 4),
    ToastificationStyle style = defaultStyle,
    Alignment alignment = defaultAlignment,
  }) {
    final BuildContext? context = Get.context;
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: style,
      alignment: alignment,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      boxShadow: lowModeShadow,
      showProgressBar: true,
      dragToClose: true,
    );
  }

  static void showInfo({
    required String message,
    String title = 'Information',
    Duration duration = const Duration(seconds: 4),
    ToastificationStyle style = defaultStyle,
    Alignment alignment = defaultAlignment,
  }) {
    final BuildContext? context = Get.context;
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: style,
      alignment: alignment,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      boxShadow: lowModeShadow,
      showProgressBar: true,
      dragToClose: true,
    );
  }

  static void showWarning({
    required String message,
    String title = 'Warning',
    Duration duration = const Duration(seconds: 4),
    ToastificationStyle style = defaultStyle,
    Alignment alignment = defaultAlignment,
  }) {
    final BuildContext? context = Get.context;
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: style,
      alignment: alignment,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      boxShadow: lowModeShadow,
      showProgressBar: true,
      dragToClose: true,
    );
  }

  /// Generic helper method to show custom toasts with full control over style
  static void show({
    required String title,
    String? message,
    ToastificationType type = ToastificationType.info,
    ToastificationStyle style = defaultStyle,
    Alignment alignment = defaultAlignment,
    Duration duration = const Duration(seconds: 4),
  }) {
    final BuildContext? context = Get.context;
    toastification.show(
      context: context,
      type: type,
      style: style,
      alignment: alignment,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      description: message != null && message.isNotEmpty
          ? Text(
              message,
              style: const TextStyle(
                fontSize: 13,
              ),
            )
          : null,
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      boxShadow: lowModeShadow,
      showProgressBar: true,
      dragToClose: true,
    );
  }
}

