import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/packing_list_controller.dart';

class PackingListDetailsView extends GetView<PackingListController> {
  const PackingListDetailsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    drawer: const AppDrawer(),
    body: SafeArea(
      child: Column(
        children: [
          const DashboardAppBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const CommonLoader();
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppBackButton(),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Packing List',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (controller
                                .selectedProjectName
                                .value
                                .isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                controller.selectedProjectName.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: controller.downloadPackingPdf,
                          icon: const Icon(Icons.download),
                          label: const Text('Download packing lists'),
                        ),
                        OutlinedButton.icon(
                          onPressed: controller.exportBundlesCsv,
                          icon: const Icon(Icons.table_chart),
                          label: const Text('Export bundles'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (controller.bundleListItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No bundles in this packing list.'),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Bundle')),
                            DataColumn(label: Text('Profile')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Items')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Length (ft)')),
                            DataColumn(label: Text('Total weight')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: controller.bundleListItems
                              .map(
                                (item) => DataRow(
                                  cells:
                                      [
                                            item.bundleId,
                                            item.profile,
                                            item.partNumber,
                                            item.items,
                                            '${item.quantity}',
                                            item.length,
                                            item.unitWeight,
                                            item.status,
                                          ]
                                          .map((value) => DataCell(Text(value)))
                                          .toList(),
                                ),
                              )
                              .toList(),
                        ),
                      ),
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
