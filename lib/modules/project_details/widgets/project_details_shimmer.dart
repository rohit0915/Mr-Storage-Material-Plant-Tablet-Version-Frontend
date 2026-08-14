import 'package:flutter/material.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';

class ProjectDetailsShimmer extends StatelessWidget {
  const ProjectDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Bar Skeleton (Back button, Title, Upload Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: const [
                  ShimmerBox(width: 80, height: 36, borderRadius: 8),
                  SizedBox(width: 16),
                  ShimmerBox(width: 220, height: 22, borderRadius: 6),
                  Spacer(),
                  ShimmerBox(width: 160, height: 38, borderRadius: 8),
                ],
              ),
            ),

            // 2. Row of 5 Quick Action Pill Buttons Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: const [
                  ShimmerBox(width: 120, height: 32, borderRadius: 8),
                  SizedBox(width: 10),
                  ShimmerBox(width: 150, height: 32, borderRadius: 8),
                  SizedBox(width: 10),
                  ShimmerBox(width: 130, height: 32, borderRadius: 8),
                  SizedBox(width: 10),
                  ShimmerBox(width: 140, height: 32, borderRadius: 8),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Main Project Info Header Card Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        ShimmerBox(width: 40, height: 40, borderRadius: 8),
                        SizedBox(width: 12),
                        ShimmerBox(width: 200, height: 20, borderRadius: 4),
                        SizedBox(width: 12),
                        ShimmerBox(width: 110, height: 22, borderRadius: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 52.0),
                      child: ShimmerBox(width: 80, height: 12, borderRadius: 4),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 16),

                    // Top Row Attributes (4 Columns)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerBox(width: 110, height: 36, borderRadius: 6),
                        ShimmerBox(width: 100, height: 36, borderRadius: 6),
                        ShimmerBox(width: 100, height: 36, borderRadius: 6),
                        ShimmerBox(width: 110, height: 36, borderRadius: 6),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 16),

                    // Bottom Row (3 Equal Boxes Skeleton)
                    Row(
                      children: List.generate(3, (i) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 2 ? 16.0 : 0.0),
                            padding: const EdgeInsets.all(14),
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                ShimmerBox(width: 120, height: 14, borderRadius: 4),
                                SizedBox(height: 8),
                                ShimmerBox(width: 90, height: 12, borderRadius: 4),
                                SizedBox(height: 6),
                                ShimmerBox(width: 140, height: 10, borderRadius: 4),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Stepper Card Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 140, height: 18, borderRadius: 4),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(8, (index) {
                        return Expanded(
                          child: Column(
                            children: const [
                              ShimmerBox(width: 22, height: 22, borderRadius: 11),
                              SizedBox(height: 6),
                              ShimmerBox(width: 50, height: 10, borderRadius: 4),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 5. 3 Column Cards Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 16.0 : 0.0),
                      height: 240,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(width: 110, height: 16, borderRadius: 4),
                          SizedBox(height: 20),
                          Center(child: ShimmerBox(width: 90, height: 90, borderRadius: 45)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
