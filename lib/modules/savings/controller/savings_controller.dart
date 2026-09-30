import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/services/file_export_service.dart';
import '../../../app/widgets/common_snackbar.dart';
import '../../item_cost_list/widgets/success_dialog.dart';
import '../model/savings_model.dart';
import '../widgets/custom_date_picker_dialog.dart';

class SavingsController extends GetxController {
  final RxBool isLoading = false.obs;

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final Rx<SavingsSummaryModel> summary = SavingsSummaryModel(
    totalSavingsThisMonth: 12897.0,
    totalLossThisMonth: 2398.0,
  ).obs;

  final RxList<SavingsItemModel> savingsList = <SavingsItemModel>[].obs;
  final RxList<SavingsItemModel> filteredSavingsList = <SavingsItemModel>[].obs;

  final RxString searchQuery = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedStatusFilter = 'Status : Good'.obs;
  final RxInt rowsPerPage = 10.obs;
  final RxInt currentPage = 4.obs;
  final RxInt totalPages = 15.obs;

  String get formattedSelectedDate {
    final d = selectedDate.value;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  @override
  void onInit() {
    super.onInit();
    loadSavingsData();
  }

  void loadSavingsData() {
    isLoading.value = true;

    final initialItems = [
      SavingsItemModel(
        id: '1',
        projectName: 'Warehouse Expansion',
        smdtCost: 24500.0,
        actualCost: 22900.0,
        savings: 1600.0,
        isProfit: true,
        savingsPercentage: 6.5,
        status: 'Good',
      ),
      SavingsItemModel(
        id: '2',
        projectName: 'Steel Building A',
        smdtCost: 18200.0,
        actualCost: 19100.0,
        savings: -900.0,
        isProfit: false,
        savingsPercentage: -4.9,
        status: 'Over Budget',
      ),
      SavingsItemModel(
        id: '3',
        projectName: 'Industrial Shed B',
        smdtCost: 32000.0,
        actualCost: 29750.0,
        savings: 2250.0,
        isProfit: true,
        savingsPercentage: 7.0,
        status: 'Good',
      ),
      SavingsItemModel(
        id: '4',
        projectName: 'Logistics Center',
        smdtCost: 15800.0,
        actualCost: 15500.0,
        savings: 300.0,
        isProfit: true,
        savingsPercentage: 1.9,
        status: 'Good',
      ),
      SavingsItemModel(
        id: '5',
        projectName: 'Commercial Project C',
        smdtCost: 40000.0,
        actualCost: 42400.0,
        savings: -2400.0,
        isProfit: false,
        savingsPercentage: -6.0,
        status: 'Over Budget',
      ),
      SavingsItemModel(
        id: '6',
        projectName: 'Warehouse Expansion',
        smdtCost: 24500.0,
        actualCost: 22900.0,
        savings: 1600.0,
        isProfit: true,
        savingsPercentage: 6.5,
        status: 'Good',
      ),
      SavingsItemModel(
        id: '7',
        projectName: 'Warehouse Expansion',
        smdtCost: 24500.0,
        actualCost: 22900.0,
        savings: 1600.0,
        isProfit: true,
        savingsPercentage: 6.5,
        status: 'Good',
      ),
    ];

    savingsList.assignAll(initialItems);
    applyFilters();
    isLoading.value = false;
  }

  void filterSearchResults(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setStatusFilter(String filter) {
    selectedStatusFilter.value = filter;
    applyFilters();
  }

  void applyFilters() {
    List<SavingsItemModel> result = List.from(savingsList);

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result
          .where((e) => e.projectName.toLowerCase().contains(q))
          .toList();
    }

    if (selectedStatusFilter.value == 'Status : Good') {
      result = result.where((e) => e.status == 'Good').toList();
    } else if (selectedStatusFilter.value == 'Status : Over Budget') {
      result = result.where((e) => e.status == 'Over Budget').toList();
    }

    filteredSavingsList.assignAll(result);
  }

  void openDatePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDatePickerDialog(
        initialDate: selectedDate.value,
        onDateSelected: (newDate) {
          selectedDate.value = newDate;
          applyFilters();
        },
      ),
    );
  }

  Future<void> exportFile(BuildContext context) async {
    try {
      await FileExportService.saveCsv(
        fileName:
            'savings_${selectedDate.value.toIso8601String().split('T').first}',
        rows: [
          const [
            'Project Name',
            'SMDT Cost',
            'Actual Cost',
            'Savings',
            'Savings Percentage',
            'Status',
          ],
          ...filteredSavingsList.map(
            (item) => [
              item.projectName,
              item.smdtCost,
              item.actualCost,
              item.savings,
              item.savingsPercentage,
              item.status,
            ],
          ),
        ],
      );
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => SuccessDialog(
          title: 'File Exported Successfully',
          buttonText: 'Ok',
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      );
    } catch (error) {
      CommonSnackbar.showError(
        title: 'Export failed',
        message: error.toString(),
      );
    }
  }
}
