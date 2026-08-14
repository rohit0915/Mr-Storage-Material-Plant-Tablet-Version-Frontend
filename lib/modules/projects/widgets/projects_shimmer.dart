import 'package:flutter/material.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';

class ProjectsShimmer extends StatelessWidget {
  const ProjectsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Projects Header Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 140, height: 24, borderRadius: 6),
                  SizedBox(height: 6),
                  ShimmerBox(width: 280, height: 14, borderRadius: 4),
                ],
              ),
            ),

            // 2. 4 Stat Cards Skeleton Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 12.0 : 0.0),
                      padding: const EdgeInsets.all(16.0),
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          ShimmerBox(width: 100, height: 12, borderRadius: 4),
                          SizedBox(height: 10),
                          ShimmerBox(width: 40, height: 20, borderRadius: 4),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            // 3. Toolbar Skeleton (Buttons + Dropdowns)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      ShimmerBox(width: 100, height: 34, borderRadius: 8),
                      SizedBox(width: 8),
                      ShimmerBox(width: 100, height: 34, borderRadius: 8),
                    ],
                  ),
                  Row(
                    children: const [
                      ShimmerBox(width: 120, height: 34, borderRadius: 8),
                      SizedBox(width: 8),
                      ShimmerBox(width: 110, height: 34, borderRadius: 8),
                      SizedBox(width: 8),
                      ShimmerBox(width: 130, height: 34, borderRadius: 8),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Data Table Skeleton Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    // Table Header Skeleton
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Row(
                        children: const [
                          ShimmerBox(width: 18, height: 18, borderRadius: 4),
                          SizedBox(width: 16),
                          Expanded(flex: 3, child: ShimmerBox(width: 80, height: 12, borderRadius: 4)),
                          Expanded(flex: 3, child: ShimmerBox(width: 70, height: 12, borderRadius: 4)),
                          Expanded(flex: 2, child: ShimmerBox(width: 60, height: 12, borderRadius: 4)),
                          Expanded(flex: 3, child: ShimmerBox(width: 60, height: 12, borderRadius: 4)),
                          Expanded(flex: 2, child: ShimmerBox(width: 70, height: 12, borderRadius: 4)),
                          Expanded(flex: 2, child: ShimmerBox(width: 40, height: 12, borderRadius: 4)),
                          Expanded(flex: 2, child: ShimmerBox(width: 50, height: 12, borderRadius: 4)),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),

                    // Table Rows Skeleton (5 Rows)
                    ...List.generate(5, (index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                const ShimmerBox(width: 18, height: 18, borderRadius: 4),
                                const SizedBox(width: 16),
                                // Project Name + Subtitle
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      ShimmerBox(width: 110, height: 14, borderRadius: 4),
                                      SizedBox(height: 4),
                                      ShimmerBox(width: 60, height: 10, borderRadius: 4),
                                    ],
                                  ),
                                ),
                                // Customer with Avatar
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: const [
                                      ShimmerBox(width: 24, height: 24, borderRadius: 12),
                                      SizedBox(width: 8),
                                      ShimmerBox(width: 70, height: 12, borderRadius: 4),
                                    ],
                                  ),
                                ),
                                // Buildings
                                const Expanded(
                                  flex: 2,
                                  child: ShimmerBox(width: 20, height: 14, borderRadius: 4),
                                ),
                                // Status Badge
                                const Expanded(
                                  flex: 3,
                                  child: ShimmerBox(width: 100, height: 22, borderRadius: 12),
                                ),
                                // Project Value
                                const Expanded(
                                  flex: 2,
                                  child: ShimmerBox(width: 65, height: 14, borderRadius: 4),
                                ),
                                // Chat Button
                                const Expanded(
                                  flex: 2,
                                  child: ShimmerBox(width: 55, height: 22, borderRadius: 12),
                                ),
                                // Actions Button
                                const Expanded(
                                  flex: 2,
                                  child: ShimmerBox(width: 28, height: 28, borderRadius: 6),
                                ),
                              ],
                            ),
                          ),
                          if (index < 4) const Divider(height: 1, color: AppColors.divider),
                        ],
                      );
                    }),
                    const Divider(height: 1, color: AppColors.divider),

                    // Pagination Footer Skeleton
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          ShimmerBox(width: 120, height: 14, borderRadius: 4),
                          ShimmerBox(width: 60, height: 20, borderRadius: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
