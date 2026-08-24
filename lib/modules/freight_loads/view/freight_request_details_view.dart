import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../binding/freight_loads_binding.dart';
import '../controller/freight_loads_controller.dart';

class FreightRequestDetailsView extends GetView<FreightLoadsController> {
  const FreightRequestDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FreightLoadsController>()) {
      FreightLoadsBinding().dependencies();
    }
    final controller = Get.find<FreightLoadsController>();
    final reqId = Get.parameters['id'] ?? '';
    if (reqId.isNotEmpty && reqId != controller.selectedLoadId.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initDetails(reqId);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isDetailsLoading.value && controller.detailLoadItem.value == null) {
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
                      // Back Button & Header Toolbar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => Get.back(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Freight Request Details',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.selectedLoadItem?.project.isNotEmpty == true &&
                                          controller.selectedLoadItem?.project != '-'
                                      ? controller.selectedLoadItem!.project
                                      : Get.parameters['vendorName'] ??
                                          Get.parameters['project'] ??
                                          '-',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 4 Full Color Metric Header Cards Row
                      _buildMetricHeaderCards(),
                      const SizedBox(height: 24),

                      // Tab Bar (Bid Comparison, Request Details, Email Exchange)
                      _buildTabBar(),
                      const SizedBox(height: 20),

                      // Dynamic Content based on selected tab index
                      Obx(() {
                        if (controller.selectedDetailsTabIndex.value == 0) {
                          return _buildBidComparisonTab();
                        } else if (controller.selectedDetailsTabIndex.value ==
                            1) {
                          return _buildRequestDetailsTab();
                        } else {
                          return _buildEmailExchangeTab();
                        }
                      }),
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

  Widget _buildMetricHeaderCards() {
    return Obx(() {
      final bids = controller.carrierBidsList;
      final bidsCount = '${bids.length}';
      final bestBid = bids.firstWhereOrNull((b) => b.isBestRate) ?? bids.firstOrNull;
      final awardedAmount = bestBid?.bidAmount ?? '-';

      String avgBidStr = '-';
      if (bids.isNotEmpty) {
        double totalAmt = 0;
        int count = 0;
        for (var b in bids) {
          final cleanAmt = b.bidAmount.replaceAll(RegExp(r'[^0-9.]'), '');
          final val = double.tryParse(cleanAmt);
          if (val != null) {
            totalAmt += val;
            count++;
          }
        }
        if (count > 0) {
          avgBidStr = '\$${(totalAmt / count).toStringAsFixed(0)}';
        }
      }

      String savingsStr = r'$0';
      if (bids.length > 1) {
        double maxAmt = 0;
        double minAmt = double.infinity;
        for (var b in bids) {
          final cleanAmt = b.bidAmount.replaceAll(RegExp(r'[^0-9.]'), '');
          final val = double.tryParse(cleanAmt);
          if (val != null) {
            if (val > maxAmt) maxAmt = val;
            if (val < minAmt) minAmt = val;
          }
        }
        if (minAmt < double.infinity && maxAmt > minAmt) {
          savingsStr = '\$${(maxAmt - minAmt).toStringAsFixed(0)}';
        }
      }

      return Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'Total Bids',
              value: bidsCount,
              subtitle: 'From invited carriers',
              bgColor: const Color(0xFF2563EB),
              icon: Icons.local_shipping_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Awarded Bid',
              value: awardedAmount,
              subtitle: 'Best available rate',
              bgColor: const Color(0xFF16A34A),
              icon: Icons.trending_down,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Average Bid',
              value: avgBidStr,
              subtitle: 'Market average',
              bgColor: const Color(0xFFEA580C),
              icon: Icons.bar_chart,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Potential Savings',
              value: savingsStr,
              subtitle: 'vs highest bid',
              bgColor: const Color(0xFF9333EA),
              icon: Icons.bolt,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 16, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Obx(() {
      final count = controller.carrierBidsList.isEmpty ? 1 : controller.carrierBidsList.length;
      final tabs = ['Bid Comparison ($count)', 'Request Details'];
      final selectedIdx = controller.selectedDetailsTabIndex.value;
      return Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = selectedIdx == index;
            return InkWell(
              onTap: () => controller.selectedDetailsTabIndex.value = index,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildRequestDetailsTab() {
    return Obx(() {
      final item = controller.selectedLoadItem;
      final desc = (item?.description.isNotEmpty ?? false) ? item!.description : '-';
      final weight = (item?.loadWeight.isNotEmpty ?? false) ? item!.loadWeight : '-';
      final dimensions = (item?.dimensions.isNotEmpty ?? false) ? item!.dimensions : '-';
      final distance = (item?.distance.isNotEmpty ?? false) ? item!.distance : '-';
      final materialType = (item?.materialType.isNotEmpty ?? false) ? item!.materialType : '-';
      final equipment = (item?.equipment.isNotEmpty ?? false) ? item!.equipment : '-';
      final routeFrom = (item?.routeFrom.isNotEmpty ?? false) ? item!.routeFrom : '-';
      final routeTo = (item?.routeTo.isNotEmpty ?? false) ? item!.routeTo : '-';
      final status = (item?.status.isNotEmpty ?? false) ? item!.status : '-';
      final pickupDateStr = (item?.pickupDate.isNotEmpty ?? false) ? item!.pickupDate : '-';
      final deliveryDateStr = (item?.deliveryDate.isNotEmpty ?? false) ? item!.deliveryDate : '-';
      final pocNameStr = (item?.receivingPocName.isNotEmpty ?? false) && item!.receivingPocName != '-' ? item.receivingPocName : '';
      final pocPhoneStr = (item?.receivingPocPhone.isNotEmpty ?? false) && item!.receivingPocPhone != '-' ? item.receivingPocPhone : '';
      final pocDisplay = pocNameStr.isEmpty && pocPhoneStr.isEmpty
          ? '-'
          : pocNameStr.isNotEmpty && pocPhoneStr.isNotEmpty
              ? '$pocNameStr ($pocPhoneStr)'
              : pocNameStr.isNotEmpty
                  ? pocNameStr
                  : pocPhoneStr;
      final specialRequirements = (item?.specialRequirements.isNotEmpty ?? false) ? item!.specialRequirements : '-';
      final additionalNotes = (item?.additionalNotes.isNotEmpty ?? false) ? item!.additionalNotes : '-';

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Load Details + Coordination & Requirements)
          Expanded(
            flex: 6,
            child: Column(
              children: [
                // Card 1: Load Details
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 22,
                            color: Color(0xFFF97316),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Load Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'WEIGHT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  weight,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DIMENSIONS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dimensions,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DISTANCE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  distance,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MATERIAL TYPE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  materialType,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'EQUIPMENT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  equipment,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'STATUS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  status,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 2: Coordination & Requirements
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 22,
                            color: Color(0xFF16A34A),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Coordination & Requirements',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'RECEIVING POC',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          children: [
                            TextSpan(
                              text: pocDisplay,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SPECIAL REQUIREMENTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEFCE8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFEF08A)),
                        ),
                        child: Text(
                          specialRequirements,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF854D0E)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ADDITIONAL NOTES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Text(
                          additionalNotes,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Right Column (Route Information)
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        size: 22,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Route Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Timeline Axis Track (Node 1 -> Line -> Node 2)
                        Column(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF16A34A), width: 3),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFEF4444), width: 3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Right Content Column (Pickup + Delivery)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pickup Section
                              const Text(
                                'PICKUP LOCATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Color(0xFF16A34A)),
                                  const SizedBox(width: 4),
                                  Text(
                                    routeFrom,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 13, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    pickupDateStr,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28), // Gap between Pickup and Delivery

                              // Delivery Section
                              const Text(
                                'DELIVERY LOCATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Color(0xFFEF4444)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      routeTo,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 13, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    deliveryDateStr,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBidComparisonTab() {
    return Obx(() {
      final bids = controller.carrierBidsList;
      final hasBids = bids.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Filter & Sort Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'All Bids',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.tune, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 6),
                        Text(
                          'Sort: ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Low to High',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: r'$40,000', style: TextStyle(color: Color(0xFF16A34A))),
                    TextSpan(text: r'  -  ', style: TextStyle(color: AppColors.textSecondary)),
                    TextSpan(text: r'$40,000', style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (hasBids)
            Column(
              children: List.generate(bids.length, (index) {
                final bid = bids[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildBidCard(
                    rank: '#${index + 1}',
                    isRankOne: index == 0,
                    carrierName: bid.carrierName,
                    rating: bid.rating > 0 ? '${bid.rating}' : '',
                    onTimeDelivery: '',
                    submittedDate: 'Submitted On: 19/08/2026',
                    transitTime: bid.deliveryDays,
                    bidAmount: bid.bidAmount,
                    bidSubtitle: index == 0 ? 'LOWEST BID' : '',
                    notes: '—',
                    isAwarded: true,
                  ),
                );
              }),
            )
          else
            _buildBidCard(
              rank: '#1',
              isRankOne: true,
              carrierName: 'Ayesha LLC',
              rating: '',
              onTimeDelivery: '',
              submittedDate: 'Submitted On: 19/08/2026',
              transitTime: '',
              bidAmount: r'$40,000',
              bidSubtitle: 'LOWEST BID',
              notes: '—',
              isAwarded: true,
            ),
        ],
      );
    });
  }

  Widget _buildBidCard({
    required String rank,
    required bool isRankOne,
    required String carrierName,
    required String rating,
    required String onTimeDelivery,
    required String submittedDate,
    required String transitTime,
    required String bidAmount,
    required String bidSubtitle,
    required String notes,
    bool isAwarded = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isRankOne ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRankOne ? const Color(0xFF86EFAC) : AppColors.inputBorder,
          width: isRankOne ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank Badge
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isRankOne
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  rank,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isRankOne ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Carrier Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carrierName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (rating.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        if (onTimeDelivery.isNotEmpty)
                          Text(
                            '• $onTimeDelivery',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (submittedDate.isNotEmpty)
                          Text(
                            submittedDate,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (transitTime.isNotEmpty)
                          Text(
                            '• $transitTime',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bid Amount Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'BID AMOUNT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bidAmount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isRankOne
                          ? const Color(0xFF16A34A)
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (bidSubtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      bidSubtitle,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isRankOne
                            ? const Color(0xFF166534)
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Carrier Notes Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isRankOne ? Colors.white : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isRankOne
                    ? const Color(0xFFDCFCE7)
                    : AppColors.inputBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Carrier Notes:',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notes,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          if (isAwarded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color:   AppColors. white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.label_outlined, size: 14, color: Color(0xFF16A34A)),
                  SizedBox(width: 6),
                  Text(
                    'Awarded Load',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.showAwardLoadDialog(),
                  icon: const Icon(
                    Icons.workspace_premium,
                    size: 14,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Award Load',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => controller.showRequestRevisionDialog(),
                  icon: const Icon(
                    Icons.autorenew,
                    size: 14,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Request Revision',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Decline',
                      'Bid declined',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 14,
                    color: Color(0xFFEF4444),
                  ),
                  label: const Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmailExchangeTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: const [
          Icon(Icons.mail_outline, size: 48, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'No Email Exchanges Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Email communications with carriers regarding this request will appear here.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
