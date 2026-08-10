import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/awarded_loads_controller.dart';

class AwardedLoadsView extends GetView<AwardedLoadsController> {
  const AwardedLoadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderToolbar(),
                      const SizedBox(height: 16),
                      _buildSummaryStatsRow(),
                      const SizedBox(height: 20),
                      _buildFilterRow(),
                      const SizedBox(height: 16),
                      _buildAwardedLoadsTableCard(),
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

  Widget _buildHeaderToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Awarded Loads',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Track all awarded freight loads',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => controller.showFilterDialog(),
              icon: const Icon(Icons.filter_list, size: 14, color: AppColors.textPrimary),
              label: const Text(
                'Filter',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.inputBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () {
                Get.snackbar('Export', 'Exporting awarded loads', snackPosition: SnackPosition.BOTTOM);
              },
              icon: const Icon(Icons.download, size: 14, color: AppColors.textPrimary),
              label: const Text(
                'Export',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.inputBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryStatsRow() {
    return Row(
      children: controller.summaryStats.map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: stat.themeColor, width: 4.5),
                top: BorderSide(color: stat.themeColor, width: 1.5),
                right: BorderSide(color: stat.themeColor, width: 1.5),
                bottom: BorderSide(color: stat.themeColor, width: 1.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stat.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Icon(stat.icon, size: 26, color: stat.themeColor),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      decoration: const InputDecoration(
                        hintText: 'Search notifications...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.textHint),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => controller.showFilterDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Filter',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardedLoadsTableCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text('REQUEST ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('PROJECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('PICKUP LOCATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('DELIVERY LOCATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('DATES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('CARRIER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('BUDGET & BIDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Table Rows
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.awardedLoadsList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = controller.awardedLoadsList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Request ID & Requested Date & SubStatus pill
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.requestId,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Requested: ${item.requestedDate}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF93C5FD)),
                              ),
                              child: Text(
                                item.subStatus,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Project Name
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.project,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),

                      // Description
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.description,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),

                      // Pickup Location
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.pickupLocation,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),

                      // Delivery Location
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.deliveryLocation,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),

                      // Dates
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pickup: ${item.pickupDate}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text('Delivery: ${item.deliveryDate}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),

                      // Carrier
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.carrierName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 10, color: Color(0xFF2563EB)),
                                const SizedBox(width: 4),
                                Text(
                                  item.carrierPhone,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Budget & Bids
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.budget,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Awarded: ${item.awardedAmount}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${item.bidsCount} bids',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Awarded',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
