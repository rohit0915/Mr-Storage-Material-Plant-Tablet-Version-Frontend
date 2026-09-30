import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../../app/utils/app_colors.dart';
import '../model/qr_labels_model.dart';

class QrCodeDialog extends StatelessWidget {
  final BundleQrLabelItemModel item;
  final String projectName;

  const QrCodeDialog({super.key, required this.item, this.projectName = ''});

  String get payload {
    final bId = item.bundleId.isNotEmpty ? item.bundleId : '';
    if (bId.isNotEmpty) {
      return 'https://storage-material-vendor-deployment.vercel.app/bundle/$bId';
    }
    return Uri(
      queryParameters: {
        'project': projectName,
        'shipper': item.shipper,
        'load_id': item.loadId,
        'bundle_id': item.bundleId,
        'parts': item.parts,
        'weight': item.weight,
        'length': item.length,
      },
    ).query;
  }

  Future<List<int>> _labelBytes() => FileExportService.qrPdf(
    title: 'QR Label — ${item.bundleId}',
    payload: payload,
  );

  Future<void> _export() async {
    try {
      final bytes = Uint8List.fromList(await _labelBytes());
      await FileExportService.savePdf(
        fileName: 'qr_label_${item.bundleId}',
        bytes: bytes,
      );
      CommonSnackbar.showSuccess(
        title: 'Export complete',
        message: 'QR label PDF was downloaded.',
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Export failed',
        message: error.toString(),
      );
    }
  }

  Future<void> _print() async {
    try {
      final bytes = Uint8List.fromList(await _labelBytes());
      await FileExportService.printPdf(
        name: 'QR label ${item.bundleId}',
        bytes: bytes,
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Print failed',
        message: error.toString(),
      );
    }
  }

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
                  child: QrImageView(
                    data: payload,
                    size: 164,
                    backgroundColor: Colors.white,
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
                      onPressed: _export,
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
                      onPressed: _print,
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
