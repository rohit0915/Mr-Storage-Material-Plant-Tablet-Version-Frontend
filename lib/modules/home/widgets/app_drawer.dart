import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_icons.dart';
import '../controller/home_controller.dart';
import '../repository/home_repository.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  HomeController get _controller {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>();
    }
    final repo = Get.isRegistered<HomeRepository>()
        ? Get.find<HomeRepository>()
        : HomeRepository(apiClient: Get.find<ApiClient>());
    return Get.put(HomeController(repository: repo));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: Colors.transparent,
      elevation: 16,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E40AF),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.precision_manufacturing_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'STEEL BUILDING',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'DEPOT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 12.0,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Obx(() {
                    final activeItem = _controller.selectedDrawerItem.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNavItem(
                          'Dashboard',
                          AppIcons.dashboard,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem('Projects', AppIcons.project, activeItem),
                        const SizedBox(height: 16),
                        _buildSectionHeader('Load Planning'),
                        const SizedBox(height: 8),
                        _buildNavItem(
                          'Uploaded BOM Files',
                          AppIcons.uploadBomFiles,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'Shipper Quotations',
                          AppIcons.shipperQuotations,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'Load Planning',
                          AppIcons.loadPlanning,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'Packing List',
                          AppIcons.packingList,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'QR Labels',
                          AppIcons.qeLabels,
                          activeItem,
                        ),
                        const SizedBox(height: 16),
                        _buildSectionHeader('Delivery'),
                        const SizedBox(height: 8),
                        _buildNavItem(
                          'Freight Loads',
                          AppIcons.freightLoads,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'Awarded Loads',
                          AppIcons.awardedLoads,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'Deliveries Calendar',
                          AppIcons.deliveriesCalendar,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'All Deliveries',
                          AppIcons.allDeliveries,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'Notification Details',
                          AppIcons.notificationDetails,
                          activeItem,
                        ),
                        const SizedBox(height: 16),
                        _buildSectionHeader('Costings'),
                        const SizedBox(height: 8),
                        _buildNavItem(
                          'Costings',
                          AppIcons.costings,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem('Savings', AppIcons.savings, activeItem),
                        const SizedBox(height: 16),
                        _buildSectionHeader('Logistics'),
                        const SizedBox(height: 8),
                        _buildNavItem(
                          'Shippers',
                          AppIcons.shippers,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'Freight Carriers',
                          AppIcons.freightCarriers,
                          activeItem,
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 12),
                        _buildNavItem(
                          'Communication',
                          AppIcons.communication,
                          activeItem,
                        ),
                        const SizedBox(height: 6),
                        _buildNavItem(
                          'Notifications',
                          AppIcons.notification,
                          activeItem,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, String iconAsset, String activeItem) {
    final isSelected = activeItem == title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _controller.selectedDrawerItem.value = title;
          Get.back();
          if (title == 'Dashboard' && Get.currentRoute != AppRoutes.home) {
            Get.offAllNamed(AppRoutes.home);
          } else if (title == 'Projects' &&
              Get.currentRoute != AppRoutes.projects) {
            Get.offAllNamed(AppRoutes.projects);
          } else if (title == 'All Deliveries' &&
              Get.currentRoute != AppRoutes.allDeliveries) {
            Get.toNamed(AppRoutes.allDeliveries);
          } else if ((title == 'Deliveries Calendar' ||
                  title == 'Delivery Calendar') &&
              Get.currentRoute != AppRoutes.deliveryCalendar) {
            Get.toNamed(AppRoutes.deliveryCalendar);
          } else if (title == 'Shipper Quotations' &&
              Get.currentRoute != AppRoutes.shipperFiles) {
            Get.toNamed(AppRoutes.shipperFiles);
          } else if (title == 'Shippers' &&
              Get.currentRoute != AppRoutes.shippersList) {
            Get.toNamed(AppRoutes.shippersList);
          } else if (title == 'Uploaded BOM Files' &&
              Get.currentRoute != AppRoutes.uploadedBomFiles) {
            Get.toNamed(AppRoutes.uploadedBomFiles);
          } else if (title == 'Load Planning' &&
              Get.currentRoute != AppRoutes.loadPlanning) {
            Get.toNamed(AppRoutes.loadPlanning);
          } else if (title == 'Packing List' &&
              Get.currentRoute != AppRoutes.packingList) {
            Get.toNamed(AppRoutes.packingList);
          } else if (title == 'QR Labels' &&
              Get.currentRoute != AppRoutes.qrLabels) {
            Get.toNamed(AppRoutes.qrLabels);
          } else if (title == 'Freight Loads' &&
              Get.currentRoute != AppRoutes.freightLoads) {
            Get.toNamed(AppRoutes.freightLoads);
          } else if (title == 'Awarded Loads' &&
              Get.currentRoute != AppRoutes.awardedLoads) {
            Get.toNamed(AppRoutes.awardedLoads);
          } else if (title == 'Notification Details' || title == 'Notification History') {
            if (Get.currentRoute != AppRoutes.deliveryNotificationHistory) Get.toNamed(AppRoutes.deliveryNotificationHistory);
          } else if (title == 'Notifications' && Get.currentRoute != AppRoutes.notificationHistory) {
            Get.toNamed(AppRoutes.notificationHistory);
          } else if (title == 'Costings' &&
              Get.currentRoute != AppRoutes.itemCostList) {
            Get.toNamed(AppRoutes.itemCostList);
          } else if (title == 'Savings' &&
              Get.currentRoute != AppRoutes.savings) {
            Get.toNamed(AppRoutes.savings);
          } else if (title == 'Freight Carriers' &&
              Get.currentRoute != AppRoutes.freightCarriers) {
            Get.toNamed(AppRoutes.freightCarriers);
          } else if (title == 'Communication' &&
              Get.currentRoute != AppRoutes.chat) {
            Get.toNamed(AppRoutes.chat);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFF1D4ED8).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Image.asset(
                  iconAsset,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.85),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
