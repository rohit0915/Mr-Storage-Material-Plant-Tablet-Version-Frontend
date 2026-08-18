class ApiEndpoints {
  ApiEndpoints._();

  // Auth Endpoints
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh';
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String uploadPresignedUrl = 'upload/presigned-url';

  // Plant Dashboard & Projects Endpoints
  static const String plantProjectStats = 'plant/projects/stats';
  static const String plantProjects = 'plant/projects';
  static String plantProjectDetail(String leadId) =>
      'plant/projects/$leadId/detail';
  static String plantProjectLifecycle(String leadId) =>
      'plant/projects/$leadId/lifecycle';
  static String plantProjectInvoices(String leadId) =>
      'plant/projects/$leadId/invoices';
  static String plantProjectNotes(String leadId) =>
      'plant/projects/$leadId/notes';
  static String plantProjectDrawings(String leadId) =>
      'plant/projects/$leadId/drawings';
  static String plantProjectBuildings(String leadId) =>
      'plant/projects/$leadId/buildings';
  static String plantProjectBom(String leadId) => 'plant/projects/$leadId/bom';
  static String plantProjectBomFiles(String leadId) =>
      'plant/projects/$leadId/bom-files';
  static String plantProjectDeliveries(String leadId) =>
      'plant/deliveries/project/$leadId';
  static String plantDeliveryDetail(String deliveryId) =>
      'plant/deliveries/$deliveryId/detail';
  static const String plantShipperFilesStats = 'plant/shipper-files/stats';
  static const String plantBomStats = 'plant/bom/stats';
  static const String plantBomProjects = 'plant/bom/projects';
  static String plantBomDetails(String jobId) => 'plant/bom/$jobId';
  static String plantConfirmBuildingBom(String buildingId) =>
      'plant/bom/buildings/$buildingId/confirm';
  static const String plantShipperProjects = 'plant/shipper-files/projects';
  static String plantProjectShipperRequests(String leadId) =>
      'plant/shipper-files/projects/$leadId/requests';
  static const String plantLoadPlanningProjects =
      'plant/load-planning/projects';
  static String plantProjectLoadPlanning(String leadId) =>
      'plant/projects/$leadId/load-planning';
  static String plantProjectTruckPlan(String leadId) =>
      'plant/projects/$leadId/load-planning/truck-plan';
  static const String plantPackingListProjects = 'plant/packing-lists/projects';
  static String plantPackingList(String packingListId) =>
      'plant/packing-lists/$packingListId';
  static String plantPackingListPlan(String packingListPlanId) =>
      'plant/packing-list-plans/$packingListPlanId';
  static const String plantDeliveriesStats = 'plant/deliveries/stats';
  static const String plantFreightStats = 'plant/deliveries/freight/stats';
  static const String plantFreightLoads = 'plant/deliveries/freight';
  static const String plantAwardedStats = 'plant/deliveries/awarded/stats';
  static const String plantAwardedLoads = 'plant/deliveries/awarded';
  static const String plantDeliveryCalendar = 'plant/deliveries/calendar';
  static const String plantAllDeliveries = 'plant/deliveries';
  static String plantDeliveryBids(String deliveryId) =>
      'plant/deliveries/$deliveryId/bids';
  static String plantFreightBidSelect(String bidId) =>
      'plant/freight-bids/$bidId/select';
  static String plantFreightBidResubmit(String bidId) =>
      'plant/freight-bids/$bidId/request-resubmit';

  // Notifications
  static const String notificationList = 'notifications';
  static const String notificationReadAll = 'notifications/read-all';
  static String notificationRead(String id) => 'notifications/$id/read';
  static String notificationDelete(String id) => 'notifications/$id';

  // Shared Master Data Table (costings)
  static const String smdtItems = 'smdt';
  static const String smdtStats = 'smdt/stats';
  static const String smdtExport = 'smdt/export/excel';
  static String smdtItem(String id) => 'smdt/$id';

  // Logistics & Delivery Endpoints
  static const String shipperFiles = '/shipper/files';
  static const String loadPlanning = '/load-planning';
  static const String packingList = '/packing-list';
  static const String qrLabels = '/qr-labels';
  static const String freightLoads = '/freight/loads';
  static const String deliveryCalendar = '/deliveries/calendar';
  static const String notifications = '/notifications';

  // Costings & Shippers
  static const String costings = '/costings';
  static const String savings = '/savings';
  static const String shippers = '/shippers';
  static const String freightCarriers = '/freight-carriers';

  static const String plantVendors = 'plant/vendors';
  static String plantVendor(String id) => 'plant/vendors/$id';
  static String plantVendorToggleStatus(String id) =>
      'plant/vendors/$id/toggle-status';
  static const String plantCarriers = 'plant/carriers';
  static String plantCarrier(String id) => 'plant/carriers/$id';
  static String plantCarrierToggleStatus(String id) =>
      'plant/carriers/$id/toggle-status';

  static const String changePassword = 'auth/change-password';
  static const String customers = 'customers';
  static String plantConsolidatedBom(String leadId) =>
      'plant/projects/$leadId/consolidated-bom';
  static String plantGenerateConsolidatedBom(String leadId) =>
      'plant/projects/$leadId/consolidated-bom/generate';
  static String plantConsolidatedBomUrl(String leadId) =>
      'plant/bom/projects/$leadId/consolidated-url';
  static String plantSendConsolidatedBom(String leadId) =>
      'plant/projects/$leadId/consolidated-bom/send';
  static String plantProjectBundlePlan(String leadId) =>
      'plant/projects/$leadId/bundle-plan';
  static String plantProjectFreightAutofill(String leadId) =>
      'plant/projects/$leadId/freight-autofill';
  static String plantShipperRequestDocument(String requestId) =>
      'plant/shipper-requests/$requestId/document';
  static String plantShipperRequestCompare(String requestId) =>
      'plant/shipper-requests/$requestId/compare';
  static String plantComparisonJobStatus(String jobId) =>
      'plant/shipper-requests/compare-jobs/$jobId/status';
  static const String plantComparisonJobsStatus =
      'plant/shipper-requests/compare-jobs/status';
  static String plantShipperRequestApprove(String requestId) =>
      'plant/shipper-requests/$requestId/approve';
  static String plantShipperRequestResubmit(String requestId) =>
      'plant/shipper-requests/$requestId/request-resubmit';
  static String plantComparisonSummary(String requestId) =>
      'plant/shipper-requests/$requestId/comparison-summary';
  static String plantComparisonResults(String requestId) =>
      'plant/shipper-requests/$requestId/comparison-results';
  static String plantGenerateBundlePlan(String requestId) =>
      'plant/shipper-requests/$requestId/bundle-plan/generate';
  static String plantBundlePlan(String bundlePlanId) =>
      'plant/bundle-plans/$bundlePlanId';
  static String plantBundlePlanCoverage(String bundlePlanId) =>
      'plant/bundle-plans/$bundlePlanId/coverage';
  static String plantBundlePlanConfirm(String bundlePlanId) =>
      'plant/bundle-plans/$bundlePlanId/confirm';
  static String plantBundlePlanBundles(String bundlePlanId) =>
      'plant/bundle-plans/$bundlePlanId/bundles';
  static String plantBundlePlanFreightAutofill(String bundlePlanId) =>
      'plant/bundle-plans/$bundlePlanId/freight-autofill';
  static String plantDeliverySendBids(String deliveryId) =>
      'plant/deliveries/$deliveryId/send-bids';
}
