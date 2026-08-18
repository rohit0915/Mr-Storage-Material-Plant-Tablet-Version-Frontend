import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_images.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../model/project_drawings_model.dart';

class DrawingDetailsDialog extends StatelessWidget {
  final DrawingItemModel item;

  const DrawingDetailsDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.status == 'Approved'
        ? const Color(0xFF16A34A)
        : item.status.contains('Revision')
            ? const Color(0xFFDC2626)
            : const Color(0xFFEAB308);

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
            // Top Header: Title, PEB Code, Metadata, Close X (Responsive layout preventing 188px overflow)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.split('.').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.pebCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildMetaCell('Pune,\nMaharashtra'),
                const SizedBox(width: 12),
                Flexible(
                  flex: 3,
                  child: _buildMetaCell('Uploaded By:\n${item.uploadedBy}'),
                ),
                const SizedBox(width: 12),
                _buildMetaCell('Received on\n${item.date}'),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Blueprint Image / PDF Canvas Container (Renders drawing / PDF directly in-place)
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
                child: Center(
                  child: item.fileUrl.isNotEmpty
                      ? Image.network(
                          item.fileUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) =>
                              _fallbackPreview(),
                        )
                      : _fallbackPreview(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Toolbar: Download Button & Status Pill
            Row(
              children: [
                // Download Button
                ElevatedButton.icon(
                  onPressed: () {
                    CommonSnackbar.showSuccess(
                      title: 'Download Started',
                      message: 'Downloading ${item.title}...',
                    );
                  },
                  icon: const Icon(Icons.south, size: 16, color: Colors.white),
                  label: const Text(
                    'Download',
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const Spacer(),

                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status,
                    style: const TextStyle(
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
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textSecondary,
        height: 1.3,
      ),
    );
  }

  Widget _fallbackPreview() {
    return Image.asset(
      AppImages.blueprint,
      fit: BoxFit.contain,
      errorBuilder: (ctx, err, stack) => const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 64,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
