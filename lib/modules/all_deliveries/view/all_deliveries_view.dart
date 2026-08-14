import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/app_colors.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/all_deliveries_controller.dart';

class AllDeliveriesView extends GetView<AllDeliveriesController> {
  const AllDeliveriesView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    drawer: const AppDrawer(),
    body: SafeArea(
      child: Column(
        children: [
          const DashboardAppBar(),
          Expanded(
            child: Obx(
              () => SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Deliveries',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Comprehensive delivery management and tracking',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: controller.stats.entries
                          .map(
                            (entry) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${entry.value}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        SizedBox(
                          width: 360,
                          child: TextField(
                            onChanged: (value) =>
                                controller.searchQuery.value = value,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText:
                                  'Search by ID, project, customer, item, vendor...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: controller.selectedStatus.value,
                          items: controller.statuses
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              controller.selectedStatus.value =
                                  value ?? 'All Status',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (controller.isLoading.value)
                      const Center(child: CircularProgressIndicator())
                    else if (controller.errorMessage.value.isNotEmpty)
                      Center(child: Text(controller.errorMessage.value))
                    else
                      Container(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns:
                                const [
                                      'ID',
                                      'Status',
                                      'Items',
                                      'Project',
                                      'Customer',
                                      'Vendor',
                                      'Carrier',
                                      'POC',
                                      'Delivery Date',
                                      'Equipment',
                                      'Site',
                                    ]
                                    .map(
                                      (label) => DataColumn(label: Text(label)),
                                    )
                                    .toList(),
                            rows: controller.filteredDeliveries
                                .map(
                                  (item) => DataRow(
                                    cells:
                                        [
                                              item.id,
                                              item.status,
                                              item.items,
                                              item.project,
                                              item.customer,
                                              item.vendor,
                                              item.carrier,
                                              item.poc,
                                              item.deliveryDate,
                                              item.equipment,
                                              item.site,
                                            ]
                                            .map(
                                              (value) => DataCell(
                                                SizedBox(
                                                  width: 130,
                                                  child: Text(
                                                    value,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
