import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';
import 'common_button.dart';

class CommonErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  const CommonErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyText1.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onBack ?? () => Get.back(),
                  icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
                  label: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: CommonButton(
                      text: AppStrings.retry,
                      onPressed: onRetry!,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
