import 'package:get/get.dart';
import '../model/project_details_model.dart';

class ProjectDetailsController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxInt currentStepIndex = 6.obs; // Step 7 (0-indexed 6)

  final RxList<LifecycleStepModel> lifecycleSteps = <LifecycleStepModel>[].obs;
  final RxList<InvoiceItemModel> invoices = <InvoiceItemModel>[].obs;
  final RxList<ActivityTimelineItemModel> activities = <ActivityTimelineItemModel>[].obs;
  final RxList<String> notes = <String>[].obs;

  final RxString selectedUploadedFile = 'Building ABC -1 Drawing'.obs;
  final RxString uploadedFileSize = '5.3MB'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjectDetails();
  }

  void loadProjectDetails() {
    isLoading.value = true;

    lifecycleSteps.assignAll([
      LifecycleStepModel(stepNumber: 1, title: 'Released to plant', date: '24-10-10', isCompleted: true),
      LifecycleStepModel(stepNumber: 2, title: 'Drawings Received', date: '24-10-10', isCompleted: true),
      LifecycleStepModel(stepNumber: 3, title: 'BOM Received', date: '24-10-10', isCompleted: true),
      LifecycleStepModel(stepNumber: 4, title: 'BOM Review', date: '24-10-10', isCompleted: true),
      LifecycleStepModel(stepNumber: 5, title: 'Material Check', date: '24-10-10', isCompleted: true),
      LifecycleStepModel(stepNumber: 6, title: 'Material Request', date: '24-10-10', isCompleted: true),
      LifecycleStepModel(stepNumber: 7, title: 'Production Planning', date: 'Current Step', isCurrent: true),
      LifecycleStepModel(stepNumber: 8, title: 'Fabrication Started', date: ''),
      LifecycleStepModel(stepNumber: 9, title: 'Quality Inspection', date: ''),
      LifecycleStepModel(stepNumber: 10, title: 'Packing Bundling', date: ''),
      LifecycleStepModel(stepNumber: 11, title: 'Shipper Prepared', date: ''),
      LifecycleStepModel(stepNumber: 12, title: 'Ready For Delivery', date: ''),
      LifecycleStepModel(stepNumber: 13, title: 'Dispatched', date: ''),
      LifecycleStepModel(stepNumber: 14, title: 'Delivered', date: ''),
    ]);

    invoices.assignAll([
      InvoiceItemModel(invoiceNumber: 'INV001', dueDate: '24 Dec 2024', amount: '\$500', paid: '\$500', amountDue: '\$500', isPaid: true),
      InvoiceItemModel(invoiceNumber: 'INV002', dueDate: '10 Dec 2024', amount: '\$1500', paid: '\$1500', amountDue: '\$1500', isPaid: true),
      InvoiceItemModel(invoiceNumber: 'INV003', dueDate: '27 Nov 2024', amount: '\$900', paid: '\$900', amountDue: '\$900', isPaid: true),
      InvoiceItemModel(invoiceNumber: 'INV004', dueDate: '19 Nov 2024', amount: '\$1000', paid: '\$1000', amountDue: '\$1000', isPaid: false),
    ]);

    activities.assignAll([
      ActivityTimelineItemModel(title: 'Building A', subtitle: 'Step updated; material request completed', date: '19 Jan 2025'),
      ActivityTimelineItemModel(title: 'Building B', subtitle: 'Additional material request #AMR-0010 created', date: '18 Jan 2025'),
      ActivityTimelineItemModel(title: 'Building C', subtitle: 'Material Check Completed', date: '18 Jan 2025'),
      ActivityTimelineItemModel(title: 'Building B', subtitle: 'BOM Review completed', date: '17 Jan 2025'),
      ActivityTimelineItemModel(title: '2 unread messages', subtitle: '', date: '17 Jan 2025'),
    ]);

    notes.assignAll([
      'Reliable for long-distance steel transport. Preferred carrier for Texas routes. Fast response time during bidding.',
      'Reliable for long-distance steel transport. Preferred carrier for Texas routes. Fast response time during bidding.',
      'Reliable for long-distance steel transport. Preferred carrier for Texas routes. Fast response time during bidding.',
      'Reliable for long-distance steel transport. Preferred carrier for Texas routes. Fast response time during bidding.',
      'Reliable for long-distance steel transport. Preferred carrier for Texas routes. Fast response time during bidding.',
    ]);

    isLoading.value = false;
  }

  void selectStep(int index) {
    currentStepIndex.value = index;
  }

  void updateStepStatus(int newIndex) {
    currentStepIndex.value = newIndex;
    for (int i = 0; i < lifecycleSteps.length; i++) {
      final step = lifecycleSteps[i];
      if (i < newIndex) {
        lifecycleSteps[i] = LifecycleStepModel(
          stepNumber: step.stepNumber,
          title: step.title,
          date: '24-10-10',
          isCompleted: true,
          isCurrent: false,
        );
      } else if (i == newIndex) {
        lifecycleSteps[i] = LifecycleStepModel(
          stepNumber: step.stepNumber,
          title: step.title,
          date: 'Current Step',
          isCompleted: false,
          isCurrent: true,
        );
      } else {
        lifecycleSteps[i] = LifecycleStepModel(
          stepNumber: step.stepNumber,
          title: step.title,
          date: '',
          isCompleted: false,
          isCurrent: false,
        );
      }
    }
    lifecycleSteps.refresh();
  }

  void addNewNote(String title, String content) {
    if (content.isNotEmpty) {
      notes.insert(0, content);
    }
  }
}
