class BomSummaryModel {
  final int totalItems;
  final String totalWeight;
  final String totalPanelsArea;
  final String? totalCost;

  BomSummaryModel({
    required this.totalItems,
    required this.totalWeight,
    required this.totalPanelsArea,
    this.totalCost,
  });
}

class MissingItemCostSummaryModel {
  final double totalAmount;
  final int missingItemQty;

  MissingItemCostSummaryModel({
    required this.totalAmount,
    required this.missingItemQty,
  });
}

class BomItemModel {
  final String category;
  final int qty;
  final String mark;
  final String description;
  final String part;
  final String color;
  final String angle;
  final String thick;
  final String length;
  final String weight;
  final String amount;
  final bool isMissing;
  final bool isFrame;
  final bool isMatched;

  BomItemModel({
    required this.category,
    required this.qty,
    required this.mark,
    required this.description,
    required this.part,
    required this.color,
    required this.angle,
    required this.thick,
    required this.length,
    required this.weight,
    required this.amount,
    this.isMissing = false,
    this.isFrame = false,
    this.isMatched = false,
  });
}

class BomDocumentModel {
  final String projectId;
  final String projectName;
  final String bomId;
  final String date;
  final String jobId;
  final String customerName;
  final String sourceFileUrl;
  final BomSummaryModel summary;
  final MissingItemCostSummaryModel missingSummary;
  final List<BomItemModel> items;
  final List<Map<String, dynamic>> sentToVendors;

  const BomDocumentModel({
    required this.projectId,
    required this.projectName,
    required this.bomId,
    required this.date,
    required this.jobId,
    required this.customerName,
    required this.sourceFileUrl,
    required this.summary,
    required this.missingSummary,
    required this.items,
    required this.sentToVendors,
  });
}
