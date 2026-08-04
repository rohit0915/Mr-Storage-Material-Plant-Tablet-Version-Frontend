import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_strings.dart';
import 'common_button.dart';

class CommonDialog {
  CommonDialog._();

  static void show({
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: () {
                Get.back();
                onCancel();
              },
              child: Text(cancelText ?? AppStrings.cancel),
            ),
          CommonButton(
            text: confirmText ?? AppStrings.confirm,
            onPressed: () {
              Get.back();
              if (onConfirm != null) onConfirm();
            },
          ),
        ],
      ),
    );
  }
}
