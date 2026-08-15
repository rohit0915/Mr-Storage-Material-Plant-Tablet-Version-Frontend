import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../controller/projects_controller.dart';

class ProjectsToolbar extends GetView<ProjectsController> {
  const ProjectsToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left action buttons (Import CSV, Export Data)
          Row(
            children: [
              _buildActionButton(
                icon: Icons.north,
                label: 'Import CSV',
                onTap: controller.importCsv,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.south,
                label: 'Export Data',
                onTap: controller.exportProjectsData,
              ),
            ],
          ),
          // Right filter dropdowns (Matching Web UI: Select Customer, Building types, All Lifecycle Statuses)
          Obx(() {
            return Row(
              children: [
                _buildFilterDropdownMenu(
                  label: controller.selectedCustomerFilter.value,
                  options: controller.customerOptions,
                  onSelected: controller.onSelectCustomerFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterDropdownMenu(
                  label: controller.selectedBuildingTypeFilter.value,
                  options: controller.buildingTypeOptions,
                  onSelected: controller.onSelectBuildingTypeFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterDropdownMenu(
                  label: controller.selectedStatusFilter.value,
                  options: controller.statusOptions,
                  onSelected: controller.onSelectStatusFilter,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdownMenu({
    required String label,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 42),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      onSelected: onSelected,
      itemBuilder: (context) {
        return options.map((option) {
          return PopupMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                fontWeight: label == option ? FontWeight.bold : FontWeight.normal,
                color: label == option ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 14),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
