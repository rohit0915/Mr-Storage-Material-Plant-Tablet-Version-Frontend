import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/customer_info_controller.dart';
import '../widgets/customer_invoice_table.dart';
import '../widgets/customer_profile_card.dart';
import '../widgets/customer_projects_table.dart';
import '../widgets/customer_stat_cards.dart';

class CustomerInfoView extends GetView<CustomerInfoController> {
  const CustomerInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Fixed at top)
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                final prof = controller.profile.value;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button & Screen Title Header Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
                              label: const Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Customer Info',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Customer Profile Info Card
                      if (prof != null) CustomerProfileCard(profile: prof),

                      // 4 Metric Stat Cards (Total Projects, Completed, Work in progress, Canceled)
                      CustomerStatCards(stats: controller.stats),

                      // All Projects Data Table
                      CustomerProjectsTable(projects: controller.projects),

                      // Invoice List Data Table
                      CustomerInvoiceTable(invoices: controller.invoices),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
