import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_images.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../model/project_drawings_model.dart';

class DrawingDetailsDialog extends StatefulWidget {
  final DrawingItemModel item;

  const DrawingDetailsDialog({super.key, required this.item});

  @override
  State<DrawingDetailsDialog> createState() => _DrawingDetailsDialogState();
}

class _DrawingDetailsDialogState extends State<DrawingDetailsDialog> {
  Uint8List? _pdfBytes;
  bool _isLoading = false;
  bool _isPdf = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkAndLoadContent();
  }

  Future<void> _checkAndLoadContent() async {
    final url = widget.item.fileUrl.trim();
    final title = widget.item.title.toLowerCase();
    final isPdfExtension = title.endsWith('.pdf') || url.toLowerCase().contains('.pdf');

    if (url.isEmpty) return;

    if (isPdfExtension) {
      setState(() {
        _isLoading = true;
        _isPdf = true;
      });

      try {
        final response = await Dio().get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = Uint8List.fromList(response.data ?? const <int>[]);
        final isPdfMagic =
            bytes.length >= 4 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46;

        if (mounted) {
          setState(() {
            if (isPdfMagic) {
              _pdfBytes = bytes;
              _isPdf = true;
            } else {
              _isPdf = false;
            }
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
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
            // Top Header: Title, PEB Code, Metadata, Close X
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
                _buildMetaCell(item.location),
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

            // Blueprint Image / PDF Canvas Container (Renders PDF or Image dynamically)
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
                child: _buildContentArea(),
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Toolbar: Download Button & Action Buttons / Status Pill
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
                    backgroundColor: const Color(0xFF94A3B8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
                const Spacer(),

                // Action Buttons or Status Pill (Matching Image 1)
                if (item.status.toLowerCase().contains('pending')) ...[
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      CommonSnackbar.showSuccess(
                        title: 'Status Updated',
                        message: 'Marked as Revision Required',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Revision Required',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      CommonSnackbar.showSuccess(
                        title: 'Drawing Approved',
                        message: '${item.title} has been approved.',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isPdf && _pdfBytes != null) {
      return PdfPreview(
        build: (_) async => _pdfBytes!,
        pdfFileName: widget.item.title,
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        useActions: false,
        loadingWidget: const Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.item.fileUrl.isNotEmpty && !_hasError && !_isPdf) {
      return Center(
        child: Image.network(
          widget.item.fileUrl,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) => _fallbackPreview(),
        ),
      );
    }

    return Center(child: _fallbackPreview());
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
