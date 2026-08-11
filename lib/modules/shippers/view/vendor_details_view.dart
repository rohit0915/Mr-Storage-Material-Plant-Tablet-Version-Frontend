import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/shippers_controller.dart';

class VendorDetailsView extends GetView<ShippersController> {
  const VendorDetailsView({super.key});

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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Navigation Bar
                      _buildHeaderToolbar(),

                      const SizedBox(height: 16),

                      // Main 2-Column Content Layout (Left Main Details + Right Sidebar Cards)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Main Content (Vendor Card + Purchase History + Compliance)
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                // Top Vendor Details Header Card
                                _buildVendorHeaderCard(),

                                const SizedBox(height: 20),

                                // Order / Purchase History Box
                                _buildOrderHistoryCard(),

                                const SizedBox(height: 20),

                                // Compliance & Certifications Card
                                _buildComplianceCard(),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Right Sidebar Column (Notes + Vendor Contact Roles)
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildNotesCard(),
                                const SizedBox(height: 20),
                                _buildContactRolesCard(),
                              ],
                            ),
                          ),
                        ],
                      ),

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
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1E293B)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        const Text(
          'Vendors',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorHeaderCard() {
    final v = controller.vendorDetails.value;
    final shipper = controller.selectedShipper.value;
    final companyName = shipper?.name ?? v.companyName;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Code, Rating, Name, Active badge & Edit Profile button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        v.vendorCode,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 14, color: Color(0xFFEAB308)),
                      const SizedBox(width: 4),
                      Text(
                        '${v.rating} / 5',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle, size: 12, color: Color(0xFF16A34A)),
                            SizedBox(width: 4),
                            Text(
                              'Active',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => controller.openEditShipper(),
                icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF334155)),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(v.address, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Email & Phone Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email Address', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          Text(v.email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Phone', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          Text(v.phone, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Row 3: Vendor Type, Service Category, Years Working
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• Vendor Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 2),
                      Text(v.vendorType, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• Service Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 2),
                      Text(v.serviceCategory, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• Years Working With Company', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 2),
                      Text(v.yearsWorking, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Row 4: Stats Grid (Total Orders, Completed, Active, Avg Delivery Time, On-time Rate)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCell('Total Orders', '${v.totalOrders}'),
                _buildStatCell('Completed Deliveries', '${v.completedDeliveries}'),
                _buildStatCell('Active Orders', '${v.activeOrders}'),
                _buildStatCell('Average Delivery Time', v.avgDeliveryTime),
                _buildStatCell('On-time Delivery Rate', v.onTimeRate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildOrderHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Order / Purchase History',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                _buildTh('Order ID', flex: 2),
                _buildTh('Material', flex: 2, sortable: true),
                _buildTh('Quantity', flex: 2, sortable: true),
                _buildTh('Order Value', flex: 2, sortable: true),
                _buildTh('Status', flex: 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Rows
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.orderHistory.length,
              separatorBuilder: (ctx, idx) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (ctx, index) {
                final item = controller.orderHistory[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.orderId,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.orderId == 'ORD00019' ? const Color(0xFF2563EB) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      _buildTd(item.material, flex: 2, isBold: true),
                      _buildTd(item.quantity, flex: 2),
                      _buildTd(item.orderValue, flex: 2),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.status == 'Delivered' ? const Color(0xFFDCFCE7) : const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.status == 'Delivered' ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Footer Pagination
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Showing  ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: 10,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B)),
                      onChanged: (v) {},
                      items: const [DropdownMenuItem(value: 10, child: Text('10'))],
                    ),
                  ),
                ),
                const Text('  Results', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const Spacer(),
                Row(
                  children: [
                    _buildPageNum('<', isArrow: true),
                    _buildPageNum('1', isSelected: true),
                    _buildPageNum('2'),
                    _buildPageNum('3'),
                    const Text(' ... ', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    _buildPageNum('8'),
                    _buildPageNum('>', isArrow: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Compliance & Certifications',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      controller.isComplianceExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                      color: const Color(0xFF64748B),
                    ),
                    onPressed: () => controller.isComplianceExpanded.toggle(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),

          Obx(() {
            if (!controller.isComplianceExpanded.value) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Toolbar: Count + Sort + Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      const Text(
                        'Total No of Documents : 4',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const Spacer(),
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'Docs Type',
                            icon: const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B)),
                            onChanged: (v) {},
                            items: const [DropdownMenuItem(value: 'Docs Type', child: Text('Sort By : Docs Type'))],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 160,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const TextField(
                          style: TextStyle(fontSize: 11),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.search, size: 14, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Document Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  color: const Color(0xFFF8FAFC),
                  child: Row(
                    children: [
                      _buildTh('Name', flex: 3, sortable: true),
                      _buildTh('Size', flex: 2),
                      _buildTh('Type', flex: 2),
                      _buildTh('Expiry Date', flex: 2),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Document Rows
                ...List.generate(controller.certificates.length, (idx) {
                  final cert = controller.certificates[idx];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('PDF', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(cert.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                ],
                              ),
                            ),
                            _buildTd(cert.size, flex: 2, color: const Color(0xFF64748B)),
                            _buildTd(cert.type, flex: 2, color: const Color(0xFF64748B)),
                            _buildTd(cert.expiryDate, flex: 2, isBold: true, color: const Color(0xFF334155)),
                          ],
                        ),
                      ),
                      if (idx < controller.certificates.length - 1)
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ],
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          SizedBox(height: 12),
          Text(
            "Keep in mind that in order to be deductible, your employees' pay must be reasonable and necessary for conducting business to qualify for",
            style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRolesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vendor Contact Roles', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),
          ...List.generate(controller.contactRoles.length, (idx) {
            final r = controller.contactRoles[idx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.roleName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text(r.name, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Text(r.phone, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPageNum(String text, {bool isSelected = false, bool isArrow = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF9333EA) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildTh(String title, {int flex = 1, bool sortable = false}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          if (sortable) ...[
            const SizedBox(width: 3),
            const Icon(Icons.swap_vert, size: 12, color: Color(0xFF94A3B8)),
          ],
        ],
      ),
    );
  }

  Widget _buildTd(String text, {int flex = 1, bool isBold = false, Color color = const Color(0xFF334155)}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}
