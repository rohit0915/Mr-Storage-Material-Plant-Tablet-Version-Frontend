import 'package:get/get.dart';
import '../model/generate_shipper_order_model.dart';

class GenerateShipperOrderController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<ShipperCardModel> shippers = <ShipperCardModel>[].obs;
  final RxList<String> newShipperEmails = <String>[].obs;

  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadShippers();
  }

  void loadShippers() {
    isLoading.value = true;

    shippers.assignAll([
      ShipperCardModel(id: '1', name: 'Steel Investments', rating: 4.8, serviceArea: 'Texas / Oklahoma', isSelected: true),
      ShipperCardModel(id: '2', name: 'DBA Storage Materials', rating: 4.5, serviceArea: 'Texas / Oklahoma', isSelected: true),
      ShipperCardModel(id: '3', name: 'Steel Investments', rating: 4.2, serviceArea: 'Texas / Oklahoma', isSelected: false),
      ShipperCardModel(id: '4', name: 'DBA Storage Materials', rating: 4.9, serviceArea: 'Texas / Oklahoma', isSelected: false),
    ]);

    newShipperEmails.assignAll(['steelinvestment@gmail.com']);

    isLoading.value = false;
  }

  void toggleShipperSelect(int index) {
    shippers[index].isSelected = !shippers[index].isSelected;
    shippers.refresh();
  }

  void addNewShipperEmail(String name, String email, String phone) {
    if (email.isNotEmpty && !newShipperEmails.contains(email)) {
      newShipperEmails.add(email);
    }
  }

  void removeShipperEmail(int index) {
    if (index >= 0 && index < newShipperEmails.length) {
      newShipperEmails.removeAt(index);
    }
  }
}
