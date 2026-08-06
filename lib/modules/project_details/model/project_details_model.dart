class LifecycleStepModel {
  final int stepNumber;
  final String title;
  final String date;
  final bool isCompleted;
  final bool isCurrent;

  LifecycleStepModel({
    required this.stepNumber,
    required this.title,
    required this.date,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class InvoiceItemModel {
  final String invoiceNumber;
  final String dueDate;
  final String amount;
  final String paid;
  final String amountDue;
  final bool isPaid;

  InvoiceItemModel({
    required this.invoiceNumber,
    required this.dueDate,
    required this.amount,
    required this.paid,
    required this.amountDue,
    required this.isPaid,
  });
}

class ActivityTimelineItemModel {
  final String title;
  final String subtitle;
  final String date;

  ActivityTimelineItemModel({
    required this.title,
    required this.subtitle,
    required this.date,
  });
}
