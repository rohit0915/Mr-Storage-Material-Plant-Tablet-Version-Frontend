import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/app_colors.dart';
import '../controller/project_details_controller.dart';
import 'bom_uploaded_success_dialog.dart';

class UploadBomDialog extends StatelessWidget {
  final Future<void> Function()? onUploaded;

  const UploadBomDialog({super.key, this.onUploaded});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectDetailsController>();
    controller.resetUpload();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(28),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload BOM File',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select a building to replace or upload up to 5 BOM files.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _existingFiles(controller),
              const SizedBox(height: 16),
              InkWell(
                onTap: controller.isUploading.value
                    ? null
                    : () {
                        if (controller.selectedBuildingId.value.isEmpty &&
                            controller.buildings.isNotEmpty) {
                          final firstId = controller
                              .buildingId(controller.buildings.first);
                          controller.selectBuildingForUpload(firstId);
                        }
                        controller.pickUploadFiles(isBom: true);
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3B82F6)),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFF2563EB),
                        size: 38,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Browse BOM files',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'OUT, CSV, XLSX, XLS, PDF or ZIP',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.selectedUploadFiles.isNotEmpty) ...[
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.selectedUploadFiles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final file = controller.selectedUploadFiles[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.description_outlined,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Ready to upload',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () =>
                                  controller.removeUploadFile(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (controller.isUploading.value) ...[
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: controller.uploadProgress.value,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2563EB),
                  ),
                ),
              ],
              if (controller.uploadError.value.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  controller.uploadError.value,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: controller.isUploading.value ? null : Get.back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: controller.isUploading.value
                        ? null
                        : () async {
                            final success = await controller
                                .uploadSelectedFiles(isBom: true);
                            if (success) {
                              await onUploaded?.call();
                              Get.back();
                              Get.dialog(const BomUploadedSuccessDialog());
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: controller.isUploading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Upload',
                            style: TextStyle(
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
      ),
    );
  }

  Widget _existingFiles(ProjectDetailsController controller) {
    if (controller.buildings.isEmpty) {
      return const Text(
        'No buildings are available for this project.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.buildings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final building = controller.buildings[index];
          final id = controller.buildingId(building);
          final existing = controller.existingFileForBuilding(id, isBom: true);
          final fileName =
              (existing?['fileName'] ?? existing?['name'] ?? 'No BOM uploaded')
                  .toString();
          final itemCount = existing?['itemCount'] ??
              existing?['totalItems'] ??
              (existing?['items'] is List
                  ? (existing!['items'] as List).length
                  : null);
          final status = _status(existing?['status'] ?? existing?['bomStatus']);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              controller.buildingName(building),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (existing != null) ...[
                            const SizedBox(width: 8),
                            _statusBadge(status),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        itemCount == null
                            ? fileName
                            : '$fileName  •  Items: $itemCount',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: controller.isUploading.value
                      ? null
                      : () async {
                          controller.selectBuildingForUpload(id);
                          await controller.pickUploadFiles(isBom: true);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    existing == null ? 'Upload file' : 'Replace file',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: status.toLowerCase().contains('confirmed')
              ? const Color(0xFFDBEAFE)
              : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: status.toLowerCase().contains('confirmed')
                ? const Color(0xFF1D4ED8)
                : const Color(0xFFD97706),
          ),
        ),
      );

  String _status(dynamic value) {
    final text = (value ?? 'Pending').toString().replaceAll('_', ' ');
    return text
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
