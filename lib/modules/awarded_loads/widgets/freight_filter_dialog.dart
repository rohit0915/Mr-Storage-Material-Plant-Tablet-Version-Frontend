import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';

class FreightFilterDialog extends StatefulWidget {
  const FreightFilterDialog({super.key});

  @override
  State<FreightFilterDialog> createState() => _FreightFilterDialogState();
}

class _FreightFilterDialogState extends State<FreightFilterDialog> {
  String selectedMonth = 'March 2024';

  String? selectedAllDeliveries;
  String? selectedProject;
  String? selectedDeliveryType;
  String? selectedColorByStatus;
  String? selectedVendor;
  String? selectedCarrier;
  String? selectedSiteLocation;
  String? selectedPriority;
  String? selectedInternalOwner;
  String? selectedStatus;
  String? selectedDelivery;
  String? selectedChannel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 840,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title Header
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Row 1: Month Selector + 4 Dropdowns
            Row(
              children: [
                // Month Selector (< March 2024 >)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Icon(
                          Icons.chevron_left,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedMonth,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {},
                        child: const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'All Deliveries',
                    selectedAllDeliveries,
                    ['All Deliveries', 'Pending', 'In Progress', 'Completed'],
                    (val) => setState(() => selectedAllDeliveries = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Project',
                    selectedProject,
                    [
                      'Storage Facility B',
                      'Industrial Complex A',
                      'Warehouse Complex',
                      'Storage Project C',
                    ],
                    (val) => setState(() => selectedProject = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Delivery Type',
                    selectedDeliveryType,
                    [
                      'Primary Steel',
                      'Roll-up panels',
                      'Fasteners & hardware',
                      'Secondary steel',
                    ],
                    (val) => setState(() => selectedDeliveryType = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Color by Status',
                    selectedColorByStatus,
                    ['By Status', 'By Priority', 'By Carrier'],
                    (val) => setState(() => selectedColorByStatus = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row 2 Dropdowns
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Vendor',
                    selectedVendor,
                    [
                      'Steel Supply Co',
                      'Apex Manufacturing',
                      'National Metals',
                    ],
                    (val) => setState(() => selectedVendor = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Carrier',
                    selectedCarrier,
                    [
                      'QuickFreight Solutions',
                      'National Haulers',
                      'Fast Freight LLC',
                      'RoadKing Logistics',
                    ],
                    (val) => setState(() => selectedCarrier = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Site Location',
                    selectedSiteLocation,
                    [
                      'Austin, TX',
                      'San Antonio, TX',
                      'Houston, TX',
                      'Dallas, TX',
                    ],
                    (val) => setState(() => selectedSiteLocation = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Priority',
                    selectedPriority,
                    ['Critical', 'High', 'Medium', 'Low'],
                    (val) => setState(() => selectedPriority = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Internal Owner',
                    selectedInternalOwner,
                    ['John Johnson', 'Mike Johnson', 'Sarah Miller'],
                    (val) => setState(() => selectedInternalOwner = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row 3 Dropdowns
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Status',
                    selectedStatus,
                    [
                      'Scheduled',
                      'In Transit',
                      'Delivered',
                      'Awarded',
                      'Requested',
                    ],
                    (val) => setState(() => selectedStatus = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Delivery',
                    selectedDelivery,
                    ['Standard Freight', 'Express Freight', 'Heavy Transport'],
                    (val) => setState(() => selectedDelivery = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Channel',
                    selectedChannel,
                    ['Direct', 'Portal', 'Email'],
                    (val) => setState(() => selectedChannel = val),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
            const SizedBox(height: 28),

            // Apply Button
            SizedBox(
              width: 140,
              height: 42,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: AppColors.textSecondary,
          ),
          value: value,
          hint: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          items: options
              .map(
                (opt) => DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    opt,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
