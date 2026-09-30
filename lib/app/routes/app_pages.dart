import '../../modules/notification_history/view/delivery_notification_history_view.dart';
import '../../modules/notification_history/controller/delivery_notification_history_controller.dart';
import '../../modules/notification_history/repository/notification_repository.dart';
import 'package:get/get.dart';
import '../../modules/all_projects/binding/all_projects_binding.dart';
import '../../modules/all_projects/view/all_projects_view.dart';
import '../../modules/bom_files_details/binding/bom_files_details_binding.dart';
import '../../modules/bom_files_details/view/bom_files_details_view.dart';
import '../../modules/customer_info/binding/customer_info_binding.dart';
import '../../modules/customer_info/view/customer_info_view.dart';
import '../../modules/delivery_details/binding/delivery_details_binding.dart';
import '../../modules/freight_carriers/view/carrier_details_view.dart';
import '../../modules/freight_carriers/binding/carrier_details_binding.dart';

import '../../modules/delivery_details/view/delivery_details_view.dart';
import '../../modules/generate_shipper_order/binding/generate_shipper_order_binding.dart';
import '../../modules/generate_shipper_order/view/generate_shipper_order_view.dart';
import '../../modules/home/binding/home_binding.dart';
import '../../modules/home/view/home_view.dart';
import '../../modules/onboarding/binding/onboarding_binding.dart';
import '../../modules/onboarding/view/onboarding_view.dart';
import '../../modules/login/binding/login_binding.dart';
import '../../modules/login/view/login_view.dart';
import '../../modules/forgot_password/binding/forgot_password_binding.dart';
import '../../modules/forgot_password/view/forgot_password_view.dart';
import '../../modules/pdf_view/binding/pdf_view_binding.dart';
import '../../modules/pdf_view/view/pdf_view_screen.dart';
import '../../modules/project_details/binding/project_details_binding.dart';
import '../../modules/project_details/view/project_details_view.dart';
import '../../modules/project_drawings/binding/project_drawings_binding.dart';
import '../../modules/project_drawings/view/project_drawings_view.dart';
import '../../modules/projects/binding/projects_binding.dart';
import '../../modules/projects/view/projects_view.dart';
import '../../modules/shipper_file_details/binding/shipper_file_details_binding.dart';
import '../../modules/shipper_file_details/view/shipper_file_details_view.dart';
import '../../modules/shipper_files/binding/shipper_files_binding.dart';
import '../../modules/shipper_files/view/shipper_files_view.dart';
import '../../modules/shipper_files/view/project_shipper_files_view.dart';
import '../../modules/additional_material_request/binding/additional_material_request_binding.dart';
import '../../modules/additional_material_request/view/additional_material_request_view.dart';
import '../../modules/uploaded_bom_files/binding/uploaded_bom_files_binding.dart';
import '../../modules/uploaded_bom_files/view/uploaded_bom_files_view.dart';
import '../../modules/order_verification/binding/order_verification_binding.dart';
import '../../modules/order_verification/view/order_verification_view.dart';
import '../../modules/comparison_result/binding/comparison_result_binding.dart';
import '../../modules/comparison_result/view/comparison_result_view.dart';
import '../../modules/load_planning/binding/load_planning_binding.dart';
import '../../modules/load_planning/view/load_planning_view.dart';
import '../../modules/load_planning/view/load_plan_details_view.dart';
import '../../modules/load_planning/binding/load_planning_workflow_binding.dart';
import '../../modules/load_planning/view/load_planning_workflow_view.dart';
import '../../modules/packing_list/binding/packing_list_binding.dart';
import '../../modules/packing_list/view/packing_list_view.dart';
import '../../modules/packing_list/view/project_packing_list_view.dart';
import '../../modules/packing_list/view/packing_list_details_view.dart';
import '../../modules/qr_labels/binding/qr_labels_binding.dart';
import '../../modules/qr_labels/view/qr_labels_view.dart';
import '../../modules/qr_labels/view/project_qr_labels_view.dart';
import '../../modules/freight_loads/binding/freight_loads_binding.dart';
import '../../modules/freight_loads/view/freight_loads_view.dart';
import '../../modules/freight_loads/view/freight_request_details_view.dart';
import '../../modules/awarded_loads/binding/awarded_loads_binding.dart';
import '../../modules/awarded_loads/view/awarded_loads_view.dart';
import '../../modules/delivery_calendar/binding/delivery_calendar_binding.dart';
import '../../modules/delivery_calendar/view/delivery_calendar_view.dart';
import '../../modules/all_deliveries/binding/all_deliveries_binding.dart';
import '../../modules/all_deliveries/view/all_deliveries_view.dart';
import '../../modules/notification_history/binding/notification_history_binding.dart';
import '../../modules/notification_history/view/notification_history_view.dart';
import '../../modules/item_cost_list/binding/item_cost_binding.dart';
import '../../modules/item_cost_list/view/item_cost_list_view.dart';
import '../../modules/missing_item_cost_list/binding/missing_item_cost_binding.dart';
import '../../modules/missing_item_cost_list/view/missing_item_cost_list_view.dart';
import '../../modules/savings/binding/savings_binding.dart';
import '../../modules/savings/view/savings_view.dart';
import '../../modules/shippers/binding/shippers_binding.dart';
import '../../modules/shippers/view/shippers_list_view.dart';
import '../../modules/shippers/view/vendor_details_view.dart';
import '../../modules/shippers/view/add_shipper_view.dart';
import '../../modules/shippers/view/edit_shipper_view.dart';
import '../../modules/freight_carriers/binding/freight_carriers_binding.dart';
import '../../modules/freight_carriers/view/freight_carriers_view.dart';
import '../../modules/freight_carriers/view/add_freight_carrier_view.dart';
import '../../modules/chat/binding/chat_binding.dart';
import '../../modules/chat/view/chat_view.dart';
import 'auth_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.projects,
      page: () => const ProjectsView(),
      binding: ProjectsBinding(),
    ),
    GetPage(
      name: AppRoutes.allProjects,
      page: () => const AllProjectsView(),
      binding: AllProjectsBinding(),
    ),
    GetPage(
      name: AppRoutes.projectDetails,
      page: () => const ProjectDetailsView(),
      binding: ProjectDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.projectDrawings,
      page: () => const ProjectDrawingsView(),
      binding: ProjectDrawingsBinding(),
    ),
    GetPage(
      name: AppRoutes.deliveryDetails,
      page: () => const DeliveryDetailsView(),
      binding: DeliveryDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.shipperFiles,
      page: () => const ShipperFilesView(),
      binding: ShipperFilesBinding(),
    ),
    GetPage(
      name: AppRoutes.projectShipperFiles,
      page: () => const ProjectShipperFilesView(),
      binding: ShipperFilesBinding(),
    ),
    GetPage(
      name: AppRoutes.shipperFileDetails,
      page: () => const ShipperFileDetailsView(),
      binding: ShipperFileDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.bomFilesDetails,
      page: () => const BomFilesDetailsView(),
      binding: BomFilesDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.generateShipperOrder,
      page: () => const GenerateShipperOrderView(),
      binding: GenerateShipperOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.pdfView,
      page: () => const PdfViewScreen(),
      binding: PdfViewBinding(),
    ),
    GetPage(
      name: AppRoutes.customerInfo,
      page: () => const CustomerInfoView(),
      binding: CustomerInfoBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.additionalMaterialRequest,
      page: () => const AdditionalMaterialRequestView(),
      binding: AdditionalMaterialRequestBinding(),
    ),
    GetPage(
      name: AppRoutes.uploadedBomFiles,
      page: () => const UploadedBomFilesView(),
      binding: UploadedBomFilesBinding(),
    ),
    GetPage(
      name: AppRoutes.orderVerification,
      page: () => const OrderVerificationView(),
      binding: OrderVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.comparisonResult,
      page: () => const ComparisonResultView(),
      binding: ComparisonResultBinding(),
    ),
    GetPage(
      name: AppRoutes.loadPlanning,
      page: () => const LoadPlanningView(),
      binding: LoadPlanningBinding(),
    ),
    GetPage(
      name: AppRoutes.projectLoadPlanning,
      page: () => const LoadPlanningWorkflowView(),
      binding: LoadPlanningWorkflowBinding(),
    ),
    GetPage(
      name: AppRoutes.loadPlanDetails,
      page: () => const LoadPlanDetailsView(),
      binding: LoadPlanningBinding(),
    ),
    GetPage(
      name: AppRoutes.packingList,
      page: () => const PackingListView(),
      binding: PackingListBinding(),
    ),
    GetPage(
      name: AppRoutes.projectPackingList,
      page: () => const ProjectPackingListView(),
      binding: PackingListBinding(),
    ),
    GetPage(
      name: AppRoutes.packingListDetails,
      page: () => const PackingListDetailsView(),
      binding: PackingListBinding(),
    ),
    GetPage(
      name: AppRoutes.qrLabels,
      page: () => const QrLabelsView(),
      binding: QrLabelsBinding(),
    ),
    GetPage(
      name: AppRoutes.projectQrLabels,
      page: () => const ProjectQrLabelsView(),
      binding: QrLabelsBinding(),
    ),
    GetPage(
      name: AppRoutes.freightLoads,
      page: () => const FreightLoadsView(),
      binding: FreightLoadsBinding(),
    ),
    GetPage(
      name: AppRoutes.freightRequestDetails,
      page: () => const FreightRequestDetailsView(),
      binding: FreightLoadsBinding(),
    ),
    GetPage(
      name: AppRoutes.awardedLoads,
      page: () => const AwardedLoadsView(),
      binding: AwardedLoadsBinding(),
    ),
    GetPage(
      name: AppRoutes.deliveryCalendar,
      page: () => const DeliveryCalendarView(),
      binding: DeliveryCalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.allDeliveries,
      page: () => const AllDeliveriesView(),
      binding: AllDeliveriesBinding(),
    ),
    GetPage(
      name: AppRoutes.deliveryNotificationHistory,
      page: () => const DeliveryNotificationHistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DeliveryNotificationHistoryController(repository: NotificationRepository(apiClient: Get.find())));
      }),
    ),
    GetPage(
      name: AppRoutes.notificationHistory,
      page: () => const NotificationHistoryView(),
      binding: NotificationHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.itemCostList,
      page: () => const ItemCostListView(),
      binding: ItemCostBinding(),
    ),
    GetPage(
      name: AppRoutes.missingItemCostList,
      page: () => const MissingItemCostListView(),
      binding: MissingItemCostBinding(),
    ),
    GetPage(
      name: AppRoutes.savings,
      page: () => const SavingsView(),
      binding: SavingsBinding(),
    ),
    GetPage(
      name: AppRoutes.shippersList,
      page: () => const ShippersListView(),
      binding: ShippersBinding(),
    ),
    GetPage(
      name: AppRoutes.vendorDetails,
      page: () => const VendorDetailsView(),
      binding: ShippersBinding(),
    ),
    GetPage(
      name: AppRoutes.addShipper,
      page: () => const AddShipperView(),
      binding: ShippersBinding(),
    ),
    GetPage(
      name: AppRoutes.editShipper,
      page: () => const EditShipperView(),
      binding: ShippersBinding(),
    ),
    GetPage(
      name: AppRoutes.freightCarriers,
      page: () => const FreightCarriersView(),
      binding: FreightCarriersBinding(),
    ),
    GetPage(
      name: AppRoutes.addFreightCarrier,
      page: () => const AddFreightCarrierView(),
      binding: FreightCarriersBinding(),
    ),
    GetPage(
      name: AppRoutes.editFreightCarrier,
      page: () => const AddFreightCarrierView(isEdit: true),
      binding: FreightCarriersBinding(),
    ),
    GetPage(
      name: AppRoutes.carrierDetails,
      page: () => const CarrierDetailsView(),
      binding: CarrierDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
  ];
}
