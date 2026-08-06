import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/delivery_details_controller.dart';

class DeliveryDetailsView extends GetView<DeliveryDetailsController> {
  const DeliveryDetailsView({super.key});

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
                    children: [
                      // Header Navigation & Actions Bar
                      _buildHeaderToolbar(),
                      const SizedBox(height: 16),

                      // Main Two-Column Layout
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Content Column (Flex: 7)
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                _buildDeliveryOverviewCard(),
                                const SizedBox(height: 16),
                                _buildDeliveryInfoCard(),
                                const SizedBox(height: 16),
                                _buildVendorAndCarrierRow(),
                                const SizedBox(height: 16),
                                _buildInternalOwnerAndPriorityRow(),
                                const SizedBox(height: 16),
                                _buildSiteCoordinationCard(),
                                const SizedBox(height: 16),
                                _buildFreightLinkCard(),
                                const SizedBox(height: 16),
                                _buildNotificationHistoryCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right Sidebar Column (Flex: 3)
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildReceivingContactCard(),
                                const SizedBox(height: 16),
                                _buildStatusHistoryCard(),
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
        ElevatedButton.icon(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
          label: const Text('Back', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              '${controller.delivery.deliveryId} - ${controller.delivery.title}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh, size: 14, color: AppColors.textPrimary),
          label: const Text('Reschedule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
          label: const Text('Edit Delivery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryOverviewCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Delivery Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  controller.delivery.status,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetaField('PROJECT', controller.delivery.projectName, icon: Icons.business)),
              Expanded(child: _buildMetaField('CUSTOMER', controller.delivery.customer)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetaField('DELIVERY DATE', controller.delivery.deliveryDate, icon: Icons.calendar_today_outlined)),
              Expanded(child: _buildMetaField('TIME WINDOW', controller.delivery.timeWindow, icon: Icons.access_time)),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetaField('SITE ADDRESS', controller.delivery.siteAddress, icon: Icons.location_on_outlined),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _buildMetaField('DESCRIPTION', controller.delivery.description, icon: Icons.check_circle_outline),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetaField('MATERIAL CATEGORY', controller.delivery.materialCategory)),
              Expanded(child: _buildMetaField('PICKUP DATE', controller.delivery.pickupDate)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendorAndCarrierRow() {
    return Row(
      children: [
        Expanded(
          child: _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vendor', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Text(controller.delivery.vendorName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _buildIconText(Icons.person_outline, controller.delivery.vendorContact),
                const SizedBox(height: 4),
                _buildIconText(Icons.phone_outlined, controller.delivery.vendorPhone),
                const SizedBox(height: 4),
                _buildIconText(Icons.email_outlined, controller.delivery.vendorEmail),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Company', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                _buildIconText(Icons.local_shipping_outlined, controller.delivery.deliveryCompany),
                const SizedBox(height: 6),
                _buildIconText(Icons.person_outline, controller.delivery.carrierContact),
                const SizedBox(height: 4),
                _buildIconText(Icons.phone_outlined, controller.delivery.carrierPhone),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInternalOwnerAndPriorityRow() {
    return Row(
      children: [
        Expanded(
          child: _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Internal Owner', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Text(controller.delivery.internalOwner, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _buildIconText(Icons.person_outline, controller.delivery.internalContact),
                const SizedBox(height: 4),
                _buildIconText(Icons.phone_outlined, controller.delivery.vendorPhone),
                const SizedBox(height: 4),
                _buildIconText(Icons.email_outlined, controller.delivery.vendorEmail),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Priority, Type, Size', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Text('${controller.delivery.deliveryId} - ${controller.delivery.title}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Priority: ${controller.delivery.priority}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Delivery Type: ${controller.delivery.deliveryType}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Load Size / Quantity: ${controller.delivery.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSiteCoordinationCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Site Coordination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          _buildMetaField('SITE INSTRUCTIONS', controller.delivery.siteInstructions),
          const SizedBox(height: 12),
          _buildMetaField('REQUIRED EQUIPMENT', controller.delivery.requiredEquipment),
          const SizedBox(height: 12),
          _buildMetaField('EQUIPMENT CONFIRMATION STATUS', '✓ ${controller.delivery.equipmentStatus}'),
          const SizedBox(height: 12),
          _buildMetaField('SPECIAL NOTES', controller.delivery.specialNotes),
        ],
      ),
    );
  }

  Widget _buildFreightLinkCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Freight Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          _buildMetaField('FREIGHT LOAD ID', controller.delivery.freightLoadId),
          const SizedBox(height: 12),
          _buildMetaField('AWARDED CARRIER', controller.delivery.awardedCarrier),
          const SizedBox(height: 12),
          _buildMetaField('PRICE', controller.delivery.price),
        ],
      ),
    );
  }

  Widget _buildNotificationHistoryCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notification History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          ...controller.notificationHistory.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(item.subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.status == 'Sent' ? const Color(0xFFDCFCE7) : const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: item.status == 'Sent' ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.timestamp, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReceivingContactCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Receiving Point of Contact', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFDBEAFE),
                child: Text(
                  controller.delivery.receivingName.split(' ').map((e) => e[0]).join(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
              const SizedBox(width: 10),
              Text(controller.delivery.receivingName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _buildIconText(Icons.phone_outlined, controller.delivery.receivingPhone),
          const SizedBox(height: 6),
          _buildIconText(Icons.email_outlined, controller.delivery.receivingEmail),
        ],
      ),
    );
  }

  Widget _buildStatusHistoryCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ...List.generate(controller.statusHistory.length, (index) {
            final item = controller.statusHistory[index];
            final isLast = index == controller.statusHistory.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 38,
                        color: const Color(0xFFCBD5E1),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(item.timestamp, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(item.description, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: child,
    );
  }

  Widget _buildMetaField(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
