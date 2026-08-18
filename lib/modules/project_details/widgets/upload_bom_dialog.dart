import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../controller/project_details_controller.dart';

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
        width: 580,
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
                          'Building BOM Files',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'View BOM status per building or upload/replace files.',
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
                          final firstId = controller.buildingId(
                            controller.buildings.first,
                          );
                          controller.selectBuildingForUpload(firstId);
                        }
                        controller.pickUploadFiles(isBom: true);
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
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
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed:
                        controller.isUploading.value ||
                            controller.isConsolidatingBom.value
                        ? null
                        : controller.selectedUploadFiles.isNotEmpty
                        ? () async {
                            final success = await controller
                                .uploadSelectedFiles(isBom: true);
                            if (success) {
                              await onUploaded?.call();
                              Get.snackbar(
                                'BOM uploaded',
                                'Extraction has started. Confirm every building BOM before consolidating.',
                              );
                            }
                          }
                        : controller.canConsolidateBom
                        ? () async {
                            final success = await controller
                                .generateConsolidatedBom();
                            if (!success) return;
                            Get.back();
                            Get.toNamed(
                              AppRoutes.bomFilesDetails,
                              parameters: {
                                'projectId': controller.projectId,
                                'id': controller.projectId,
                                'mode': 'consolidated',
                                'name': controller.projectName.value,
                                'customer': controller.customerName.value,
                                'projectJobId': controller.jobId.value,
                              },
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E56B9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child:
                        controller.isUploading.value ||
                            controller.isConsolidatingBom.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            controller.selectedUploadFiles.isNotEmpty
                                ? 'Upload'
                                : 'Consolidate',
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
    final buildingList = controller.buildings;

    if (buildingList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('No buildings found for this project.')),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 260),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: buildingList.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final building = buildingList[index];
          final id = controller.buildingId(building);
          final existing = controller.existingFileForBuilding(id, isBom: true);

          final buildingTitle = controller.buildingName(building).isNotEmpty
              ? controller.buildingName(building)
              : 'Building ${index + 1}';

          final fileName =
              (existing?['fileName'] ??
                      existing?['name'] ??
                      existing?['originalName'] ??
                      'No BOM uploaded')
                  .toString();

          final itemCount =
              existing?['itemCount'] ??
              existing?['totalItems'] ??
              (existing?['items'] is List
                  ? (existing!['items'] as List).length
                  : 0);

          final rawDate =
              existing?['uploadedAt'] ??
              existing?['createdAt'] ??
              existing?['date'];
          final parsedDate = DateTime.tryParse((rawDate ?? '').toString());
          final formattedDate = parsedDate == null
              ? '-'
              : '${_month(parsedDate.month)} ${parsedDate.day}';

          final hasFile = existing != null;
          final jobStatus =
              (existing?['status'] ?? existing?['bomJobStatus'] ?? '')
                  .toString()
                  .toLowerCase();
          final isCompleted = jobStatus == 'completed';
          final isConfirmed = existing?['isConfirmed'] == true;
          final status = isCompleted
              ? (isConfirmed ? 'BOM Confirmed' : 'BOM Extracted')
              : _status(
                  existing?['bomJobStatus'] ??
                      existing?['status'] ??
                      'Processing',
                );
          final bomJobId =
              (existing?['bomJobId'] ??
                      existing?['jobId'] ??
                      existing?['_id'] ??
                      '')
                  .toString();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      buildingTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(hasFile ? status : 'No BOM uploaded'),
                    const Spacer(),
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
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: Text(
                        hasFile ? 'Replace file' : 'Upload file',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: !hasFile || bomJobId.isEmpty
                          ? null
                          : () {
                              Get.back();
                              Get.toNamed(
                                AppRoutes.bomFilesDetails,
                                parameters: {
                                  'id': bomJobId,
                                  'projectId': controller.projectId,
                                  'buildingId': id,
                                  'buildingName': buildingTitle,
                                  'name': controller.projectName.value,
                                  'customer': controller.customerName.value,
                                  'projectJobId': controller.jobId.value,
                                  'date': controller.createdOn.value,
                                },
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                      ),
                      child: Text(
                        isCompleted && !isConfirmed
                            ? 'View and Confirm'
                            : 'View',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$fileName  •  Items: $itemCount  •  $formattedDate',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  Widget _statusBadge(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color:
          status.toLowerCase().contains('confirmed') ||
              status.toLowerCase().contains('uploaded')
          ? const Color(0xFFDBEAFE)
          : const Color(0xFFFEF3C7),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color:
            status.toLowerCase().contains('confirmed') ||
                status.toLowerCase().contains('uploaded')
            ? const Color(0xFF1D4ED8)
            : const Color(0xFFD97706),
      ),
    ),
  );

  String _status(dynamic value) {
    final text = (value ?? 'BOM Confirmed').toString().replaceAll('_', ' ');
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
