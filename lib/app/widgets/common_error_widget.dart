import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';
import 'common_button.dart';

class CommonErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CommonErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
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
            if (onRetry != null)
              SizedBox(
                width: 120,
                child: CommonButton(
                  text: AppStrings.retry,
                  onPressed: onRetry!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
