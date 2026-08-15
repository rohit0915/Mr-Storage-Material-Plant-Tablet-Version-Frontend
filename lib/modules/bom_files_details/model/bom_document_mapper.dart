import 'bom_files_details_model.dart';

class BomDocumentMapper {
  BomDocumentMapper._();

  static BomDocumentModel fromApi({
    required String projectId,
    required Map<String, dynamic> response,
  }) {
    final project = _map(response['projectDetail']);
    final lead = _map(project['lead']).isNotEmpty
        ? _map(project['lead'])
        : project;
    final consolidatedResponse = _map(response['consolidatedBom']);
    final consolidated =
        _map(consolidatedResponse['consolidatedBOM']).isNotEmpty
        ? _map(consolidatedResponse['consolidatedBOM'])
        : consolidatedResponse;
    final buildingData = _map(response['bomFiles']);

    final client = _firstNonEmptyMap([
      project['client'],
      project['customer'],
      lead['customerId'],
      lead['customer'],
    ]);

    final rawItems = <Map<String, dynamic>>[];
    final grouped = consolidated['groupedItems'] ?? consolidated['items'];
    _appendItems(rawItems, grouped);
    if (rawItems.isEmpty) {
      final buildings = buildingData['buildings'] ?? response['buildings'];
      if (buildings is List) {
        for (final rawBuilding in buildings.whereType<Map>()) {
          final building = Map<String, dynamic>.from(rawBuilding);
          final bom = _map(building['bom']).isNotEmpty
              ? _map(building['bom'])
              : building;
          _appendItems(rawItems, bom['items'] ?? bom['groupedItems']);
        }
      }
    }

    final items = rawItems.map(_item).toList();
    if (items.isEmpty) {
      throw const FormatException(
        'The consolidated BOM does not contain any items.',
      );
    }

    final calculatedWeight = rawItems.fold<double>(
      0,
      (sum, item) => sum + _double(item['weight'] ?? item['totalWeight']),
    );
    final calculatedCost = rawItems.fold<double>(
      0,
      (sum, item) =>
          sum +
          _double(item['totalCost'] ?? item['amount'] ?? item['totalPrice']),
    );
    final totalWeight = _double(
      consolidated['totalWeight'] ?? response['totalWeight'],
    );
    final totalPanelsArea = _double(
      consolidated['totalPanelsArea'] ?? response['totalPanelsArea'],
    );
    final totalCost = _double(
      consolidated['totalCost'] ?? response['totalCost'],
    );
    final customerName = _customerName(client, project, lead);
    final generatedDate =
        consolidated['generatedAt'] ??
        consolidated['updatedAt'] ??
        project['updatedAt'] ??
        project['createdAt'] ??
        lead['createdAt'];
    final sentRaw = consolidated['sentToVendors'];
    final sentToVendors = sentRaw is List
        ? sentRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : <Map<String, dynamic>>[];

    return BomDocumentModel(
      projectId: projectId,
      projectName: _text(
        project['projectName'] ?? lead['projectName'],
        'Project',
      ),
      bomId: _text(
        consolidated['_id'] ?? consolidated['bomId'] ?? buildingData['bomId'],
        'BOM',
      ),
      date: _date(generatedDate),
      jobId: _text(project['jobId'] ?? lead['jobId'] ?? lead['job_id'], '-'),
      customerName: customerName,
      sourceFileUrl: _text(
        consolidated['fileUrl'] ??
            consolidated['excelFileUrl'] ??
            consolidated['downloadUrl'],
        '',
      ),
      summary: BomSummaryModel(
        totalItems: _int(consolidated['totalItems'] ?? items.length),
        totalWeight:
            '${_compact(totalWeight > 0 ? totalWeight : calculatedWeight)} lbs',
        totalPanelsArea: '${_compact(totalPanelsArea)} sq ft',
        totalCost: '\$${_money(totalCost > 0 ? totalCost : calculatedCost)}',
      ),
      missingSummary: MissingItemCostSummaryModel(
        totalAmount: 0,
        missingItemQty: items.where((item) => item.isMissing).length,
      ),
      items: items,
      sentToVendors: sentToVendors,
    );
  }

  static BomItemModel _item(Map<String, dynamic> item) {
    final rawCost =
        item['totalCost'] ??
        item['amount'] ??
        item['totalPrice'] ??
        item['price'];
    final missing = rawCost == null || '$rawCost'.trim().isEmpty;
    return BomItemModel(
      category: _text(
        item['category'] ?? item['group'] ?? item['section'],
        '-',
      ),
      qty: _int(item['qty'] ?? item['quantity']),
      mark: _text(item['mark'] ?? item['itemCode'], '-'),
      description: _text(item['description'] ?? item['name'], '-'),
      part: _text(item['partCode'] ?? item['part'] ?? item['partNumber'], '-'),
      color: _text(item['color'], '-'),
      angle: _text(item['angle'], '-'),
      thick: _text(item['thick'] ?? item['thickness'], '-'),
      length: _text(item['length'], '0'),
      weight: _compact(_double(item['weight'] ?? item['totalWeight'])),
      amount: missing ? 'Missing' : '\$${_money(_double(rawCost))}',
      isMissing: missing,
      isFrame:
          item['isFrame'] == true ||
          _text(item['category'], '').toLowerCase().contains('frame'),
      isMatched:
          item['isMatched'] == true ||
          _text(item['matchStatus'] ?? item['status'], '').toLowerCase() ==
              'matched',
    );
  }

  static void _appendItems(List<Map<String, dynamic>> target, dynamic source) {
    if (source is List) {
      target.addAll(
        source.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );
    } else if (source is Map) {
      for (final value in source.values) {
        _appendItems(target, value);
      }
    }
  }

  static Map<String, dynamic> _firstNonEmptyMap(List<dynamic> values) {
    for (final value in values) {
      final result = _map(value);
      if (result.isNotEmpty) return result;
    }
    return {};
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  static double _double(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  static String _text(dynamic value, String fallback) {
    final result = (value ?? '').toString().trim();
    return result.isEmpty ? fallback : result;
  }

  static String _customerName(
    Map<String, dynamic> client,
    Map<String, dynamic> project,
    Map<String, dynamic> lead,
  ) {
    final first = _text(client['firstName'], '');
    final last = _text(client['lastName'], '');
    return _text(
      client['name'] ??
          (first.isNotEmpty ? '$first $last'.trim() : null) ??
          project['clientName'] ??
          lead['clientName'],
      '-',
    );
  }

  static String _date(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString())?.toLocal();
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _compact(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static String _money(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '$whole.${parts.last}';
  }
}
