import 'package:get/get.dart';
import '../model/bom_files_details_model.dart';

class BomFilesDetailsController extends GetxController {
  final RxBool isLoading = false.obs;

  final Rx<BomSummaryModel?> summary = Rx<BomSummaryModel?>(null);
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

  void loadBomData() {
    isLoading.value = true;

    summary.value = BomSummaryModel(
      totalItems: 125,
      totalWeight: '32,000 lbs',
      totalPanelsArea: '3,300 sqm',
    );

    bomItems.assignAll([
      BomItemModel(qty: 5, mark: 'S-1', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
      BomItemModel(qty: 8, mark: 'S-2', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
      BomItemModel(qty: 6, mark: 'S-3', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
      BomItemModel(qty: 5, mark: 'S-4', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
      BomItemModel(qty: 8, mark: 'S-5', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
      BomItemModel(qty: 6, mark: 'S-6', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
      BomItemModel(qty: 3, mark: 'S-7', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
      BomItemModel(qty: 4, mark: 'S-8', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
      BomItemModel(qty: 2, mark: 'S-9', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
      BomItemModel(qty: 4, mark: 'S-10', description: 'STUD', part: 'C42516', color: 'RO', angle: '-', thick: '16 GA', length: "8'-7 1/4\"", weight: '16.00'),
    ]);

    isLoading.value = false;
  }
}
