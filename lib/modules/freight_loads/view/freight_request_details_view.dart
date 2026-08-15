import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/freight_loads_controller.dart';

class FreightRequestDetailsView extends GetView<FreightLoadsController> {
  const FreightRequestDetailsView({super.key});

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
                                Obx(
                                  () => Text(
                                    '${controller.selectedLoadId.value} • Primary Steel Frame - 45,000 lbs • Status: Bidding Open',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: controller.exportCarrierBids,
                                icon: const Icon(
                                  Icons.download,
                                  size: 14,
                                  color: AppColors.textPrimary,
                                ),
                                label: const Text(
                                  'Export',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: AppColors.inputBorder,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Edit Request',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
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
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Bids',
            value: '5',
            subtitle: 'From 5 verified carriers',
            bgColor: const Color(0xFF2563EB), // Solid Blue
            icon: Icons.attach_money,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Lowest Bid',
            value: r'$2,850',
            subtitle: 'Best available rate',
            bgColor: const Color(0xFF10B981), // Solid Green
            icon: Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Average Bid',
            value: r'$3,120',
            subtitle: 'Market average',
            bgColor: const Color(0xFFEA580C), // Solid Orange
            icon: Icons.attach_money,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Potential Savings',
            value: r'$600',
            subtitle: 'vs highest bid',
            bgColor: const Color(0xFFA855F7), // Solid Purple
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
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
    final tabs = ['Bid Comparison (5)', 'Request Details', 'Email Exchange'];

    return Obx(() {
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
    return Column(
      children: [
        // Row 1: Load Details & Route Information
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Load Details
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
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
                          size: 20,
                          color: Color(0xFFEA580C),
                        ),
                        SizedBox(width: 8),
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
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Primary Steel Frame - 45,000 lbs',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Weight',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '45,000 lbs',
                                style: TextStyle(
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
                            children: const [
                              Text(
                                'Dimensions',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "40' x 8' x 8'",
                                style: TextStyle(
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
                            children: const [
                              Text(
                                'Distance',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '280 miles',
                                style: TextStyle(
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Material Type',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Steel Beams',
                                style: TextStyle(
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
                            children: const [
                              Text(
                                'Equipment',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Flatbed',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Card 2: Route Information
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
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
                          size: 20,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 8),
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
                    const SizedBox(height: 20),
                    const Text(
                      'Pickup Location',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.room, size: 16, color: Color(0xFF16A34A)),
                        SizedBox(width: 6),
                        Text(
                          'Steel Mill, Pittsburgh, PA',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 22, top: 2),
                      child: Text(
                        '4/1/2026 at 09:00',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 16),
                    const Text(
                      'Delivery Location',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.room, size: 16, color: Color(0xFFDC2626)),
                        SizedBox(width: 6),
                        Text(
                          'Construction Site, Austin, TX',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 22, top: 2),
                      child: Text(
                        '4/5/2026 at 14:00',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Row 2: Coordination & Requirements
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
                    size: 20,
                    color: Color(0xFF16A34A),
                  ),
                  SizedBox(width: 8),
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
              const SizedBox(height: 20),
              const Text(
                'Receiving POC',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              const Text(
                'John Site Manager',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Special Requirements',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                child: const Text(
                  'Crane unloading required',
                  style: TextStyle(fontSize: 12, color: Color(0xFF854D0E)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Additional Notes',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                child: const Text(
                  'Contact site supervisor 30 minutes before arrival',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBidComparisonTab() {
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Row(
                    children: const [
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
            const Text(
              r'$2,850 - $3,450',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bid Card #1 (Awarded)
        _buildBidCard(
          rank: '#1',
          isRankOne: true,
          carrierName: 'QuickFreight Solutions',
          rating: '4.8',
          onTimeDelivery: 'On-time delivery 89%',
          submittedDate: 'Submitted 3/20/2026',
          transitTime: 'Transit time: 1 day',
          bidAmount: r'$2,850',
          bidSubtitle: 'LOWEST BID',
          notes: 'Best rate available, experienced with steel transport',
          isAwarded: true,
        ),
        const SizedBox(height: 12),

        // Bid Card #2
        _buildBidCard(
          rank: '#2',
          isRankOne: false,
          carrierName: 'National Haulers Inc.',
          rating: '4.5',
          onTimeDelivery: 'On-time delivery 89%',
          submittedDate: 'Submitted 3/20/2026',
          transitTime: 'Transit time: 1 day',
          bidAmount: r'$2,950',
          bidSubtitle: r'+$100 more',
          notes: 'Includes insurance coverage',
        ),
        const SizedBox(height: 12),

        // Bid Card #3
        _buildBidCard(
          rank: '#3',
          isRankOne: false,
          carrierName: 'Regional Transport Co.',
          rating: '4.2',
          onTimeDelivery: 'On-time delivery 89%',
          submittedDate: 'Submitted 3/21/2026',
          transitTime: 'Transit time: 1 day',
          bidAmount: r'$3,100',
          bidSubtitle: r'+$250 more',
          notes: 'Guaranteed delivery window',
        ),
        const SizedBox(height: 12),

        // Bid Card #4
        _buildBidCard(
          rank: '#4',
          isRankOne: false,
          carrierName: 'FastFreight Logistics',
          rating: '4.9',
          onTimeDelivery: 'On-time delivery 89%',
          submittedDate: 'Submitted 3/21/2026',
          transitTime: 'Transit time: 1 day',
          bidAmount: r'$3,250',
          bidSubtitle: r'+$400 more',
          notes: 'Premium service with tracking',
        ),
        const SizedBox(height: 12),

        // Bid Card #5
        _buildBidCard(
          rank: '#5',
          isRankOne: false,
          carrierName: 'Budget Carriers LLC',
          rating: '3.9',
          onTimeDelivery: 'On-time delivery 89%',
          submittedDate: 'Submitted 3/22/2026',
          transitTime: 'Transit time: 1 day',
          bidAmount: r'$3,450',
          bidSubtitle: r'+$600 more',
          notes: 'Standard service',
        ),
      ],
    );
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
                        Text(
                          '• $onTimeDelivery',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '• $submittedDate',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
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
                    'Bid Amount',
                    style: TextStyle(
                      fontSize: 10,
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
