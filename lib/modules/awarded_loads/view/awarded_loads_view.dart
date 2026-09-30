import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../../app/widgets/common_loader.dart';
import '../../freight_loads/model/freight_loads_model.dart';
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            const AppBackButton(),
            const SizedBox(width: 16),
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
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        if (isWide) {
          return Row(
            children: controller.summaryStats.map((stat) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _buildSummaryStatCard(stat),
                ),
              );
            }).toList(),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: controller.summaryStats.map((stat) {
              return SizedBox(
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildSummaryStatCard(stat),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStatCard(FreightLoadSummaryStatModel stat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: stat.themeColor, width: 4.5),
          top: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          right: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          bottom: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.label,
            style: const TextStyle(
              fontSize: 12,
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
              Flexible(
                child: Text(
                  stat.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(stat.icon, size: 26, color: stat.themeColor),
            ],
          ),
        ],
      ),
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
                  const Icon(
                    Icons.search,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      decoration: const InputDecoration(
                        hintText: 'Search awarded loads...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
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
              backgroundColor: const Color(0xFF2563EB),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Filter',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardedLoadsTableCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth =
            constraints.maxWidth < 1450 ? 1450 : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: tableWidth,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        _buildTh('REQUEST ID', flex: 3),
                        _buildTh('PROJECT', flex: 3),
                        _buildTh('DESCRIPTION', flex: 4),
                        _buildTh('PICKUP LOCATION', flex: 3),
                        _buildTh('DELIVERY LOCATION', flex: 3),
                        _buildTh('DATES', flex: 3),
                        _buildTh('CARRIER', flex: 3),
                        _buildTh('BUDGET & BIDS', flex: 3),
                        _buildTh('STATUS', flex: 2),
                        _buildTh('ACTIONS', flex: 2),
                        _buildTh('LOAD SIZE / WEIGHT', flex: 3),
                        _buildTh('INTERNAL OWNER', flex: 3, isLast: true),
                      ],
                    ),
                  ),

                  // Table Rows
                  Obx(() {
                    final items = controller.filteredAwardedLoads;
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'No awarded loads found.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return IntrinsicHeight(
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFF1F5F9)),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. Request ID & Requested Date & SubStatus pill
                                _buildTd(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.requestId,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Requested: ${item.requestedDate}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                      if (item.subStatus.isNotEmpty &&
                                          item.subStatus != '-') ...[
                                        const SizedBox(height: 4),
                                        _buildSubStatusBadge(item.subStatus),
                                      ],
                                    ],
                                  ),
                                  flex: 3,
                                ),

                                // 2. Project Name
                                _buildTd(
                                  Text(
                                    item.project,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  flex: 3,
                                ),

                                // 3. Description
                                _buildTd(
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  flex: 4,
                                ),

                                // 4. Pickup Location
                                _buildTd(
                                  Text(
                                    item.pickupLocation,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  flex: 3,
                                ),

                                // 5. Delivery Location
                                _buildTd(
                                  Text(
                                    item.deliveryLocation,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  flex: 3,
                                ),

                                // 6. Dates
                                _buildTd(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Pickup: ${item.pickupDate}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Delivery: ${item.deliveryDate}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  flex: 3,
                                ),

                                // 7. Carrier
                                _buildTd(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.carrierName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (item.carrierPhone.isNotEmpty &&
                                          item.carrierPhone != '-') ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              size: 11,
                                              color: Color(0xFF2563EB),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                item.carrierPhone,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF2563EB),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                  flex: 3,
                                ),

                                // 8. Budget & Bids
                                _buildTd(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.budget,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Awarded: ${item.awardedAmount}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  flex: 3,
                                ),

                                // 9. Status
                                _buildTd(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildStatusBadge(item.status),
                                  ),
                                  flex: 2,
                                ),

                                // 10. Actions
                                _buildTd(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: OutlinedButton.icon(
                                      onPressed: () => controller
                                          .openFreightRequestDetails(item),
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                      label: const Text(
                                        'View',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF0F172A),
                                        side: const BorderSide(
                                          color: Color(0xFFCBD5E1),
                                        ),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ),
                                  flex: 2,
                                ),

                                // 11. Load Size / Weight
                                _buildTd(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.loadWeight,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (item.packageCount.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item.packageCount,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  flex: 3,
                                ),

                                // 12. Internal Owner
                                _buildTd(
                                  Text(
                                    item.internalOwner,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  flex: 3,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  // Pagination Footer
                  Obx(() {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Showing ${controller.totalResults.value == 0 ? 0 : (controller.currentPage.value - 1) * AwardedLoadsController.pageSize + 1} to '
                            '${(controller.currentPage.value * AwardedLoadsController.pageSize).clamp(0, controller.totalResults.value)} of '
                            '${controller.totalResults.value} results',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: controller.hasPreviousPage
                                ? controller.previousPage
                                : null,
                            child: const Text('Previous'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: controller.hasNextPage
                                ? controller.nextPage
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubStatusBadge(String status) {
    final lower = status.toLowerCase();
    Color bgColor = const Color(0xFFF1F5F9);
    Color borderColor = const Color(0xFFCBD5E1);
    Color textColor = const Color(0xFF475569);

    if (lower.contains('deliver')) {
      bgColor = const Color(0xFFDCFCE7);
      borderColor = const Color(0xFF86EFAC);
      textColor = const Color(0xFF166534);
    } else if (lower.contains('load') || lower.contains('transit')) {
      bgColor = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFF93C5FD);
      textColor = const Color(0xFF2563EB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('deliver')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Delivered',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF166534),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.check_circle_outline,
              size: 12,
              color: Color(0xFF166534),
            ),
          ],
        ),
      );
    }

    if (lower.contains('load')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF93C5FD)),
        ),
        child: const Text(
          'Loaded',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
      );
    }

    if (lower.contains('transit')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDBA74)),
        ),
        child: const Text(
          'In Transit',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEA580C),
          ),
        ),
      );
    }

    // Default 'Confirmed' or other
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        status.isNotEmpty ? status : 'Confirmed',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildTh(String label, {int flex = 2, double? width, bool isLast = false}) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          right: isLast ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }

  Widget _buildTd(Widget child, {int flex = 2, double? width, bool isLast = false}) {
    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: isLast ? BorderSide.none : const BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (width != null) return SizedBox(width: width, child: container);
    return Expanded(flex: flex, child: container);
  }
}
