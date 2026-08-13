import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../model/qr_labels_model.dart';

class QrCodeDialog extends StatelessWidget {
  final BundleQrLabelItemModel item;
  final String projectName;

  const QrCodeDialog({
    super.key,
    required this.item,
    this.projectName = 'RiversideComplex',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Header with Close Button
            Stack(
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'QR Code Data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: -4,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Content Row (QR Code + Detail Key-Values)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom Painter QR Code
                Container(
                  width: 180,
                  height: 180,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  ),
                  child: CustomPaint(
                    size: const Size(164, 164),
                    painter: QrPainter(),
                  ),
                ),
                const SizedBox(width: 32),

                // Key-Value List
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'project=$projectName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Shipper :', 'shipper=${item.shipper}'),
                      const SizedBox(height: 8),
                      _buildDetailRow('Load :', 'load_id=${item.loadId}'),
                      const SizedBox(height: 8),
                      _buildDetailRow('Bundle :', 'bundle_id=${item.bundleId}'),
                      const SizedBox(height: 8),
                      _buildDetailRow('Parts :', 'parts=${item.parts}'),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Weight :',
                        'weight=${item.weight.replaceAll(RegExp(r'[^0-9]'), '')}',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Length :',
                        'Length=${item.length.replaceAll(RegExp(r'[^0-9]'), '')}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Export',
                          'Exporting PDF for ${item.bundleId}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Export PDF',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Print',
                          'Printing label for ${item.bundleId}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Print',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter that draws a clean QR code matrix with 3 finder patterns
class QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellWidth = size.width / 21;
    final cellHeight = size.height / 21;

    // Helper to draw a single module cell
    void drawCell(int row, int col) {
      canvas.drawRect(
        Rect.fromLTWH(col * cellWidth, row * cellHeight, cellWidth, cellHeight),
        paint,
      );
    }

    // Helper to draw a QR finder pattern (7x7 outer square, 3x3 inner square)
    void drawFinderPattern(int topRow, int leftCol) {
      for (int r = 0; r < 7; r++) {
        for (int c = 0; c < 7; c++) {
          if (r == 0 ||
              r == 6 ||
              c == 0 ||
              c == 6 ||
              (r >= 2 && r <= 4 && c >= 2 && c <= 4)) {
            drawCell(topRow + r, leftCol + c);
          }
        }
      }
    }

    // Draw the 3 standard QR finder patterns
    drawFinderPattern(0, 0); // Top Left
    drawFinderPattern(0, 14); // Top Right
    drawFinderPattern(14, 0); // Bottom Left

    // Standard timing pattern lines
    for (int i = 6; i < 15; i += 2) {
      drawCell(6, i);
      drawCell(i, 6);
    }

    // Mock QR data pattern matrix
    final dataPoints = [
      // Top section details
      [2, 8], [3, 9], [4, 8], [4, 10], [1, 11], [5, 12],
      [8, 1], [9, 3], [10, 2], [11, 4], [12, 1], [10, 5],
      [8, 15], [9, 17], [10, 18], [11, 15], [12, 19], [8, 19],
      // Center area
      [8, 8], [8, 9], [8, 11], [9, 10], [9, 12], [10, 8], [10, 10], [10, 12],
      [11, 9], [11, 11], [12, 8], [12, 10], [12, 12],
      // Bottom Right & Alignment area
      [14, 14], [14, 15], [14, 16], [14, 17], [14, 18],
      [15, 14], [15, 18], [16, 14], [16, 16], [16, 18],
      [17, 14], [17, 18], [18, 14], [18, 15], [18, 16], [18, 17], [18, 18],
      // Random data modules
      [14, 9], [15, 7], [16, 10], [17, 8], [18, 11], [19, 9], [20, 8],
      [9, 14], [7, 16], [10, 19], [8, 20], [11, 18], [9, 20],
      [15, 2], [17, 4], [19, 1], [20, 3], [18, 5], [20, 5],
      [2, 18], [4, 19], [1, 20], [5, 20],
    ];

    for (var pt in dataPoints) {
      drawCell(pt[0], pt[1]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
