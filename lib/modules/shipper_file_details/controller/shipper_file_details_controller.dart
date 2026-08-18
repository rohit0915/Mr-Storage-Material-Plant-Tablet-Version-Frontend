import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../shipper_files/repository/shipper_request_workflow_repository.dart';

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
  final RxString errorMessage = ''.obs;
  final RxString projectName = ''.obs;
  final RxString projectCode = ''.obs;
  final RxString leadId = ''.obs;
  final RxString vendorName = ''.obs;
  final RxString fileName = ''.obs;
  final RxString uploadedDate = ''.obs;
  final RxString fileUrl = ''.obs;
  final Rxn<Uint8List> pdfBytes = Rxn<Uint8List>();
  final RxBool isPdfLoading = false.obs;
  final RxString pdfError = ''.obs;
  final RxMap<String, dynamic> request = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> document = <String, dynamic>{}.obs;

  final RxBool showEmbeddedView = true.obs;
  final RxDouble zoomScale = 1.0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  void toggleEmbeddedView() {
    showEmbeddedView.value = !showEmbeddedView.value;
    if (showEmbeddedView.value && pdfBytes.value == null) {
      loadPdfPreview();
    }
  }

  void zoomIn() {
    if (zoomScale.value < 2.0) {
      zoomScale.value = (zoomScale.value + 0.15).clamp(0.5, 2.0);
    }
  }

  void zoomOut() {
    if (zoomScale.value > 0.5) {
      zoomScale.value = (zoomScale.value - 0.15).clamp(0.5, 2.0);
    }
  }

  void resetZoom() {
    zoomScale.value = 1.0;
  }

  @override
  void onInit() {
    super.onInit();
    requestId.value = Get.parameters['id'] ?? '';
    loadSalesOrderDetails();
  }

  Future<void> loadSalesOrderDetails() async {
    if (requestId.value.isEmpty) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await repository.document(requestId.value);
      // The plant API returns this document as a flat object. Keep support for
      // the older nested shape as well, but never replace missing data with mocks.
      request.assignAll({...data, ..._map(data['request'])});
      document.assignAll({...data, ..._map(data['document'])});
      projectName.value = (data['projectName'] ?? request['projectName'] ?? '-')
          .toString();
      projectCode.value = (data['projectId'] ?? request['projectId'] ?? '-')
          .toString();
      leadId.value = (data['leadId'] ?? request['leadId'] ?? '').toString();
      vendorName.value = (data['vendorName'] ?? request['vendorName'] ?? '-')
          .toString();
      fileName.value = (data['fileName'] ?? document['fileName'] ?? '-')
          .toString();
      uploadedDate.value = _date(
        data['uploadedDate'] ?? document['uploadedDate'],
      );
      fileUrl.value = (data['fileUrl'] ?? document['fileUrl'] ?? '').toString();
      pdfBytes.value = null;
      status.value = _title(
        data['fileStatus'] ??
            request['status'] ??
            document['status'] ??
            'under_review',
      );
      final rawItems =
          data['items'] ??
          data['lineItems'] ??
          document['items'] ??
          document['lineItems'] ??
          request['items'];
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
      if (showEmbeddedView.value) await loadPdfPreview();
    } catch (error) {
      salesOrderItems.clear();
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openOrderVerificationDialog() => Get.toNamed(
    AppRoutes.orderVerification,
    parameters: {
      'id': requestId.value,
      if (leadId.value.isNotEmpty) 'projectId': leadId.value,
    },
  );

  Future<void> openFile() async {
    showEmbeddedView.value = true;
    if (pdfBytes.value == null) await loadPdfPreview();
  }

  Future<void> loadPdfPreview() async {
    final url = fileUrl.value.trim();
    if (url.isEmpty) {
      pdfError.value = 'Shipper file URL was not returned by the server.';
      return;
    }
    isPdfLoading.value = true;
    pdfError.value = '';
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? const <int>[]);
      final isPdf =
          bytes.length >= 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;
      if (!isPdf) {
        throw Exception('The uploaded shipper file is not a valid PDF.');
      }
      pdfBytes.value = bytes;
    } catch (error) {
      pdfBytes.value = null;
      pdfError.value = 'Unable to load the uploaded shipper PDF: $error';
    } finally {
      isPdfLoading.value = false;
    }
  }

  Future<void> startLoadPlanning() async {
    isLoading.value = true;
    try {
      final existingPlanId = await _existingBundlePlanId();
      if (existingPlanId.isNotEmpty) {
        _openLoadPlanning(existingPlanId);
        return;
      }

      final data = await repository.generateBundlePlan(requestId.value);
      final bundlePlanId = _bundlePlanId(data);
      if (bundlePlanId.isEmpty) {
        throw Exception('Bundle plan was not created.');
      }
      _openLoadPlanning(bundlePlanId);
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('bundle plan already exists')) {
        final existingPlanId = await _existingBundlePlanId();
        if (existingPlanId.isNotEmpty) {
          _openLoadPlanning(existingPlanId);
          return;
        }
      }
      CommonSnackbar.showError(
        title: 'Unable to generate bundle plan',
        message: error.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _existingBundlePlanId() async {
    if (leadId.value.isEmpty) return '';
    try {
      return _bundlePlanId(await repository.projectBundlePlan(leadId.value));
    } catch (_) {
      return '';
    }
  }

  String _bundlePlanId(Map<String, dynamic> data) {
    final plan = _map(data['bundlePlan']);
    return (data['bundlePlanId'] ??
            data['_id'] ??
            plan['bundlePlanId'] ??
            plan['_id'] ??
            '')
        .toString();
  }

  void _openLoadPlanning(String bundlePlanId) {
    Get.toNamed(
      AppRoutes.projectLoadPlanning,
      parameters: {
        'id': leadId.value,
        'name': projectName.value,
        'bundlePlanId': bundlePlanId,
      },
    );
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

  String _date(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString())?.toLocal();
    if (date == null) return '-';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}
