class ApiEndpoints {
  ApiEndpoints._();

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // Dashboard & Projects Endpoints
  static const String dashboard = '/dashboard/summary';
  static const String projects = '/projects';
  static const String projectDetails = '/projects/details';
  static const String drawings = '/drawings';

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
