import 'package:get/get.dart';

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
  final RxBool isLoading = false.obs;

  final RxList<SalesOrderItemModel> salesOrderItems = <SalesOrderItemModel>[].obs;
  final RxString status = 'Approved'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSalesOrderDetails();
  }

  void loadSalesOrderDetails() {
    isLoading.value = true;

    salesOrderItems.assignAll([
      SalesOrderItemModel(qty: 5, itemCode: 'PC16RO8X', description: '16Ga CEE Purlin Red Oxide 8X3-12"\nPunch: Custom, Piece Mark: DJ-1', length: "6'11-3/4\"", weight: 621, unitPrice: '\$2.0', amount: '\$16.00'),
      SalesOrderItemModel(qty: 8, itemCode: 'PC16RO8X', description: '16Ga CEE Purlin Red Oxide 8X3-12"\nPunch: Custom, Piece Mark: DJ-1', length: "6'11-3/4\"", weight: 621, unitPrice: '\$2.0', amount: '\$16.00'),
      SalesOrderItemModel(qty: 6, itemCode: 'PC16RO8X', description: '16Ga CEE Purlin Red Oxide 8X3-12"\nPunch: Custom, Piece Mark: DJ-1', length: "6'11-3/4\"", weight: 621, unitPrice: '\$2.0', amount: '\$16.00'),
      SalesOrderItemModel(qty: 5, itemCode: 'PC16RO8X', description: '16Ga CEE Purlin Red Oxide 8X3-12"\nPunch: Custom, Piece Mark: DJ-1', length: "6'11-3/4\"", weight: 621, unitPrice: '\$2.0', amount: '\$16.00'),
      SalesOrderItemModel(qty: 8, itemCode: 'PC16RO8X', description: '16Ga CEE Purlin Red Oxide 8X3-12"\nPunch: Custom, Piece Mark: DJ-1', length: "6'11-3/4\"", weight: 621, unitPrice: '\$2.0', amount: '\$16.00'),
      SalesOrderItemModel(qty: 6, itemCode: 'PC16RO8X', description: '16Ga CEE Purlin Red Oxide 8X3-12"\nPunch: Custom, Piece Mark: DJ-1', length: "6'11-3/4\"", weight: 621, unitPrice: '\$2.0', amount: '\$16.00'),
      SalesOrderItemModel(qty: 3, itemCode: 'PC16RO8X', description: '16Ga CEE Purlin Red Oxide 8X3-12"\nPunch: Custom, Piece Mark: DJ-1', length: "6'11-3/4\"", weight: 621, unitPrice: '\$2.0', amount: '\$16.00'),
      SalesOrderItemModel(qty: 4, itemCode: 'PC16RO8X', description: '16Ga CEE Purlin Red Oxide 8X3-12"\nPunch: Custom, Piece Mark: DJ-1', length: "6'11-3/4\"", weight: 621, unitPrice: '\$2.0', amount: '\$16.00'),
      SalesOrderItemModel(qty: 2, itemCode: 'PC16RO8X', description: '16Ga CEE Purlin Red Oxide 8X3-12"\nPunch: Custom, Piece Mark: DJ-1', length: "6'11-3/4\"", weight: 621, unitPrice: '\$2.0', amount: '\$16.00'),
    ]);

    isLoading.value = false;
  }
}
