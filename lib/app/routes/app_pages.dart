import 'package:get/get.dart';
import '../../modules/all_projects/binding/all_projects_binding.dart';
import '../../modules/all_projects/view/all_projects_view.dart';
import '../../modules/bom_files_details/binding/bom_files_details_binding.dart';
import '../../modules/bom_files_details/view/bom_files_details_view.dart';
import '../../modules/customer_info/binding/customer_info_binding.dart';
import '../../modules/customer_info/view/customer_info_view.dart';
import '../../modules/delivery_details/binding/delivery_details_binding.dart';
import '../../modules/delivery_details/view/delivery_details_view.dart';
import '../../modules/generate_shipper_order/binding/generate_shipper_order_binding.dart';
import '../../modules/generate_shipper_order/view/generate_shipper_order_view.dart';
import '../../modules/home/binding/home_binding.dart';
import '../../modules/home/view/home_view.dart';
import '../../modules/onboarding/binding/onboarding_binding.dart';
import '../../modules/onboarding/view/onboarding_view.dart';
import '../../modules/login/binding/login_binding.dart';
import '../../modules/login/view/login_view.dart';
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
import '../../modules/load_planning/view/project_load_planning_view.dart';
import '../../modules/packing_list/binding/packing_list_binding.dart';
import '../../modules/packing_list/view/packing_list_view.dart';
import '../../modules/packing_list/view/project_packing_list_view.dart';
import '../../modules/packing_list/view/packing_list_details_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
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
      page: () => const ProjectLoadPlanningView(),
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
  ];
}
