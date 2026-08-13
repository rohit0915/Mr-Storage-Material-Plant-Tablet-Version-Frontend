class ApiEndpoints {
  ApiEndpoints._();

  // Auth Endpoints
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh';

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
  static String plantProjectBomFiles(String leadId) =>
      'plant/projects/$leadId/bom-files';
  static String plantProjectDeliveries(String leadId) =>
      'plant/deliveries/project/$leadId';
  static String plantDeliveryDetail(String deliveryId) =>
      'plant/deliveries/$deliveryId/detail';
  static const String plantShipperFilesStats = 'plant/shipper-files/stats';
  static const String plantBomStats = 'plant/bom/stats';
  static const String plantBomProjects = 'plant/bom/projects';
  static const String plantShipperProjects = 'plant/shipper-files/projects';
  static String plantProjectShipperRequests(String leadId) =>
      'plant/shipper-files/projects/$leadId/requests';
  static const String plantLoadPlanningProjects =
      'plant/load-planning/projects';
  static String plantProjectLoadPlanning(String leadId) =>
      'plant/projects/$leadId/load-planning';
  static const String plantPackingListProjects = 'plant/packing-lists/projects';
  static String plantPackingList(String packingListId) =>
      'plant/packing-lists/$packingListId';
  static String plantPackingListPlan(String packingListPlanId) =>
      'plant/packing-list-plans/$packingListPlanId';
  static const String plantDeliveriesStats = 'plant/deliveries/stats';

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
}
