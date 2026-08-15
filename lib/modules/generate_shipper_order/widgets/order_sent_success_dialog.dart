import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steel_building_plant_panel/app/utils/app_icons.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../controller/generate_shipper_order_controller.dart';

class OrderSentSuccessDialog extends StatelessWidget {
  const OrderSentSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 400,
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
              'Order sent to Shippers\nsuccessfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'After Shipper/vendor processes the order, they prepare the actual shipment. Then they send the shipper file.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: 200,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  final controller = Get.find<GenerateShipperOrderController>();
                  Get.back();
                  Get.offNamed(
                    AppRoutes.projectShipperFiles,
                    parameters: {
                      'id': controller.projectId.value,
                      'name': controller.projectName.value,
                    },
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
                  'Ok',
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
