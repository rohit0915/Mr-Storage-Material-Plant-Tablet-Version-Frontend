import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'app_shimmer.dart';

class CommonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CommonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                ShimmerBox(width: 86, height: 36, borderRadius: 8),
                SizedBox(width: 16),
                ShimmerBox(width: 230, height: 24, borderRadius: 6),
                Spacer(),
                ShimmerBox(width: 128, height: 36, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Container(
                    height: 88,
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 12),
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 92, height: 11, borderRadius: 4),
                        SizedBox(height: 12),
                        ShimmerBox(width: 54, height: 20, borderRadius: 5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: width,
              constraints: BoxConstraints(minHeight: height),
              decoration: _cardDecoration(radius: borderRadius),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ShimmerBox(width: 150, height: 18, borderRadius: 5),
                        Spacer(),
                        ShimmerBox(width: 220, height: 34, borderRadius: 8),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      children: List.generate(
                        6,
                        (_) => const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 14),
                            child: ShimmerBox(
                              width: 70,
                              height: 11,
                              borderRadius: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(
                    6,
                    (index) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          child: Row(
                            children: List.generate(
                              6,
                              (column) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: ShimmerBox(
                                    width: column == 0 ? 100 : 62,
                                    height: column == 0 ? 14 : 12,
                                    borderRadius: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (index < 5)
                          const Divider(height: 1, color: AppColors.divider),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  const Padding(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ShimmerBox(width: 120, height: 14, borderRadius: 4),
                        Spacer(),
                        ShimmerBox(width: 150, height: 28, borderRadius: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _cardDecoration({double radius = 12}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.inputBorder),
  );
}
