import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../model/dashboard_models.dart';

class TopMetricsRow extends StatelessWidget {
  final List<TopMetricModel> metrics;

  const TopMetricsRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: List.generate(metrics.length, (index) {
          final item = metrics[index];
          return SizedBox(
            width: 175,
            child: InkWell(
              onTap: () {
                if (index == 0) {
                  Get.toNamed(AppRoutes.projects);
                } else if (index == 1) {
                  Get.toNamed(AppRoutes.loadPlanning);
                } else if (index == 2) {
                  Get.toNamed(AppRoutes.packingList);
                } else if (index == 3) {
                  Get.toNamed(AppRoutes.deliveryDetails);
                } else if (index == 4) {
                  Get.toNamed(AppRoutes.projectDrawings);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: EdgeInsets.only(
                  right: index == metrics.length - 1 ? 0 : 12.0,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: item.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: item.backgroundColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.count,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        item.iconAsset,
                        color: Colors.white,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.build_outlined, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
