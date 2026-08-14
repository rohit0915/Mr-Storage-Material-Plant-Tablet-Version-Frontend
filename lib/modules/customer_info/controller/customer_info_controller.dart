import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/repositories/workflow_repository.dart';
import '../../../app/utils/app_colors.dart';
import '../model/customer_info_model.dart';

class CustomerInfoController extends GetxController {
  final WorkflowRepository repository;
  CustomerInfoController({required this.repository});
  final RxBool isLoading = false.obs;
  final Rxn<CustomerProfileModel> profile = Rxn<CustomerProfileModel>();
  final RxList<CustomerStatModel> stats = <CustomerStatModel>[].obs;
  final RxList<CustomerProjectModel> projects = <CustomerProjectModel>[].obs;
  final RxList<CustomerInvoiceModel> invoices = <CustomerInvoiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomerInfo();
  }

  Future<void> loadCustomerInfo() async {
    isLoading.value = true;
    try {
      final data = await repository.customers(
        search: Get.parameters['search'] ?? '',
        limit: 20,
      );
      final raw = data['customers'];
      final customers = raw is List ? raw.whereType<Map>().toList() : <Map>[];
      if (customers.isEmpty) {
        profile.value = null;
        stats.clear();
        projects.clear();
        invoices.clear();
        return;
      }
      final item = Map<String, dynamic>.from(customers.first);
      final customerProjects = item['projects'] is List
          ? item['projects'] as List
          : const [];
      final customerInvoices = item['invoices'] is List
          ? item['invoices'] as List
          : const [];
      profile.value = CustomerProfileModel(
        name:
            (item['name'] ??
                    item['customerName'] ??
                    '${item['firstName'] ?? ''} ${item['lastName'] ?? ''}')
                .toString()
                .trim(),
        id: (item['customerCode'] ?? item['_id'] ?? '').toString(),
        joinedDate: _date(item['createdAt']),
        isActive:
            (item['status'] ?? 'active').toString().toLowerCase() == 'active',
        phone: (item['phone'] ?? '').toString(),
        email: (item['email'] ?? '').toString(),
        address: _address(item['address']),
      );
      final completed = customerProjects
          .whereType<Map>()
          .where((p) => '${p['status']}'.toLowerCase() == 'completed')
          .length;
      final active = customerProjects.length - completed;
      stats.assignAll([
        CustomerStatModel(
          title: 'Total Projects',
          count: '${customerProjects.length}',
          iconData: Icons.build_outlined,
          backgroundColor: AppColors.totalProjectsCard,
        ),
        CustomerStatModel(
          title: 'Completed',
          count: '$completed',
          iconData: Icons.verified_user_outlined,
          backgroundColor: AppColors.inProductionCard,
        ),
        CustomerStatModel(
          title: 'Work in progress',
          count: '$active',
          iconData: Icons.monetization_on_outlined,
          backgroundColor: AppColors.readyToDispatchCard,
        ),
        CustomerStatModel(
          title: 'Canceled',
          count: '0',
          iconData: Icons.show_chart,
          backgroundColor: AppColors.pendingApprovalCard,
        ),
      ]);
      projects.assignAll(
        customerProjects.whereType<Map>().map(
          (p) => CustomerProjectModel(
            projectCode: (p['projectId'] ?? p['_id'] ?? '').toString(),
            projectName: (p['projectName'] ?? p['name'] ?? '').toString(),
            amount: _money(p['amount'] ?? p['quoteValue']),
            status: _title(p['status']),
            startDate: _date(p['startDate']),
            endDate: _date(p['endDate']),
            isCompleted: '${p['status']}'.toLowerCase() == 'completed',
          ),
        ),
      );
      invoices.assignAll(
        customerInvoices.whereType<Map>().map(
          (i) => CustomerInvoiceModel(
            invoiceNumber: (i['invoiceNumber'] ?? i['_id'] ?? '').toString(),
            dueDate: _date(i['dueDate']),
            amount: _money(i['amount']),
            paid: _money(i['paid']),
            amountDue: _money(i['amountDue']),
            status: _title(i['status']),
            isPaid: '${i['status']}'.toLowerCase() == 'paid',
          ),
        ),
      );
    } catch (error) {
      Get.snackbar('Unable to load customers', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String _money(dynamic v) => v == null ? r'$0' : '\$$v';
  String _title(dynamic v) => (v ?? '').toString().replaceAll('_', ' ');
  String _date(dynamic v) =>
      DateTime.tryParse(
        (v ?? '').toString(),
      )?.toLocal().toString().split(' ').first ??
      'N/A';
  String _address(dynamic v) => v is Map
      ? [
          v['streetAddress'],
          v['city'],
          v['state'],
          v['postalCode'],
        ].where((e) => e != null && '$e'.isNotEmpty).join(', ')
      : (v ?? '').toString();
}
