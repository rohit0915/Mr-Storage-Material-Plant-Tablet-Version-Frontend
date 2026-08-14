import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../item_cost_list/widgets/success_dialog.dart';
import '../model/shipper_model.dart';
import '../repository/shippers_repository.dart';

class ShippersController extends GetxController {
  final ShippersRepository repository;
  ShippersController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = ''.obs;
  final RxList<ShipperModel> shippers = <ShipperModel>[].obs;
  final RxList<ShipperModel> filteredShippers = <ShipperModel>[].obs;
  final Rx<ShipperModel?> selectedShipper = Rx<ShipperModel?>(null);

  late Rx<VendorDetailsModel> vendorDetails;
  final RxList<VendorContactRoleModel> contactRoles =
      <VendorContactRoleModel>[].obs;
  final RxList<VendorOrderHistoryModel> orderHistory =
      <VendorOrderHistoryModel>[].obs;
  final RxList<ComplianceCertificateModel> certificates =
      <ComplianceCertificateModel>[].obs;
  final RxBool isComplianceExpanded = true.obs;

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
    vendorDetails = _emptyDetails().obs;
    loadShippersData();
  }

  Future<void> loadShippersData() async {
    isLoading.value = true;
    try {
      final data = await repository.list(
        status: statusFilter.value.isEmpty
            ? null
            : statusFilter.value.toLowerCase(),
      );
      final raw = data['vendors'];
      shippers.assignAll(
        raw is List
            ? raw.whereType<Map>().map((item) => _mapShipper(item)).toList()
            : <ShipperModel>[],
      );
      applyFilter();
    } catch (error) {
      shippers.clear();
      filteredShippers.clear();
      CommonSnackbar.showError(title: 'Unable to load shippers', message: error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  ShipperModel _mapShipper(Map item) {
    final stats = _map(item['stats']);
    final materials = item['materialTypes'];
    return ShipperModel(
      id: (item['_id'] ?? item['id'] ?? '').toString(),
      vendorCode:
          (item['vendorCode'] ?? item['shipperCode'] ?? item['code'] ?? '')
              .toString(),
      name:
          (item['vendorName'] ??
                  item['companyName'] ??
                  item['name'] ??
                  'Shipper')
              .toString(),
      contactName: (item['contactName'] ?? item['primaryContact'] ?? '')
          .toString(),
      email: (item['email'] ?? '').toString(),
      phone: (item['phone'] ?? item['phoneNumber'] ?? '').toString(),
      materialTypes: materials is List
          ? materials.map((e) => e.toString()).toList()
          : <String>[],
      activeOrders: _int(item['activeOrders'] ?? stats['activeOrders']),
      totalOrders: _int(item['totalOrders'] ?? stats['totalOrders']),
    );
  }

  void filterSearchResults(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    loadShippersData();
  }

  void applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    filteredShippers.assignAll(
      q.isEmpty
          ? shippers
          : shippers.where(
              (s) =>
                  s.name.toLowerCase().contains(q) ||
                  s.contactName.toLowerCase().contains(q) ||
                  s.email.toLowerCase().contains(q) ||
                  s.vendorCode.toLowerCase().contains(q) ||
                  s.phone.toLowerCase().contains(q) ||
                  s.materialTypes.any((type) => type.toLowerCase().contains(q)),
            ),
    );
  }

  Future<void> openVendorDetails(ShipperModel shipper) async {
    selectedShipper.value = shipper;
    Get.toNamed(AppRoutes.vendorDetails);
    try {
      final data = await repository.detail(shipper.id);
      final stats = _map(data['stats']);
      vendorDetails.value = VendorDetailsModel(
        vendorCode: (data['vendorCode'] ?? shipper.vendorCode).toString(),
        rating: _double(data['rating'] ?? stats['rating']),
        companyName: (data['vendorName'] ?? data['companyName'] ?? shipper.name)
            .toString(),
        status: _title(data['status'] ?? 'active'),
        address: _address(data['address'] ?? data['pickupLocation']),
        email: (data['email'] ?? shipper.email).toString(),
        phone: (data['phone'] ?? shipper.phone).toString(),
        vendorType: (data['vendorType'] ?? 'Material Shipper').toString(),
        serviceCategory: (data['serviceCategory'] ?? '').toString(),
        yearsWorking: (data['yearsWorking'] ?? data['yearsOfWorking'] ?? '')
            .toString(),
        totalOrders: _int(stats['totalOrders'] ?? shipper.totalOrders),
        completedDeliveries: _int(stats['completedDeliveries']),
        activeOrders: _int(stats['activeOrders'] ?? shipper.activeOrders),
        avgDeliveryTime: (stats['avgDeliveryTime'] ?? '-').toString(),
        onTimeRate: (stats['onTimeRate'] ?? '-').toString(),
      );
      _mapVendorCollections(data);
    } catch (error) {
      CommonSnackbar.showError(title: 'Unable to load shipper details', message: error.toString());
    }
  }

  void _mapVendorCollections(Map<String, dynamic> data) {
    final history = data['orderHistory'];
    orderHistory.assignAll(
      history is List
          ? history.whereType<Map>().map(
              (item) => VendorOrderHistoryModel(
                orderId: (item['orderId'] ?? item['projectId'] ?? '')
                    .toString(),
                material: (item['material'] ?? item['materialType'] ?? '')
                    .toString(),
                quantity: (item['quantity'] ?? '').toString(),
                orderValue: (item['orderValue'] ?? item['amount'] ?? '')
                    .toString(),
                status: _title(item['status']),
              ),
            )
          : <VendorOrderHistoryModel>[],
    );
    contactRoles.clear();
    certificates.clear();
  }

  void openAddShipper() {
    _clearForm();
    Get.toNamed(AppRoutes.addShipper);
  }

  void openEditShipper() {
    final shipper = selectedShipper.value;
    if (shipper == null) return;
    nameController.text = shipper.name;
    idController.text = shipper.vendorCode;
    phoneController.text = shipper.phone;
    emailController.text = shipper.email;
    streetController.text = vendorDetails.value.address;
    Get.toNamed(AppRoutes.editShipper);
  }

  Future<void> saveShipper(BuildContext context, {required bool isEdit}) async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      CommonSnackbar.showError(title: 'Required fields', message: 'Shipper name and email are required.');
      return;
    }
    isLoading.value = true;
    try {
      final payload = <String, dynamic>{
        'vendorName': nameController.text.trim(),
        'vendorCode': idController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'vendorType': vendorType.value,
        'serviceCategory': serviceCategory.value,
        'yearsWorking': yearsController.text.trim(),
        'address': {
          'country': country.value,
          'state': state.value,
          'city': city.value,
          'streetAddress': streetController.text.trim(),
          'placeNumber': placeController.text.trim(),
          'postalCode': postalController.text.trim(),
        },
        'notes': notesController.text.trim(),
      };
      if (isEdit && selectedShipper.value != null) {
        await repository.update(selectedShipper.value!.id, payload);
      } else {
        await repository.create(payload);
      }
      await loadShippersData();
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => SuccessDialog(
          title: isEdit
              ? 'Shipper Updated Successfully'
              : 'New Shipper Added Successfully',
          buttonText: 'Ok',
          onPressed: () {
            Navigator.of(ctx).pop();
            Get.offNamed(AppRoutes.shippersList);
          },
        ),
      );
    } catch (error) {
      CommonSnackbar.showError(title: 'Unable to save shipper', message: error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStatus(ShipperModel shipper) async {
    try {
      await repository.toggleStatus(shipper.id);
      await loadShippersData();
    } catch (error) {
      CommonSnackbar.showError(title: 'Unable to update status', message: error.toString());
    }
  }

  void _clearForm() {
    for (final controller in [
      nameController,
      idController,
      phoneController,
      emailController,
      yearsController,
      streetController,
      placeController,
      postalController,
      notesController,
    ]) {
      controller.clear();
    }
  }

  VendorDetailsModel _emptyDetails() => VendorDetailsModel(
    vendorCode: '',
    rating: 0,
    companyName: '',
    status: '',
    address: '',
    email: '',
    phone: '',
    vendorType: '',
    serviceCategory: '',
    yearsWorking: '',
    totalOrders: 0,
    completedDeliveries: 0,
    activeOrders: 0,
    avgDeliveryTime: '-',
    onTimeRate: '-',
  );

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  int _int(dynamic value) => int.tryParse((value ?? 0).toString()) ?? 0;
  double _double(dynamic value) =>
      double.tryParse((value ?? 0).toString()) ?? 0;
  String _title(dynamic value) => (value ?? '')
      .toString()
      .replaceAll('_', ' ')
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
  String _address(dynamic value) {
    if (value is Map) {
      return [
        value['streetAddress'],
        value['city'],
        value['state'],
        value['postalCode'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
    }
    return (value ?? '').toString();
  }
}
