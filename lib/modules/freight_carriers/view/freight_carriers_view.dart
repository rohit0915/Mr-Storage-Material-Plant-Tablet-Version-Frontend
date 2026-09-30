import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/app_back_button.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/freight_carriers_controller.dart';
import '../model/freight_carrier_master_model.dart';

class FreightCarriersView extends GetView<FreightCarriersController> {
  const FreightCarriersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
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
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Title & Subtitle
                      Row(
                        children: [
                          const AppBackButton(),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Carrier Master',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Manage freight haulers and carriers for bidding',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Filter & Action Toolbar Box
                      _buildSearchAndActionBox(context),

                      const SizedBox(height: 24),

                      // Carriers Data Table with Horizontal Scroll
                      _buildCarriersTable(context),

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

  Widget _buildSearchAndActionBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search TextField
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => controller.filterCarriers(val),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        hintText:
                            'Search by carrier name, contact, email, or phone...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Filter Button
          PopupMenuButton<String>(
            onSelected: controller.setStatusFilter,
            itemBuilder: (_) => const [
              PopupMenuItem(value: '', child: Text('All statuses')),
              PopupMenuItem(value: 'active', child: Text('Active')),
              PopupMenuItem(value: 'inactive', child: Text('Inactive')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF71717A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Filter',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // + Add Carrier Button
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.addFreightCarrier),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Add Carrier',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarriersTable(BuildContext context) {
    final scrollController = ScrollController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1700,
            child: Column(
              children: [
                // Header Row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F2FE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 210,
                        child: Text(
                          'CARRIER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: Text(
                          'CONTACT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: Text(
                          'EMAIL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: Text(
                          'PHONE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          'BIDS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          'AWARDED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          'AVG BID',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          'STATUS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: Text(
                          'SERVICE TYPE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          'SERVICE AREA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: Text(
                          'EQUIPMENT TYPE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          'ACTIONS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Data Rows
                Obx(() {
                  if (controller.filteredCarriers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No carriers found',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(
                      controller.filteredCarriers.length,
                      (index) {
                        final carrier = controller.filteredCarriers[index];
                        final isLast =
                            index == controller.filteredCarriers.length - 1;

                        return Column(
                          children: [
                            _buildCarrierRow(context, carrier),
                            if (!isLast)
                              const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarrierRow(BuildContext context, FreightCarrierMasterModel carrier) {
    final bool isActive = carrier.status.toLowerCase() == 'active';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Carrier Icon + Name + ID
          SizedBox(
            width: 210,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.directions_bus_outlined,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carrier.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        carrier.carrierId,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contact
          SizedBox(
            width: 140,
            child: Text(
              carrier.contact,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Email
          SizedBox(
            width: 220,
            child: Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 14,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    carrier.email,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2563EB),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Phone
          SizedBox(
            width: 140,
            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    carrier.phone,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2563EB),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Bids
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    children: [
                      TextSpan(
                        text: '${carrier.activeBids} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: 'active',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${carrier.totalBids} total',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Awarded
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${carrier.awardedCount}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  carrier.winRate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // AVG BID
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    children: [
                      TextSpan(
                        text: '${carrier.avgBid} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: 'average',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '• ${carrier.respondsTime}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // STATUS
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  carrier.status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
          ),

          // SERVICE TYPE
          SizedBox(
            width: 140,
            child: Text(
              carrier.serviceType,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // SERVICE AREA
          SizedBox(
            width: 120,
            child: Text(
              carrier.serviceArea,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // EQUIPMENT TYPE
          SizedBox(
            width: 130,
            child: Text(
              carrier.equipmentType,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ACTIONS (View and Edit only - Delete removed as requested)
          SizedBox(
            width: 70,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.carrierDetails, parameters: {'id': carrier.id});
                  },
                  child: const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    controller.selectedCarrier.value = carrier;
                    Get.toNamed(AppRoutes.editFreightCarrier);
                  },
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Carrier Details Modal with Interactive Service Area Map
  void _showCarrierDetailDialog(BuildContext context, FreightCarrierMasterModel carrier) {
    final bool isActive = carrier.status.toLowerCase() == 'active';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 760,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header: Carrier Name, Code, Status Pill & Close Button
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.directions_bus_outlined,
                        color: Color(0xFF2563EB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            carrier.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Carrier Code: ${carrier.carrierId.isNotEmpty ? carrier.carrierId : 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        carrier.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 20),

                // Contact & Logistics Specs Grid
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCell(
                              icon: Icons.person_outline,
                              label: 'Contact Name',
                              value: carrier.contact.isNotEmpty ? carrier.contact : 'N/A',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailCell(
                              icon: Icons.email_outlined,
                              label: 'Email Address',
                              value: carrier.email.isNotEmpty ? carrier.email : 'N/A',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailCell(
                              icon: Icons.phone_outlined,
                              label: 'Phone Number',
                              value: carrier.phone.isNotEmpty ? carrier.phone : 'N/A',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCell(
                              icon: Icons.local_shipping_outlined,
                              label: 'Service Type',
                              value: carrier.serviceType.isNotEmpty ? carrier.serviceType : 'N/A',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailCell(
                              icon: Icons.place_outlined,
                              label: 'Service Area',
                              value: carrier.serviceArea.isNotEmpty ? carrier.serviceArea : 'N/A',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailCell(
                              icon: Icons.build_circle_outlined,
                              label: 'Equipment Types',
                              value: carrier.equipmentType.isNotEmpty ? carrier.equipmentType : 'N/A',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Key Performance Metrics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Active Bids',
                        value: '${carrier.activeBids}',
                        subtitle: '${carrier.totalBids} Total Bids',
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Awarded Bids',
                        value: '${carrier.awardedCount}',
                        subtitle: carrier.winRate,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Average Bid',
                        value: carrier.avgBid,
                        subtitle: carrier.respondsTime.isNotEmpty ? carrier.respondsTime : '—',
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(carrier.serviceArea.isEmpty ? 'No service area provided.' : 'Service area: ${carrier.serviceArea}'),
                const SizedBox(height: 24),

                // Modal Bottom Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.selectedCarrier.value = carrier;
                        Get.toNamed(AppRoutes.editFreightCarrier);
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Carrier Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildDetailCell({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
