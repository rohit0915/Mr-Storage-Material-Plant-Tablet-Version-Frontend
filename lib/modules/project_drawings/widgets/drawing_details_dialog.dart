import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_images.dart';
import '../model/project_drawings_model.dart';

class DrawingDetailsDialog extends StatelessWidget {
  final DrawingItemModel item;

  const DrawingDetailsDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 720,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Title, PEB Code, Metadata, Close X
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.split('.').first,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.pebCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                _buildMetaCell('Pune,\nMaharashtra'),
                const SizedBox(width: 20),
                _buildMetaCell('Uploaded By:\n${item.uploadedBy}'),
                const SizedBox(width: 20),
                _buildMetaCell('Received on\n${item.date}'),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Blueprint Image Canvas Container
            Container(
              height: 380,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  AppImages.blueprint,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) {
                    return Image.asset(
                      'assets/images/img_blueprint.png',
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Toolbar: Download Button & Status Pill
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Download Started',
                      'Downloading ${item.title}...',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2563EB),
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.south, size: 16, color: Colors.white),
                  label: const Text(
                    'Download',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF94A3B8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCell(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textSecondary,
        height: 1.3,
      ),
    );
  }
}
