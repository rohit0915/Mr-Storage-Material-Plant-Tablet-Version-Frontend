import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steel_building_plant_panel/app/utils/app_icons.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';

class BomUploadedSuccessDialog extends StatelessWidget {
  final String projectId;
  final String projectName;

  const BomUploadedSuccessDialog({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 380,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppIcons.successfully,
              width: 115,
              height: 115,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            const Text(
              'BOM File Uploaded',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: 200,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.bomFilesDetails,
                    parameters: {'id': projectId, 'name': projectName},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'View BOM File',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
