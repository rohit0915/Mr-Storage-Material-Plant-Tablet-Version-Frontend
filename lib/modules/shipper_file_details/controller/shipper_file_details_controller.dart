import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';
import '../../shipper_files/widgets/ready_for_planning_dialog.dart';

class SalesOrderItemModel {
  final int qty;
  final String itemCode;
  final String description;
  final String length;
  final int weight;
  final String unitPrice;
  final String amount;
  SalesOrderItemModel({
    required this.qty,
    required this.itemCode,
    required this.description,
    required this.length,
    required this.weight,
    required this.unitPrice,
    required this.amount,
  });
}

class ShipperFileDetailsController extends GetxController {
  final ShipperRequestWorkflowRepository repository;
  ShipperFileDetailsController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxList<SalesOrderItemModel> salesOrderItems =
      <SalesOrderItemModel>[].obs;
  final RxString status = 'Under Review'.obs;
  final RxString requestId = ''.obs;
  final RxMap<String, dynamic> request = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> document = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    requestId.value = Get.parameters['id'] ?? '';
    loadSalesOrderDetails();
  }

  Future<void> loadSalesOrderDetails() async {
    if (requestId.value.isEmpty) return;
    isLoading.value = true;
    try {
      final data = await repository.document(requestId.value);
      request.assignAll(_map(data['request']));
      document.assignAll(_map(data['document']));
      status.value = _title(
        request['status'] ?? document['status'] ?? 'under_review',
      );
      final rawItems =
          document['items'] ?? document['lineItems'] ?? request['items'];
      final items = rawItems is List ? rawItems : const [];
      salesOrderItems.assignAll(
        items.whereType<Map>().map(
          (item) => SalesOrderItemModel(
            qty: _int(item['qty'] ?? item['quantity']),
            itemCode: (item['itemCode'] ?? item['partNumber'] ?? '').toString(),
            description: (item['description'] ?? '').toString(),
            length: (item['length'] ?? '').toString(),
            weight: _int(item['weight']),
            unitPrice: _money(item['unitPrice'] ?? item['rate']),
            amount: _money(item['amount'] ?? item['total']),
          ),
        ),
      );
    } catch (error) {
      CommonSnackbar.showError(title: 'Unable to load document', message: error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void openOrderVerificationDialog() => Get.toNamed(
    AppRoutes.orderVerification,
    parameters: {'id': requestId.value},
  );

  Future<void> startLoadPlanning() async {
    isLoading.value = true;
    try {
      final data = await repository.generateBundlePlan(requestId.value);
      if ((data['bundlePlanId'] ?? '').toString().isEmpty) {
        throw Exception('Bundle plan was not created.');
      }
      Get.dialog(const ReadyForPlanningDialog());
    } catch (error) {
      CommonSnackbar.showError(title: 'Unable to generate bundle plan', message: error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  String _money(dynamic value) => value == null ? r'$0' : '\$$value';
  String _title(dynamic value) => (value ?? '')
      .toString()
      .replaceAll('_', ' ')
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
}
