import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmerLoading extends StatelessWidget {
  const DashboardShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Greeting Header Placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 220, height: 24, decoration: _boxDecoration()),
                    const SizedBox(height: 8),
                    Container(width: 140, height: 14, decoration: _boxDecoration()),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(width: 100, height: 20, decoration: _boxDecoration()),
                    const SizedBox(height: 8),
                    Container(width: 160, height: 14, decoration: _boxDecoration()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Top Metrics Row (5 Cards)
            Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 72,
                    margin: EdgeInsets.only(right: index == 4 ? 0 : 12.0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 60, height: 10, decoration: _boxDecoration()),
                            const SizedBox(height: 8),
                            Container(width: 36, height: 20, decoration: _boxDecoration()),
                          ],
                        ),
                        Container(width: 32, height: 32, decoration: _boxDecoration(radius: 8)),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // 3. Production Overview Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 180, height: 18, decoration: _boxDecoration()),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(5, (index) {
                      return Expanded(
                        child: Container(
                          height: 48,
                          margin: EdgeInsets.only(right: index == 4 ? 0 : 12),
                          decoration: _boxDecoration(radius: 10),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Three Column Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(3, (colIndex) {
                return Expanded(
                  child: Container(
                    height: 280,
                    margin: EdgeInsets.only(right: colIndex == 2 ? 0 : 16.0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 130, height: 16, decoration: _boxDecoration()),
                            Container(width: 50, height: 14, decoration: _boxDecoration()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(4, (rowIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Container(width: 36, height: 36, decoration: _boxDecoration(radius: 8)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: double.infinity, height: 12, decoration: _boxDecoration()),
                                      const SizedBox(height: 6),
                                      Container(width: 100, height: 10, decoration: _boxDecoration()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // 5. Recent Shipper Files Grid (4 Cards)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 180, height: 18, decoration: _boxDecoration()),
                    Container(width: 70, height: 14, decoration: _boxDecoration()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        height: 190,
                        margin: EdgeInsets.only(right: index == 3 ? 0 : 16.0),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(width: 60, height: 14, decoration: _boxDecoration()),
                                Container(width: 80, height: 20, decoration: _boxDecoration(radius: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(width: 140, height: 14, decoration: _boxDecoration()),
                            const SizedBox(height: 8),
                            Container(width: 90, height: 10, decoration: _boxDecoration()),
                            const Spacer(),
                            Container(width: double.infinity, height: 1, color: Colors.grey.shade200),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(width: 60, height: 12, decoration: _boxDecoration()),
                                Container(width: 60, height: 12, decoration: _boxDecoration()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 6. Drawing Approval Status Data Table Placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 200, height: 18, decoration: _boxDecoration()),
                  const SizedBox(height: 16),
                  ...List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(width: 32, height: 32, decoration: _boxDecoration(radius: 16)),
                          const SizedBox(width: 12),
                          Container(width: 120, height: 14, decoration: _boxDecoration()),
                          const Spacer(),
                          Container(width: 100, height: 14, decoration: _boxDecoration()),
                          const Spacer(),
                          Container(width: 80, height: 20, decoration: _boxDecoration(radius: 10)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration({double radius = 6}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
