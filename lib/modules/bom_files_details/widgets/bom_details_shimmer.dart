import 'package:flutter/material.dart';

import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';

class BomDetailsShimmer extends StatelessWidget {
  const BomDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                ShimmerBox(width: 82, height: 36, borderRadius: 8),
                SizedBox(width: 16),
                ShimmerBox(width: 210, height: 24, borderRadius: 5),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: _card(),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: ShimmerBox(width: 340, height: 26, borderRadius: 5),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: List.generate(
                      2,
                      (index) => Expanded(
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(right: index == 0 ? 20 : 0),
                          padding: const EdgeInsets.all(20),
                          decoration: _softCard(),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(
                                width: 150,
                                height: 20,
                                borderRadius: 4,
                              ),
                              SizedBox(height: 22),
                              ShimmerBox(
                                width: double.infinity,
                                height: 12,
                                borderRadius: 4,
                              ),
                              SizedBox(height: 16),
                              ShimmerBox(
                                width: double.infinity,
                                height: 12,
                                borderRadius: 4,
                              ),
                              SizedBox(height: 16),
                              ShimmerBox(
                                width: double.infinity,
                                height: 12,
                                borderRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    height: 112,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: ShimmerBox(
                              width: 210,
                              height: 48,
                              borderRadius: 4,
                            ),
                          ),
                        ),
                        VerticalDivider(width: 2, color: Colors.black),
                        Expanded(
                          child: Center(
                            child: ShimmerBox(
                              width: 300,
                              height: 62,
                              borderRadius: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Row(
                    children: [
                      ShimmerBox(width: 90, height: 18, borderRadius: 4),
                      SizedBox(width: 30),
                      ShimmerBox(width: 110, height: 18, borderRadius: 4),
                      SizedBox(width: 30),
                      ShimmerBox(width: 100, height: 18, borderRadius: 4),
                      SizedBox(width: 30),
                      ShimmerBox(width: 100, height: 18, borderRadius: 4),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(
                    6,
                    (_) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 16,
                        borderRadius: 4,
                      ),
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

  static BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.inputBorder),
  );

  static BoxDecoration _softCard() => BoxDecoration(
    color: const Color(0xFFF8FAFC),
    borderRadius: BorderRadius.circular(12),
  );
}
