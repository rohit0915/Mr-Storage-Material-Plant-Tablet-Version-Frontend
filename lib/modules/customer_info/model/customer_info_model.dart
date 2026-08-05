import 'package:flutter/material.dart';

class CustomerProfileModel {
  final String name;
  final String id;
  final String joinedDate;
  final bool isActive;
  final String phone;
  final String email;
  final String address;

  CustomerProfileModel({
    required this.name,
    required this.id,
    required this.joinedDate,
    required this.isActive,
    required this.phone,
    required this.email,
    required this.address,
  });
}

class CustomerStatModel {
  final String title;
  final String count;
  final IconData iconData;
  final Color backgroundColor;

  CustomerStatModel({
    required this.title,
    required this.count,
    required this.iconData,
    required this.backgroundColor,
  });
}

class CustomerProjectModel {
  final String projectCode;
  final String projectName;
  final String amount;
  final String status;
  final String startDate;
  final String endDate;
  final bool isCompleted;

  CustomerProjectModel({
    required this.projectCode,
    required this.projectName,
    required this.amount,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.isCompleted,
  });
}

class CustomerInvoiceModel {
  final String invoiceNumber;
  final String dueDate;
  final String amount;
  final String paid;
  final String amountDue;
  final String status;
  final bool isPaid;

  CustomerInvoiceModel({
    required this.invoiceNumber,
    required this.dueDate,
    required this.amount,
    required this.paid,
    required this.amountDue,
    required this.status,
    required this.isPaid,
  });
}
