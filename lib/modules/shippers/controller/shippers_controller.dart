import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../item_cost_list/widgets/success_dialog.dart';
import '../model/shipper_model.dart';

class ShippersController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  final RxList<ShipperModel> shippers = <ShipperModel>[].obs;
  final RxList<ShipperModel> filteredShippers = <ShipperModel>[].obs;

  final Rx<ShipperModel?> selectedShipper = Rx<ShipperModel?>(null);

  // Vendor details state
  late Rx<VendorDetailsModel> vendorDetails;
  final RxList<VendorContactRoleModel> contactRoles = <VendorContactRoleModel>[].obs;
  final RxList<VendorOrderHistoryModel> orderHistory = <VendorOrderHistoryModel>[].obs;
  final RxList<ComplianceCertificateModel> certificates = <ComplianceCertificateModel>[].obs;
  final RxBool isComplianceExpanded = true.obs;

  // Add / Edit Shipper Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController yearsController = TextEditingController();
  final RxString serviceCategory = 'Construction Material'.obs;
  final RxString vendorType = 'Material Shipper'.obs;

  final RxString country = 'India'.obs;
  final RxString state = 'Maharashtra'.obs;
  final RxString city = 'Pune'.obs;
  final TextEditingController streetController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController postalController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadShippersData();
    loadVendorDetailsData();
  }

  void loadShippersData() {
    isLoading.value = true;
    final initialList = [
      ShipperModel(
        id: '1',
        vendorCode: 'VEN-001',
        name: 'Steel Shippers Inc.',
        contactName: 'Robert Anderson',
        email: 'robert@steelShippers.com',
        phone: '(555) 111-2222',
        materialTypes: ['Steel & Metal', 'Structural Steel', '+1'],
        activeOrders: 8,
        totalOrders: 156,
      ),
      ShipperModel(
        id: '2',
        vendorCode: 'VEN-002',
        name: 'Concrete Works Ltd.',
        contactName: 'Maria Garcia',
        email: 'maria@concreteworks.com',
        phone: '(555) 222-3333',
        materialTypes: ['Concrete', 'Ready Mix', '+1'],
        activeOrders: 5,
        totalOrders: 98,
      ),
      ShipperModel(
        id: '3',
        vendorCode: 'VEN-003',
        name: 'Lumber & Building Materials Co.',
        contactName: 'David Chen',
        email: 'david@lumberbuild.com',
        phone: '(555) 333-4444',
        materialTypes: ['Lumber', 'Wood Products', '+2'],
        activeOrders: 6,
        totalOrders: 124,
      ),
      ShipperModel(
        id: '4',
        vendorCode: 'VEN-004',
        name: 'Electrical Supply Warehouse',
        contactName: 'Jennifer Thompson',
        email: 'jen@electricalsupply.com',
        phone: '(555) 444-5555',
        materialTypes: ['Electrical', 'Wiring', '+2'],
        activeOrders: 4,
        totalOrders: 67,
      ),
      ShipperModel(
        id: '5',
        vendorCode: 'VEN-005',
        name: 'ABC Plumbing Supplies',
        contactName: 'Michael Brown',
        email: 'mike@abcplumbing.com',
        phone: '(555) 555-6666',
        materialTypes: ['Plumbing', 'Pipes', '+2'],
        activeOrders: 0,
        totalOrders: 23,
      ),
    ];

    shippers.assignAll(initialList);
    applyFilter();
    isLoading.value = false;
  }

  void loadVendorDetailsData() {
    vendorDetails = VendorDetailsModel(
      vendorCode: 'CI-12345',
      rating: 4.7,
      companyName: 'Steel Shippers Inc.',
      status: 'Active',
      address: '4712 Cherry Ridge Drive Rochester, NY 14620.',
      email: 'john@example.com',
      phone: '+1 58578 54840',
      vendorType: 'Material Shipper',
      serviceCategory: 'Construction Materials',
      yearsWorking: '3 Years',
      totalOrders: 142,
      completedDeliveries: 138,
      activeOrders: 4,
      avgDeliveryTime: '2.4 Days',
      onTimeRate: '95%',
    ).obs;

    contactRoles.assignAll([
      VendorContactRoleModel(roleName: 'Sales Rep', name: 'John Doe', phone: '+1 58578 54840'),
      VendorContactRoleModel(roleName: 'Dispatch', name: 'Riyaz Khan', phone: '+1 58578 54840'),
      VendorContactRoleModel(roleName: 'Accounts', name: 'Sir John Peds', phone: '+1 58578 54840'),
      VendorContactRoleModel(roleName: 'Warehouse Manager', name: 'John Doe', phone: '+1 58578 54840'),
    ]);

    orderHistory.assignAll([
      VendorOrderHistoryModel(orderId: 'ORD00025', material: 'Steel Beams', quantity: '20 Tons', orderValue: '\$5,000', status: 'Delivered'),
      VendorOrderHistoryModel(orderId: 'ORD00024', material: 'Cement Bags', quantity: '500 Units', orderValue: '\$10,750', status: 'In Transit'),
      VendorOrderHistoryModel(orderId: 'ORD00023', material: 'Iron Rods', quantity: '12 Tons', orderValue: '\$20,000', status: 'Delivered'),
      VendorOrderHistoryModel(orderId: 'ORD00022', material: 'Cement Bags', quantity: '500 Units', orderValue: '\$50,000', status: 'Delivered'),
      VendorOrderHistoryModel(orderId: 'ORD00019', material: 'Iron Rods', quantity: '20 Tons', orderValue: '\$1,25,000', status: 'Delivered'),
    ]);

    certificates.assignAll([
      ComplianceCertificateModel(name: 'Insurance certificate', size: '6.1 MB', type: 'PDF', expiryDate: 'Mar 15, 2025'),
      ComplianceCertificateModel(name: 'Material certifications', size: '5.2 MB', type: 'PDF', expiryDate: 'Jan 8, 2025'),
      ComplianceCertificateModel(name: 'Contracts', size: '6.1 MB', type: 'PDF', expiryDate: 'Mar 15, 2025'),
      ComplianceCertificateModel(name: 'Pricing sheets', size: '6.1 MB', type: 'PDF', expiryDate: 'Mar 15, 2025'),
    ]);
  }

  void filterSearchResults(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void applyFilter() {
    if (searchQuery.isEmpty) {
      filteredShippers.assignAll(shippers);
    } else {
      final q = searchQuery.value.toLowerCase();
      filteredShippers.assignAll(
        shippers.where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.contactName.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            s.vendorCode.toLowerCase().contains(q)),
      );
    }
  }

  void openVendorDetails(ShipperModel shipper) {
    selectedShipper.value = shipper;
    Get.toNamed(AppRoutes.vendorDetails);
  }

  void openAddShipper() {
    nameController.text = 'Steel Shippers Inc.';
    idController.text = 'SHP-2026-10482';
    phoneController.text = '000-000-0000';
    emailController.text = 'emmawatson@email.com';
    yearsController.text = '3 years';
    streetController.text = 'Palm Residency, MG Road';
    placeController.text = 'Flat 402';
    postalController.text = '411001';
    notesController.text = 'Client requested work completion before Friday inspection. Ensure safety compliance checklist is completed before closure.';
    Get.toNamed(AppRoutes.addShipper);
  }

  void openEditShipper() {
    nameController.text = 'Steel Shippers Inc.';
    idController.text = 'SHP-2026-10482';
    phoneController.text = '000-000-0000';
    emailController.text = 'emmawatson@email.com';
    yearsController.text = '3 years';
    streetController.text = 'Palm Residency, MG Road';
    placeController.text = 'Flat 402';
    postalController.text = '411001';
    notesController.text = 'Client requested work completion before Friday inspection. Ensure safety compliance checklist is completed before closure.';
    Get.toNamed(AppRoutes.editShipper);
  }

  void saveShipper(BuildContext context, {required bool isEdit}) {
    showDialog(
      context: context,
      builder: (ctx) => SuccessDialog(
        title: isEdit ? 'Shipper Updated Successfully' : 'New Shipper Added Successfully',
        buttonText: 'Ok',
        onPressed: () {
          Navigator.of(ctx).pop();
          Get.offNamed(AppRoutes.shippersList);
        },
      ),
    );
  }
}
