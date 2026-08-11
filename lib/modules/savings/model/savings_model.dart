class SavingsSummaryModel {
  final double totalSavingsThisMonth;
  final double totalLossThisMonth;

  SavingsSummaryModel({
    required this.totalSavingsThisMonth,
    required this.totalLossThisMonth,
  });
}

class SavingsItemModel {
  final String id;
  final String projectName;
  final double smdtCost;
  final double actualCost;
  final double savings;
  final bool isProfit;
  final double savingsPercentage;
  final String status; // 'Good' or 'Over Budget'

  SavingsItemModel({
    required this.id,
    required this.projectName,
    required this.smdtCost,
    required this.actualCost,
    required this.savings,
    required this.isProfit,
    required this.savingsPercentage,
    required this.status,
  });
}
