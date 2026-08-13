import 'package:get/get.dart';
import '../model/bom_files_details_model.dart';
import '../repository/bom_files_details_repository.dart';

class BomFilesDetailsController extends GetxController {
  final BomFilesDetailsRepository repository;
  BomFilesDetailsController({required this.repository});
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<BomSummaryModel?> summary = Rx<BomSummaryModel?>(null);
  final Rx<MissingItemCostSummaryModel?> missingSummary =
      Rx<MissingItemCostSummaryModel?>(null);
  final RxList<BomItemModel> bomItems = <BomItemModel>[].obs;

  final String projectName = 'ABC Construction';
  final String bomId = 'BOM-001';
  final String date = '01.09.26';
  final String jobId = 'BLDG-D';
  final String customerName = 'John Doe';

  @override
  void onInit() {
    super.onInit();
    loadBomData();
  }

  Future<void> loadBomData() async {
    isLoading.value = true;
    final projectId = Get.parameters['id'] ?? '';
    if (projectId.isEmpty) {
      errorMessage.value = 'Project id is missing.';
      isLoading.value = false;
      return;
    }
    try {
      final data = await repository.fetch(projectId);
      final buildings = data['buildings'] is List
          ? data['buildings'] as List
          : const [];
      final items = <Map>[];
      for (final raw in buildings.whereType<Map>()) {
        final building = Map<String, dynamic>.from(raw);
        final bom = building['bom'] is Map
            ? Map<String, dynamic>.from(building['bom'] as Map)
            : building;
        final rawItems = bom['items'];
        if (rawItems is List) items.addAll(rawItems.whereType<Map>());
      }
      if (items.isNotEmpty) {
        bomItems.assignAll(
          items.map((raw) {
            final item = Map<String, dynamic>.from(raw);
            final price = item['amount'] ?? item['totalPrice'] ?? item['price'];
            return BomItemModel(
              qty: _int(item['qty'] ?? item['quantity']),
              mark: '${item['mark'] ?? ''}',
              description: '${item['description'] ?? ''}',
              part: '${item['part'] ?? item['partNumber'] ?? ''}',
              color: '${item['color'] ?? ''}',
              angle: '${item['angle'] ?? '-'}',
              thick: '${item['thick'] ?? item['thickness'] ?? ''}',
              length: '${item['length'] ?? ''}',
              weight: '${item['weight'] ?? 0}',
              amount: price == null ? 'Missing' : '\$$price',
              isMissing: price == null,
            );
          }),
        );
        summary.value = BomSummaryModel(
          totalItems: bomItems.length,
          totalWeight: '${data['totalWeight'] ?? 0} lbs',
          totalPanelsArea: '${data['totalPanelsArea'] ?? 0} sqm',
        );
        missingSummary.value = MissingItemCostSummaryModel(
          totalAmount: 0,
          missingItemQty: bomItems.where((item) => item.isMissing).length,
        );
      } else {
        bomItems.clear();
        summary.value = BomSummaryModel(
          totalItems: 0,
          totalWeight: '0 lbs',
          totalPanelsArea: '0 sqm',
        );
        missingSummary.value = MissingItemCostSummaryModel(
          totalAmount: 0,
          missingItemQty: 0,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      bomItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
