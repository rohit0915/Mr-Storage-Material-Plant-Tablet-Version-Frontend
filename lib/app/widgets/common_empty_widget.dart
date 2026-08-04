import 'package:flutter/material.dart';
import '../utils/app_text_styles.dart';

class CommonEmptyWidget extends StatelessWidget {
  final String message;

  const CommonEmptyWidget({
    super.key,
    this.message = 'No Data Found',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyText1,
          ),
        ],
      ),
    );
  }
}
