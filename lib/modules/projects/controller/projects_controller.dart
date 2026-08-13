import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/app_colors.dart';
import '../model/projects_model.dart';
import '../repository/projects_repository.dart';

class ProjectsController extends GetxController {
  final ProjectsRepository? repository;

  ProjectsController({this.repository});

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<ProjectStatModel> projectStats = <ProjectStatModel>[].obs;
  final List<ProjectItemModel> allProjectItems = [];
  final RxList<ProjectItemModel> projectItems = <ProjectItemModel>[].obs;

  // Filter Selection States (Matching Web UI: Select Customer, Building types, All Lifecycle Statuses)
  final RxString selectedProjectFilter = 'Select Project'.obs;
  final RxString selectedCustomerFilter = 'Select Customer'.obs;
  final RxString selectedBuildingTypeFilter = 'Building types'.obs;
  final RxString selectedStatusFilter = 'All Lifecycle Statuses'.obs;

  // Dynamic Filter Options Lists
  final RxList<String> projectOptions = <String>['Select Project'].obs;
  final RxList<String> customerOptions = <String>['Select Customer'].obs;
  final RxList<String> buildingTypeOptions = <String>['Building types'].obs;
  final RxList<String> statusOptions = <String>[
    'All Lifecycle Statuses',
    'Released to Plant',
    'Drawings Received',
    'Converted To Po',
    'Drawing Rejected',
    'Approved',
  ].obs;

  final RxBool selectAllRows = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjectsData();
  }

  Future<void> loadProjectsData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (repository != null) {
        final results = await Future.wait([
          repository!.fetchProjectStats(),
          repository!.fetchProjects(limit: 50),
        ]);

        final statsData = results[0];
        final projectsData = results[1];

        // 1. Map stats
        final total = statsData?['totalProjects'] ?? projectsData?['total'] ?? 0;
        final active = statsData?['activeProjects'] ?? 0;
        final pending = statsData?['pendingCustomerApproval'] ?? 0;
        final cancelled = statsData?['cancelledProjects'] ?? 0;

        projectStats.assignAll([
          ProjectStatModel(
            title: 'Total Projects',
            count: total.toString(),
            iconData: Icons.person_add_outlined,
            backgroundColor: AppColors.totalProjectsCard,
          ),
          ProjectStatModel(
            title: 'Active Projects',
            count: active.toString(),
            iconData: Icons.check_box_outlined,
            backgroundColor: AppColors.inProductionCard,
          ),
          ProjectStatModel(
            title: 'Pending Customer Approval',
            count: pending.toString(),
            iconData: Icons.monetization_on_outlined,
            backgroundColor: AppColors.readyToDispatchCard,
          ),
          ProjectStatModel(
            title: 'Canceled Projects',
            count: cancelled.toString(),
            iconData: Icons.show_chart,
            backgroundColor: AppColors.pendingApprovalCard,
          ),
        ]);

        // 2. Map project items list
        if (projectsData != null && projectsData['projects'] is List) {
          final List list = projectsData['projects'];
          final mappedItems = list.map((item) {
            final leadId = (item['_id'] ?? item['id'] ?? item['jobId'] ?? '').toString();
            final name = (item['projectName'] ?? 'Project').toString();
            final jobIdStr = (item['jobId'] ?? item['job_id'] ?? '').toString();
            final bType = (item['buildingType'] ?? item['type'] ?? 'Workshop').toString();
            final location = (item['location'] ?? 'Texas').toString();
            
            // Subtitle should display Job ID (e.g., PRO-008) matching Web UI
            final subtitle = jobIdStr.isNotEmpty ? jobIdStr : '$bType . $location';
            
            final client = (item['clientName'] ?? item['customer']?['firstName'] ?? 'Customer').toString();
            final buildingsCount = (item['numberOfBuildings'] ?? item['buildings']?.length ?? 1).toString();
            
            // Format currency with commas e.g. $600,000
            final val = _formatCurrency(item['quoteValue']);

            // Dynamic chat / unread count from API
            final unreadMsg = item['unreadMessagesCount'] ??
                item['unreadCount'] ??
                item['chatCount'] ??
                item['messagesCount'] ??
                0;

            final statusLabel = _parseStatus(item as Map<String, dynamic>);
            ProjectStatusType statusType = ProjectStatusType.shipperFileReceived;
            if (statusLabel == 'Approved') {
              statusType = ProjectStatusType.approved;
            } else if (statusLabel == 'BOM Ready') {
              statusType = ProjectStatusType.bomReady;
            }

            return ProjectItemModel(
              id: leadId,
              projectName: name,
              projectSubtitle: subtitle,
              customerName: client,
              customerAvatarInitial: client.isNotEmpty ? client[0].toUpperCase() : 'C',
              buildingsCount: buildingsCount,
              status: statusLabel,
              statusType: statusType,
              projectValue: val,
              chatCount: unreadMsg.toString(),
            );
          }).toList();

          allProjectItems.clear();
          allProjectItems.addAll(mappedItems);

          // Build dynamic filter dropdown options
          final prjNames = {'Select Project', 'All', ...mappedItems.map((e) => e.projectName)}.toList();
          final custNames = {'Select Customer', 'All', ...mappedItems.map((e) => e.customerName)}.toList();
          final bTypes = {
            'Building types',
            'All',
            ...mappedItems.map((e) {
              final parts = e.projectSubtitle.split('.');
              return parts.isNotEmpty ? parts[0].trim() : 'Workshop';
            })
          }.toList();

          projectOptions.assignAll(prjNames);
          customerOptions.assignAll(custNames);
          buildingTypeOptions.assignAll(bTypes);

          applyFilters();
        } else {
          allProjectItems.clear();
          projectItems.clear();
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String _formatCurrency(dynamic val) {
    if (val == null) return '\$0';
    final numVal = num.tryParse(val.toString());
    if (numVal == null) return val.toString().startsWith('\$') ? val.toString() : '\$$val';
    final formatted = numVal.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '\$$formatted';
  }

  String _parseStatus(Map<String, dynamic> item) {
    final drawingStatus = (item['drawingStatus'] ?? '').toString().toLowerCase();
    if (drawingStatus == 'drawings_received' || drawingStatus == 'drawingsreceived') {
      return 'Drawings Received';
    }

    final lifecycle = (item['lifecycleStatus'] ?? '').toString().toLowerCase();
    if (lifecycle == 'released_to_plant') return 'Released to Plant';
    if (lifecycle == 'converted_to_po' || (item['status'] ?? '').toString().toLowerCase() == 'converted_to_po') {
      return 'Converted To Po';
    }

    if (drawingStatus == 'approved') return 'Approved';
    if (drawingStatus == 'rejected') return 'Drawing Rejected';
    if (drawingStatus == 'revision_sent') return 'Pending Revision';

    if (item['status'] != null && item['status'].toString().isNotEmpty) {
      return _formatStatusText(item['status'].toString());
    }

    final bomStatus = (item['bomStatus'] ?? '').toString().toLowerCase();
    if (bomStatus.contains('ready') || bomStatus.contains('complete')) {
      return 'BOM Ready';
    }

    if (lifecycle.isNotEmpty) {
      return _formatStatusText(lifecycle);
    }

    return 'Released to Plant';
  }

  String _formatStatusText(String text) {
    final lower = text.toLowerCase().trim();
    if (lower == 'approved') return 'Approved';
    if (lower == 'drawings_received') return 'Drawings Received';
    if (lower == 'converted_to_po') return 'Converted To Po';
    if (lower == 'released_to_plant') return 'Released to Plant';
    if (lower == 'bom_ready' || lower == 'bomready') return 'BOM Ready';
    if (lower == 'drawing_rejected' || lower == 'rejected') return 'Drawing Rejected';
    if (lower == 'pending_revision' || lower == 'revision_sent') return 'Pending Revision';

    final words = text.replaceAll('_', ' ').replaceAll('-', ' ').split(' ');
    return words.map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '').join(' ').trim();
  }

  void onSelectProjectFilter(String value) {
    selectedProjectFilter.value = value;
    applyFilters();
  }

  void onSelectCustomerFilter(String value) {
    selectedCustomerFilter.value = value;
    applyFilters();
  }

  void onSelectBuildingTypeFilter(String value) {
    selectedBuildingTypeFilter.value = value;
    applyFilters();
  }

  void onSelectStatusFilter(String value) {
    selectedStatusFilter.value = value;
    applyFilters();
  }

  void applyFilters() {
    List<ProjectItemModel> filtered = List.from(allProjectItems);

    // 1. Project Filter
    final prj = selectedProjectFilter.value.trim().toLowerCase();
    if (prj != 'select project' && prj != 'all') {
      filtered = filtered.where((item) {
        final pName = item.projectName.trim().toLowerCase();
        return pName == prj || pName.contains(prj) || prj.contains(pName);
      }).toList();
    }

    // 2. Customer Filter
    final cust = selectedCustomerFilter.value.trim().toLowerCase();
    if (cust != 'select customer' && cust != 'all') {
      filtered = filtered.where((item) {
        final cName = item.customerName.trim().toLowerCase();
        return cName == cust || cName.contains(cust) || cust.contains(cName);
      }).toList();
    }

    // 3. Building Type Filter
    final bType = selectedBuildingTypeFilter.value.trim().toLowerCase();
    if (bType != 'building types' && bType != 'all') {
      filtered = filtered.where((item) {
        final sub = item.projectSubtitle.trim().toLowerCase();
        return sub.contains(bType);
      }).toList();
    }

    // 4. Status Filter
    final stat = selectedStatusFilter.value.trim().toLowerCase();
    if (stat != 'all lifecycle statuses' && stat != 'select status' && stat != 'all') {
      filtered = filtered.where((item) {
        final st = item.status.trim().toLowerCase();
        return st.contains(stat) || stat.contains(st);
      }).toList();
    }

    projectItems.assignAll(filtered);
    projectItems.refresh();
    selectAllRows.value = false;
  }

  void toggleSelectAll(bool? val) {
    final newValue = val ?? false;
    selectAllRows.value = newValue;
    for (var item in projectItems) {
      item.isSelected = newValue;
    }
    projectItems.refresh();
  }

  void toggleRowSelect(int index) {
    projectItems[index].isSelected = !projectItems[index].isSelected;
    selectAllRows.value = projectItems.every((item) => item.isSelected);
    projectItems.refresh();
  }
}
