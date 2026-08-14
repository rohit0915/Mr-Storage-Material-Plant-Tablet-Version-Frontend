import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/shippers_controller.dart';

class ShippersListView extends GetView<ShippersController> {
  const ShippersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
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
                      // Header title & subtitle
                      const Text(
                        'Logistics',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Manage Shipper companies and material vendors',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Filter & Action Toolbar Box
                      _buildSearchAndActionBox(context),

                      const SizedBox(height: 20),

                      // Shippers Data Table
                      _buildShippersTable(),

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                onChanged: (val) => controller.filterSearchResults(val),
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Search by vendor, contact, email, or material...',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Filter button
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
                color: const Color(0xFF94A3B8),
                borderRadius: BorderRadius.circular(8),
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
          ),
          const SizedBox(width: 12),

          // + Add Shipper button
          ElevatedButton.icon(
            onPressed: () => controller.openAddShipper(),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              'Add Shipper',
              style: TextStyle(
                fontSize: 13,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippersTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: const Color(0xFFF1F5F9),
            child: Row(
              children: [
                _buildTh('SHIPPERS', flex: 3),
                _buildTh('CONTACT', flex: 2),
                _buildTh('EMAIL', flex: 3),
                _buildTh('PHONE', flex: 2),
                _buildTh('MATERIAL TYPES', flex: 3),
                _buildTh('ORDERS', flex: 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Rows
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredShippers.length,
              separatorBuilder: (ctx, idx) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (ctx, index) {
                final shipper = controller.filteredShippers[index];
                return InkWell(
                  onTap: () => controller.openVendorDetails(shipper),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // Shippers column (Icon + Name + Code)
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDBEAFE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.storefront_outlined,
                                  color: Color(0xFF2563EB),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shipper.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      shipper.vendorCode,
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

                        // Contact column
                        _buildTd(shipper.contactName, flex: 2, isBold: true),

                        // Email column
                        Expanded(
                          flex: 3,
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
                                  shipper.email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2563EB),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Phone column
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                shipper.phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Material Types column (purple pill badges)
                        Expanded(
                          flex: 3,
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: shipper.materialTypes.map((type) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  type,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9333EA),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Orders column
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${shipper.activeOrders} ',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'active',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${shipper.totalOrders} total',
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTh(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTd(String text, {int flex = 1, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }
}
