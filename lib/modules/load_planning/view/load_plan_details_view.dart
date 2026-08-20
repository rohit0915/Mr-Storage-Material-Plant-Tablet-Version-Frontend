import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../controller/load_planning_controller.dart';

class LoadPlanDetailsView extends GetView<LoadPlanningController> {
  const LoadPlanDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const CommonLoader();
                if (controller.errorMessage.value.isNotEmpty) {
                  return _errorState();
                }
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Navigation Header: Arrow Icon + "Load Plan"
                      InkWell(
                        onTap: Get.back,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Color(0xFF0F172A),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Load Plan',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Main Details Card
                      _detailsCard(),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 52, color: Colors.red),
        const SizedBox(height: 12),
        Text(controller.errorMessage.value, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => controller.loadProjectLoadPlans(
            controller.selectedProjectId.value,
          ),
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _detailsCard() {
    final trucks = controller.detailTruckLoads;
    final reference =
        controller.selectedLoadPlan.value?.shipperReference ??
        _text(controller.detailPlan, [
          'planNumber',
          'shipperReference',
          'reference',
        ]);
    final apiBundlePlan = controller.loadPlanningData['bundlePlan'];
    final webReference = apiBundlePlan is Map
        ? _text(Map<String, dynamic>.from(apiBundlePlan), ['planNumber'])
        : '';

    final shipperRefText = webReference.isNotEmpty
        ? webReference
        : reference.isEmpty
        ? 'N/A'
        : reference;

    final projectNameText = controller.selectedProjectName.value.isEmpty
        ? 'Project'
        : controller.selectedProjectName.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Title Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'Project: $projectNameText | Shipper Ref: $shipperRefText',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Load Summary Section
          const Text(
            'Load Summary Card',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _summaryRow('Total Bundles', '${controller.detailTotalBundles}'),
          _summaryRow('Total Loads', '${controller.detailTotalLoads}'),
          _summaryRow(
            'Total Weight',
            _weightUpper(controller.detailTotalWeight),
          ),

          const SizedBox(height: 32),

          // Truckload Summary Section
          const Text(
            'Truckload Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (trucks.isEmpty)
            _emptyState('No truckloads were returned for this load plan.')
          else ...[
            _truckSummaryTable(trucks),
            const SizedBox(height: 36),

            // Individual Truck Load Detail Tables
            ...trucks.map((truck) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Truck Load - ${_truckName(truck)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _bundleTable(truck),
                  const SizedBox(height: 36),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _truckSummaryTable(List<Map<String, dynamic>> trucks) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF262626),
                ),
                headingTextStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columnSpacing: 48,
                horizontalMargin: 20,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Load ID')),
                  DataColumn(label: Text('Truck')),
                  DataColumn(label: Text('Bundle')),
                  DataColumn(label: Text('Total Weight')),
                  DataColumn(label: Text('Ready')),
                ],
                rows: trucks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final truck = entry.value;
                  final bundles = controller.bundlesForTruck(truck);
                  final count = _number(truck, ['bundleCount', 'totalBundles']);
                  final isReady = _ready(truck);
                  final loadIdText = _text(truck, [
                    'packingListNo',
                    'loadId',
                    'packingListId',
                    'truckId',
                    'id',
                    '_id',
                  ], fallback: 'N/A');

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          loadIdText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _truckName(truck),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${count > 0 ? count : bundles.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _weightUpper(truck['totalWeight'] ?? truck['weight']),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      DataCell(_checkIcon(isReady)),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bundleTable(Map<String, dynamic> truck) {
    final bundles = controller.bundlesForTruck(truck);
    if (bundles.isEmpty) {
      return _emptyState('No bundles were returned for this truckload.');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF262626),
                ),
                headingTextStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columnSpacing: 40,
                horizontalMargin: 20,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Bundle ID')),
                  DataColumn(label: Text('Parts')),
                  DataColumn(label: Text('Weight')),
                  DataColumn(label: Text('Packing List Generated')),
                  DataColumn(label: Text('QR Labels Generated')),
                  DataColumn(label: Text('Bundles Assigned to Truck')),
                ],
                rows: bundles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bundle = entry.value;
                  final hasPackingList = _flag(bundle, [
                    'packingListGenerated',
                    'hasPackingList',
                  ]);
                  final hasQrLabels = _flag(bundle, [
                    'qrLabelsGenerated',
                    'hasQrLabels',
                  ]);
                  final isAssigned =
                      _flag(bundle, ['assignedToTruck', 'isAssigned']) ||
                      _text(bundle, [
                        'status',
                      ]).toLowerCase().contains('assigned');

                  final bundleIdText = _text(bundle, [
                    'bundleNo',
                    'bundleId',
                    'bundleNumber',
                    'reference',
                    'id',
                    '_id',
                  ], fallback: 'N/A');

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          bundleIdText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _parts(bundle),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _weightUpper(
                            bundle['totalWeight'] ?? bundle['weight'],
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      DataCell(_checkIcon(hasPackingList)),
                      DataCell(_checkIcon(hasQrLabels)),
                      DataCell(_checkIcon(isAssigned)),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _checkIcon(bool value) {
    if (value) {
      return const Icon(Icons.check, size: 18, color: Color(0xFF0F172A));
    }
    return const Text(
      '-',
      style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
    );
  }

  Widget _emptyState(String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
    ),
  );

  String _truckName(Map<String, dynamic> truck) {
    final nested = truck['truck'];
    if (nested is Map) {
      final value = _text(Map<String, dynamic>.from(nested), ['name', 'type']);
      if (value.isNotEmpty) return value;
    }
    return _text(truck, [
      'truckLabel',
      'truckType',
      'truckNo',
      'vehicleType',
      'truckName',
    ], fallback: 'Truck');
  }

  String _parts(Map<String, dynamic> bundle) {
    final value = bundle['parts'];
    if (value is List) {
      if (value.isEmpty) return '-';
      if (value.length == 1 && value.first is Map) {
        return _text(Map<String, dynamic>.from(value.first as Map), [
          'partNumber',
          'category',
          'profile',
        ], fallback: '1 part');
      }
      return '${value.length} parts';
    }
    return _text(bundle, [
      'partNumber',
      'category',
      'profile',
      'bundleType',
    ], fallback: '-');
  }

  bool _ready(Map<String, dynamic> truck) {
    if (_flag(truck, ['ready', 'isReady'])) return true;
    final status = _text(truck, ['status']).toLowerCase();
    return status.contains('ready') || status.contains('confirm');
  }

  bool _flag(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == true || value == 1) return true;
      if (value is String &&
          [
            'true',
            'yes',
            'generated',
            'complete',
          ].contains(value.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  int _number(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      final parsed = value is num ? value.toInt() : int.tryParse('$value');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  String _text(
    Map<String, dynamic> map,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  String _weightUpper(dynamic value) {
    if (value == null || value.toString().isEmpty) return '0 LBS';
    final text = value.toString();
    if (text.toUpperCase().contains('LBS') ||
        text.toUpperCase().contains('LB')) {
      return text.toUpperCase();
    }
    return '$text LBS';
  }
}
