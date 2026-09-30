import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/common_snackbar.dart';
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

  late final Rx<VendorDetailsModel> vendorDetails = _emptyDetails().obs;
  final RxList<VendorContactRoleModel> contactRoles =
      <VendorContactRoleModel>[].obs;
  final RxList<VendorOrderHistoryModel> orderHistory =
      <VendorOrderHistoryModel>[].obs;
  final RxList<ComplianceCertificateModel> certificates =
      <ComplianceCertificateModel>[].obs;
  final RxBool isComplianceExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
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
      CommonSnackbar.showError(
        title: 'Unable to load shippers',
        message: error.toString(),
      );
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
    await refreshVendorDetails(shipper);
  }

  Future<void> refreshVendorDetails(ShipperModel shipper) async {
    try {
      final response = await repository.detail(shipper.id);
      final data = response['vendor'] is Map
          ? Map<String, dynamic>.from(response['vendor'])
          : response;
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
        vendorType: (data['vendorType'] ?? 'other').toString(),
        serviceCategory:
            (data['serviceCategory'] ?? data['category'] ?? '-').toString(),
        yearsWorking:
            (data['yearsWithCompany'] ??
                    data['yearsWorking'] ??
                    data['yearsOfWorking'] ??
                    '-')
                .toString(),
        totalOrders: _int(stats['totalOrders'] ?? data['totalOrders'] ?? shipper.totalOrders),
        completedDeliveries: _int(stats['completedDeliveries'] ?? data['completedDeliveries']),
        activeOrders: _int(stats['activeOrders'] ?? data['activeOrders'] ?? shipper.activeOrders),
        avgDeliveryTime:
            (stats['avgDeliveryTime'] ?? stats['averageDeliveryTime'] ?? data['avgDeliveryTime'] ?? '-')
                .toString(),
        onTimeRate:
            (stats['onTimeRate'] ?? stats['onTimeDeliveryRate'] ?? data['onTimeRate'] ?? '-')
                .toString(),
        notes: (data['notes'] ?? data['note'] ?? data['description'] ?? '').toString(),
      );
      _mapVendorCollections(data, shipper);
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Unable to load shipper details',
        message: error.toString(),
      );
    }
  }

  void _mapVendorCollections(Map<String, dynamic> data, ShipperModel shipper) {
    // 1. Order History
    final history = data['orderHistory'] ?? data['orders'] ?? data['purchaseHistory'];
    orderHistory.assignAll(
      history is List
          ? history.whereType<Map>().map(
              (item) => VendorOrderHistoryModel(
                orderId: (item['orderId'] ??
                        item['orderCode'] ??
                        item['code'] ??
                        item['_id'] ??
                        '')
                    .toString(),
                project: (item['project'] ??
                        item['projectName'] ??
                        item['projectTitle'] ??
                        item['material'] ??
                        item['materialType'] ??
                        '-')
                    .toString(),
                material: (item['material'] ??
                        item['materialType'] ??
                        item['project'] ??
                        '-')
                    .toString(),
                quantity: (item['quantity'] ?? item['packageCount'] ?? '-').toString(),
                orderValue:
                    (item['orderValue'] ?? item['amount'] ?? item['total'] ?? '-')
                        .toString(),
                status: _title(item['status'] ?? 'Pending'),
              ),
            )
          : <VendorOrderHistoryModel>[],
    );

    // 2. Vendor Contact Roles
    final rolesList = data['contactRoles'] ?? data['contacts'];
    if (rolesList is List && rolesList.isNotEmpty) {
      contactRoles.assignAll(
        rolesList.whereType<Map>().map(
              (r) => VendorContactRoleModel(
                roleName: (r['roleName'] ?? r['role'] ?? r['title'] ?? 'Contact')
                    .toString(),
                name: (r['name'] ?? r['contactName'] ?? '-').toString(),
                phone: (r['phone'] ?? r['phoneNumber'] ?? '').toString(),
              ),
            ),
      );
    } else {
      // Default contact roles matching web panel
      final contactName = (data['contactName'] ??
              (data['primaryContact'] is Map
                  ? data['primaryContact']['name']
                  : data['primaryContact']) ??
              shipper.contactName)
          .toString()
          .trim();
      final contactPhone = (data['phone'] ??
              data['phoneNumber'] ??
              (data['primaryContact'] is Map
                  ? data['primaryContact']['phone']
                  : null) ??
              shipper.phone)
          .toString()
          .trim();
      final pickupLoc = _address(data['pickupLocation'] ?? data['address']);

      contactRoles.assignAll([
        VendorContactRoleModel(
          roleName: 'Primary Contact',
          name: contactName.isNotEmpty ? contactName : '-',
          phone: contactPhone.isNotEmpty ? contactPhone : '',
        ),
        VendorContactRoleModel(
          roleName: 'Pickup Location',
          name: pickupLoc.isNotEmpty ? pickupLoc : '-',
          phone: '',
        ),
      ]);
    }

    // 3. Compliance Documents
    final docsList = data['complianceDocuments'] ??
        data['compliance'] ??
        data['certificates'] ??
        data['documents'];
    if (docsList is List) {
      certificates.assignAll(
        docsList.whereType<Map>().map(
              (d) => ComplianceCertificateModel(
                name: (d['name'] ??
                        d['documentName'] ??
                        d['title'] ??
                        d['fileName'] ??
                        'Document')
                    .toString(),
                size: (d['size'] ?? d['fileSize'] ?? '-').toString(),
                type: (d['type'] ?? d['docType'] ?? d['documentType'] ?? 'PDF')
                    .toString(),
                expiryDate: (d['expiryDate'] ??
                        d['expirationDate'] ??
                        d['expiresAt'] ??
                        '-')
                    .toString(),
              ),
            ),
      );
    } else {
      certificates.clear();
    }
  }

  void openAddShipper() => Get.toNamed(AppRoutes.addShipper);

  void openEditShipper() {
    if (selectedShipper.value != null) Get.toNamed(AppRoutes.editShipper);
  }

  Future<void> toggleStatus(ShipperModel shipper) async {
    try {
      await repository.toggleStatus(shipper.id);
      await loadShippersData();
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Unable to update status',
        message: error.toString(),
      );
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
    notes: '',
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
      final parts = [
        value['streetAddress'],
        value['city'],
        value['state'],
        value['postalCode'],
      ]
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString().trim())
          .toList();
      return parts.join(', ');
    }
    final s = (value ?? '').toString().trim();
    if (s == ',' || s == ', ' || s == '—' || s == '-') return '';
    return s;
  }
}
