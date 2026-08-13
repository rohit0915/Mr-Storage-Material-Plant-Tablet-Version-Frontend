import 'package:get/get.dart';
import '../model/project_details_model.dart';
import '../repository/project_details_repository.dart';

class ProjectDetailsController extends GetxController {
  final ProjectDetailsRepository? repository;

  ProjectDetailsController({this.repository});

  final RxBool isLoading = true.obs;
  final RxBool isUpdatingLifecycle = false.obs;
  final RxBool isAddingNote = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt currentStepIndex = 1.obs; // Step 2 (0-indexed 1)

  // Reactive Header & Summary Card Attributes
  final RxString projectName = ''.obs;
  final RxString jobId = ''.obs;
  final RxString poNumber = ''.obs;
  final RxString projectSubtitle = ''.obs;
  final RxString projectStatus = ''.obs;
  final RxString buildingType = ''.obs;
  final RxString numberOfBuildings = '1'.obs;
  final RxString quoteValue = ''.obs;
  final RxString createdOn = ''.obs;
  final RxString location = ''.obs;

  // Contact Information
  final RxString customerName = ''.obs;
  final RxString customerPhone = ''.obs;
  final RxString customerEmail = ''.obs;
  final RxString customerAddress = ''.obs;

  // Assignment & Contract Info
  final RxString salesPerson = ''.obs;
  final RxString signedContractDate = ''.obs;

  // Active Step Details
  final RxString activeStepTitle = ''.obs;
  final RxString activeStepDesc = ''.obs;
  final RxString plannedStartDate = ''.obs;
  final RxString targetCompletionDate = ''.obs;
  final RxString assignedPlanner = ''.obs;
  final RxString activeStepPriority = 'Medium'.obs;
  final RxString nextStepTitle = ''.obs;

  // Lists
  final RxList<LifecycleStepModel> lifecycleSteps = <LifecycleStepModel>[].obs;
  final RxList<InvoiceItemModel> invoices = <InvoiceItemModel>[].obs;
  final RxList<ActivityTimelineItemModel> activities =
      <ActivityTimelineItemModel>[].obs;
  final RxList<String> notes = <String>[].obs;

  final RxString selectedUploadedFile = ''.obs;
  final RxString uploadedFileSize = ''.obs;

  String projectId = '';

  @override
  void onInit() {
    super.onInit();
    if (Get.parameters.containsKey('id') && Get.parameters['id'] != null) {
      projectId = Get.parameters['id']!;
    } else if (Get.arguments != null && Get.arguments is String) {
      projectId = Get.arguments as String;
    }
    loadProjectDetails();
  }

  Future<void> loadProjectDetails() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (repository == null || projectId.isEmpty) {
        errorMessage.value = 'Project id is missing.';
        _loadDefaultData();
        return;
      }

      // The detail request is the source of truth for the page. Do not discard a
      // valid detail response when an optional section endpoint fails.
      final detailData = await repository!.fetchProjectDetail(projectId);
      if (detailData == null) {
        errorMessage.value = 'Project details were not found.';
        _loadDefaultData();
        return;
      }

      final leadObj = _asStringMap(detailData['lead']);
      final clientObj = _asStringMap(
        detailData['client'] ??
            detailData['customer'] ??
            leadObj['customerId'] ??
            leadObj['customer'],
      );

      final pName =
          (detailData['projectName'] ?? leadObj['projectName'] ?? 'Project')
              .toString();
      final jId =
          (detailData['jobId'] ??
                  leadObj['jobId'] ??
                  detailData['projectId'] ??
                  detailData['_id'] ??
                  '')
              .toString();

      final poObj = detailData['poOrder'] ?? leadObj['poOrder'];
      final poNum =
          (detailData['poNumber'] ??
                  (poObj is Map ? poObj['poNumber'] : null) ??
                  leadObj['poNumber'] ??
                  '')
              .toString();

      final cFirst = (clientObj['firstName'] ?? '').toString();
      final cLast = (clientObj['lastName'] ?? '').toString();
      final cNameRaw =
          (clientObj['name'] ??
                  detailData['clientName'] ??
                  (cFirst.isNotEmpty ? '$cFirst $cLast'.trim() : 'Customer'))
              .toString();

      projectName.value = pName;
      jobId.value = jId;
      poNumber.value = poNum;
      projectSubtitle.value = jId.isNotEmpty ? '$jId | $cNameRaw' : cNameRaw;

      final rawStatus =
          (detailData['lifecycleStatus'] ??
                  detailData['drawingStatus'] ??
                  detailData['status'] ??
                  leadObj['lifecycleStatus'] ??
                  'pending')
              .toString();
      projectStatus.value = _formatStatusText(rawStatus);

      buildingType.value =
          (detailData['buildingType'] ??
                  leadObj['buildingType'] ??
                  detailData['type'] ??
                  'N/A')
              .toString();
      numberOfBuildings.value =
          (detailData['numberOfBuildings'] ??
                  leadObj['numberOfBuildings'] ??
                  detailData['buildings']?.length ??
                  1)
              .toString();

      final qVal = detailData['quoteValue'] ?? leadObj['quoteValue'];
      quoteValue.value = _formatCurrency(qVal);

      createdOn.value = _formatDate(
        (detailData['createdAt'] ??
                detailData['createdOn'] ??
                leadObj['createdAt'])
            ?.toString(),
      );
      location.value =
          (detailData['location'] ??
                  leadObj['location'] ??
                  detailData['address'] ??
                  'N/A')
              .toString();

      // Contact Information
      customerName.value = cNameRaw;
      customerPhone.value = _parsePhone(clientObj['phone'] ?? leadObj['phone']);
      customerEmail.value = (clientObj['email'] ?? leadObj['email'] ?? 'N/A')
          .toString();
      customerAddress.value = (clientObj['address'] ?? location.value)
          .toString();

      // Assignment & Contract Info
      salesPerson.value = _parseSalesPerson(detailData, leadObj);

      final agreement = _asStringMap(detailData['agreement']);
      final signedRaw =
          (agreement['createdAt'] ??
                  detailData['signedContractDate'] ??
                  detailData['contractDate'])
              ?.toString();
      signedContractDate.value =
          (signedRaw != null && signedRaw != 'null' && signedRaw.isNotEmpty)
          ? _formatDate(signedRaw)
          : 'N/A';

      final actList = detailData['activityLog'] ?? leadObj['activityLog'];
      if (actList is List && actList.isNotEmpty) {
        final mappedActivities = actList.map((a) {
          final rawMsg = (a['displayMessage'] ?? a['message'] ?? a['title'] ?? '').toString();
          final rawAction = (a['action'] ?? '').toString();
          final titleStr = rawMsg.isNotEmpty ? rawMsg : _formatActionName(rawAction);

          String performer = '';
          if (a['performedBy'] != null) {
            if (a['performedBy'] is Map) {
              performer = (a['performedBy']['name'] ?? a['performedBy']['email'] ?? '').toString();
            } else if (a['performedBy'] is String) {
              performer = a['performedBy'].toString();
            }
          }

          final subtitleStr = performer.isNotEmpty ? 'by $performer' : _formatActionName(rawAction);

          return ActivityTimelineItemModel(
            title: titleStr,
            subtitle: subtitleStr,
            date: _formatDate(
              a['createdAt']?.toString() ?? a['date']?.toString(),
            ),
          );
        }).toList();
        activities.assignAll(mappedActivities);
      } else {
        _loadDefaultActivities();
      }

      final optionalResults = await Future.wait<dynamic>([
        _withoutFailure(repository!.fetchLifecycle(projectId)),
        _withoutFailure(repository!.fetchInvoices(projectId)),
        _withoutFailure(repository!.fetchNotes(projectId)),
      ]);
      final lifecycleData = optionalResults[0] as Map<String, dynamic>?;
      final invoicesData = optionalResults[1] as List<dynamic>?;
      final notesData = optionalResults[2] as List<dynamic>?;

      final historyList =
          detailData['lifecycleHistory'] ??
          leadObj['lifecycleHistory'] ??
          lifecycleData?['steps'] ??
          lifecycleData?['history'];
      _buildLifecycleStepsFromHistory(
        rawStatus,
        historyList is List ? historyList : null,
      );

      // 3. Map Invoices
      if (invoicesData != null && invoicesData.isNotEmpty) {
        final mappedInvoices = invoicesData.whereType<Map>().map((inv) {
          return InvoiceItemModel(
            invoiceNumber: (inv['number'] ?? inv['invoiceNumber'] ?? 'INV001')
                .toString(),
            dueDate: _formatDate(
              (inv['dueDate'] ?? inv['createdAt'])?.toString(),
            ),
            amount: _formatCurrency(inv['amount']),
            paid: _formatCurrency(inv['paid'] ?? inv['amountPaid']),
            amountDue: _formatCurrency(inv['dueAmount'] ?? inv['amountDue']),
            isPaid: (inv['status'] ?? '').toString().toLowerCase() == 'paid',
          );
        }).toList();
        invoices.assignAll(mappedInvoices);
      } else {
        invoices.clear();
      }

      // 4. Map Notes
      final leadNotes = detailData['leadNotes'] ?? notesData;
      if (leadNotes is List && leadNotes.isNotEmpty) {
        final mappedNotes = leadNotes.map((n) {
          if (n is String) return n;
          if (n is Map && n['note'] != null) return n['note'].toString();
          if (n is Map && n['text'] != null) return n['text'].toString();
          return n.toString();
        }).toList();
        notes.assignAll(mappedNotes);
      } else {
        notes.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      _loadDefaultData();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _asStringMap(dynamic value) {
    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  Future<T?> _withoutFailure<T>(Future<T?> request) async {
    try {
      return await request;
    } catch (e) {
      if (errorMessage.value.isEmpty) errorMessage.value = e.toString();
      return null;
    }
  }

  void _buildLifecycleStepsFromHistory(String currentStageRaw, List? history) {
    final defaultStageTitles = [
      {'key': 'released_to_plant', 'title': 'Released To Plant'},
      {'key': 'drawings_received', 'title': 'Drawings Received'},
      {'key': 'bom_received', 'title': 'Bom Received'},
      {'key': 'bom_review', 'title': 'Bom Review'},
      {'key': 'material_check', 'title': 'Material Check'},
      {'key': 'production_planning', 'title': 'Production Planning'},
      {'key': 'fabrication_started', 'title': 'Fabrication Started'},
      {'key': 'quality_inspection', 'title': 'Quality Inspection'},
      {'key': 'packing_bundling', 'title': 'Packing Bundling'},
      {'key': 'shipper_prepared', 'title': 'Shipper Prepared'},
      {'key': 'ready_for_delivery', 'title': 'Ready For Delivery'},
      {'key': 'dispatched', 'title': 'Dispatched'},
      {'key': 'delivered', 'title': 'Delivered'},
    ];

    Map<String, String> datesByStage = {};
    if (history != null) {
      for (var item in history) {
        if (item is Map) {
          final stage = (item['stage'] ?? '').toString().toLowerCase();
          final dateStr = _formatDate(
            item['changedAt']?.toString() ?? item['createdAt']?.toString(),
          );
          if (stage.isNotEmpty && dateStr != 'N/A') {
            datesByStage[stage] = dateStr;
          }
        }
      }
    }

    final lowerCurrent = currentStageRaw.toLowerCase();
    int currentIdx = defaultStageTitles.indexWhere(
      (s) => s['key'] == lowerCurrent,
    );
    if (currentIdx == -1) {
      currentIdx = 1; // Default to Drawings Received (Step 2)
    }

    currentStepIndex.value = currentIdx;

    final steps = List.generate(defaultStageTitles.length, (i) {
      final key = defaultStageTitles[i]['key']!;
      final title = defaultStageTitles[i]['title']!;
      final date = datesByStage[key] ?? (i <= currentIdx ? '12/08/26' : '');
      final isCompleted = i < currentIdx;
      final isCurrent = i == currentIdx;

      return LifecycleStepModel(
        stepNumber: i + 1,
        title: title,
        date: date,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
      );
    });

    lifecycleSteps.assignAll(steps);
    _updateActiveStepDetails(steps[currentIdx], currentIdx);
  }

  String _parsePhone(dynamic phoneVal) {
    if (phoneVal == null) return 'N/A';
    if (phoneVal is Map) {
      final code = (phoneVal['countryCode'] ?? '').toString();
      final num = (phoneVal['number'] ?? '').toString();
      final full = '$code$num'.trim();
      return full.isNotEmpty ? full : 'N/A';
    }
    final str = phoneVal.toString().trim();
    return str.isNotEmpty ? str : 'N/A';
  }

  String _parseSalesPerson(
    Map<String, dynamic> detailData,
    Map<String, dynamic> leadObj,
  ) {
    final assignedSales =
        detailData['assignedSales'] ?? leadObj['assignedSales'];
    if (assignedSales != null) {
      if (assignedSales is Map) {
        final name = (assignedSales['name'] ?? assignedSales['email'] ?? '')
            .toString();
        if (name.isNotEmpty) return name;
      } else if (assignedSales.toString().isNotEmpty) {
        return assignedSales.toString();
      }
    }
    if (detailData['salesPerson'] != null &&
        detailData['salesPerson'].toString().isNotEmpty) {
      return detailData['salesPerson'].toString();
    }
    return 'N/A';
  }

  String _formatCurrency(dynamic val) {
    if (val == null) return '\$0';
    final numVal = num.tryParse(val.toString());
    if (numVal == null) {
      return val.toString().startsWith('\$') ? val.toString() : '\$$val';
    }
    final formatted = numVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$$formatted';
  }

  void _updateActiveStepDetails(LifecycleStepModel step, int index) {
    activeStepTitle.value =
        '${step.title} (Step ${index + 1} of ${lifecycleSteps.length})';
    activeStepDesc.value =
        'Plan Production Schedule, assign resources and determine fabrication priority for this project.';
    plannedStartDate.value = step.date.isNotEmpty ? step.date : '12/08/26';
    targetCompletionDate.value = step.date.isNotEmpty ? step.date : '12/08/26';
    assignedPlanner.value =
        salesPerson.value.isNotEmpty && salesPerson.value != 'N/A'
        ? salesPerson.value
        : 'Plant Admin';

    if (index < lifecycleSteps.length - 1) {
      nextStepTitle.value = lifecycleSteps[index + 1].title;
    } else {
      nextStepTitle.value = 'Completed';
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty || isoString == 'null') {
      return 'N/A';
    }
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final yearShort = dt.year.toString().substring(2);
      return '$day/$month/$yearShort';
    } catch (_) {
      return isoString;
    }
  }

  String _formatStatusText(String text) {
    final lower = text.toLowerCase().trim();
    if (lower == 'drawings_received' || lower == 'drawingsreceived') {
      return 'Drawings_received';
    }
    if (lower == 'in_progress') return 'In Progress';
    if (lower == 'approved') return 'Approved';
    if (lower == 'bom_ready') return 'BOM Ready';
    if (lower == 'released_to_plant') return 'Released to Plant';

    final words = text.replaceAll('_', ' ').replaceAll('-', ' ').split(' ');
    return words
        .map(
          (w) => w.isNotEmpty
              ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ')
        .trim();
  }

  String _formatActionName(String action) {
    if (action.isEmpty) return 'Activity';
    final clean = action.replaceAll('_', ' ').replaceAll('.', ' • ');
    final words = clean.split(' ');
    return words
        .map(
          (w) => w.isNotEmpty
              ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ')
        .trim();
  }

  void _loadDefaultData() {
    _loadDefaultLifecycleSteps();
    _loadDefaultInvoices();
    _loadDefaultActivities();
    _loadDefaultNotes();
  }

  void _loadDefaultLifecycleSteps() {
    _buildLifecycleStepsFromHistory('drawings_received', null);
  }

  void _loadDefaultInvoices() {
    invoices.assignAll([
      InvoiceItemModel(
        invoiceNumber: 'INV001',
        dueDate: '24/12/24',
        amount: '\$500',
        paid: '\$500',
        amountDue: '\$500',
        isPaid: true,
      ),
      InvoiceItemModel(
        invoiceNumber: 'INV002',
        dueDate: '10/12/24',
        amount: '\$1500',
        paid: '\$1500',
        amountDue: '\$1500',
        isPaid: true,
      ),
    ]);
  }

  void _loadDefaultActivities() {
    activities.assignAll([
      ActivityTimelineItemModel(
        title: 'Note added for Another Project',
        subtitle: 'lead.note_added',
        date: '13/08/26',
      ),
    ]);
  }

  void _loadDefaultNotes() {
    notes.assignAll(['Reliable for long-distance steel transport.']);
  }

  void selectStep(int index) {
    currentStepIndex.value = index;
    if (index >= 0 && index < lifecycleSteps.length) {
      _updateActiveStepDetails(lifecycleSteps[index], index);
    }
  }

  Future<bool> updateStepStatus(int newIndex, {String? note}) async {
    const stageKeys = [
      'released_to_plant',
      'drawings_received',
      'bom_received',
      'bom_review',
      'material_check',
      'production_planning',
      'fabrication_started',
      'quality_inspection',
      'packing_bundling',
      'shipper_prepared',
      'ready_for_delivery',
      'dispatched',
      'delivered',
    ];
    if (repository == null ||
        projectId.isEmpty ||
        newIndex < 0 ||
        newIndex >= stageKeys.length) {
      errorMessage.value = 'Unable to update this project step.';
      return false;
    }

    isUpdatingLifecycle.value = true;
    errorMessage.value = '';
    try {
      await repository!.updateLifecycle(
        leadId: projectId,
        lifecycleStatus: stageKeys[newIndex],
        note: note,
      );
      if (note != null && note.trim().isNotEmpty) {
        notes.insert(0, note.trim());
      }
      await loadProjectDetails();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isUpdatingLifecycle.value = false;
    }
  }

  Future<bool> addNewNote(String title, String content) async {
    final trimmedContent = content.trim();
    if (repository == null || projectId.isEmpty || trimmedContent.isEmpty) {
      errorMessage.value = trimmedContent.isEmpty
          ? 'Please enter a note.'
          : 'Project id is missing.';
      return false;
    }

    isAddingNote.value = true;
    errorMessage.value = '';
    try {
      final note = title.trim().isEmpty
          ? trimmedContent
          : '${title.trim()}: $trimmedContent';
      await repository!.addNote(leadId: projectId, note: note);
      await loadProjectDetails();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isAddingNote.value = false;
    }
  }
}
