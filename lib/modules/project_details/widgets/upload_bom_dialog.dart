import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../controller/project_details_controller.dart';
import 'single_building_upload_bom_dialog.dart';

class UploadBomDialog extends StatelessWidget {
  final Future<void> Function()? onUploaded;

  const UploadBomDialog({super.key, this.onUploaded});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectDetailsController>();
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
                    onPressed: controller.isConsolidatingBom.value
                        ? null
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
                            'Consolidate',
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
          final rawJobStatus = (existing?['status'] ??
                  existing?['bomJobStatus'] ??
                  existing?['jobStatus'] ??
                  building['status'] ??
                  '')
              .toString();
          final jobStatus = rawJobStatus.toLowerCase();
          final isConfirmed = existing?['isConfirmed'] == true ||
              existing?['isBomConfirmed'] == true ||
              existing?['confirmed'] == true ||
              building['isConfirmed'] == true ||
              building['isBomConfirmed'] == true ||
              building['confirmed'] == true ||
              jobStatus.contains('confirm');

          final isCompleted = jobStatus == 'completed' ||
              jobStatus == 'bom_extraction_complete' ||
              jobStatus == 'bom_review_complete' ||
              jobStatus == 'confirmed' ||
              jobStatus == 'bom confirmed' ||
              isConfirmed;

          final status = isConfirmed
              ? 'BOM Confirmed'
              : isCompleted
                  ? 'BOM Extracted'
                  : _status(rawJobStatus.isNotEmpty ? rawJobStatus : 'Processing');
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
                      onPressed: () {
                        controller.selectBuildingForUpload(id);
                        Get.dialog(
                          SingleBuildingUploadBomDialog(
                            buildingId: id,
                            buildingName: buildingTitle,
                            onUploaded: onUploaded,
                          ),
                        );
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
                      onPressed: !hasFile || !isCompleted || bomJobId.isEmpty
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
                              )?.then((_) {
                                controller.loadProjectDetails();
                              });
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
          status.toLowerCase().contains('confirm') ||
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
            status.toLowerCase().contains('confirm') ||
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
