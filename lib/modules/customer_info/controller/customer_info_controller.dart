import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../model/customer_info_model.dart';

class CustomerInfoController extends GetxController {
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

  void loadCustomerInfo() {
    isLoading.value = true;

    profile.value = CustomerProfileModel(
      name: 'John Doe',
      id: 'ID-2025-1047',
      joinedDate: 'Joined January 15, 2023',
      isActive: true,
      phone: '(163) 2459 315',
      email: 'darlee@example.com',
      address: '1861 Bayonne Ave, Manchester, NJ, 08759',
    );

    stats.assignAll([
      CustomerStatModel(
        title: 'Total Projects',
        count: '04',
        iconData: Icons.build_outlined,
        backgroundColor: AppColors.totalProjectsCard,
      ),
      CustomerStatModel(
        title: 'Completed',
        count: '3',
        iconData: Icons.verified_user_outlined,
        backgroundColor: AppColors.inProductionCard,
      ),
      CustomerStatModel(
        title: 'Work in progress',
        count: '1',
        iconData: Icons.monetization_on_outlined,
        backgroundColor: AppColors.readyToDispatchCard,
      ),
      CustomerStatModel(
        title: 'Canceled',
        count: '1',
        iconData: Icons.show_chart,
        backgroundColor: AppColors.pendingApprovalCard,
      ),
    ]);

    projects.assignAll([
      CustomerProjectModel(
        projectCode: 'Project 1',
        projectName: 'ABC Building',
        amount: '\$5,0000',
        status: 'Completed',
        startDate: 'Apr 02, 2024',
        endDate: 'May 02, 2024',
        isCompleted: true,
      ),
      CustomerProjectModel(
        projectCode: 'Project 2',
        projectName: 'XYZ Building',
        amount: '\$5,0000',
        status: 'Completed',
        startDate: 'Apr 02, 2024',
        endDate: 'May 02, 2024',
        isCompleted: true,
      ),
      CustomerProjectModel(
        projectCode: 'Project 3',
        projectName: 'PQR Building',
        amount: '\$5,0000',
        status: 'In progress',
        startDate: 'Apr 02, 2024',
        endDate: 'May 02, 2024',
        isCompleted: false,
      ),
    ]);

    invoices.assignAll([
      CustomerInvoiceModel(
        invoiceNumber: 'INV001',
        dueDate: '24 Dec 2024',
        amount: '\$500',
        paid: '\$500',
        amountDue: '\$500',
        status: 'Paid',
        isPaid: true,
      ),
      CustomerInvoiceModel(
        invoiceNumber: 'INV002',
        dueDate: '10 Dec 2024',
        amount: '\$1500',
        paid: '\$1500',
        amountDue: '\$1500',
        status: 'Paid',
        isPaid: true,
      ),
      CustomerInvoiceModel(
        invoiceNumber: 'INV003',
        dueDate: '27 Nov 2024',
        amount: '\$600',
        paid: '\$600',
        amountDue: '\$600',
        status: 'Paid',
        isPaid: true,
      ),
      CustomerInvoiceModel(
        invoiceNumber: 'INV004',
        dueDate: '18 Nov 2024',
        amount: '\$1000',
        paid: '\$1000',
        amountDue: '\$1000',
        status: 'Unpaid',
        isPaid: false,
      ),
    ]);

    isLoading.value = false;
  }
}
