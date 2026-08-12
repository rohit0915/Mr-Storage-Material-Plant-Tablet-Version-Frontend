class AppConstants {
  AppConstants._();

  static const String appName = 'Steel Building Depot Plant Panel';
  
  // API Base URL
  static const String baseUrl = 'https://api.example.com/v1/';
  
  // Timeout
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Shared Preferences Keys
  static const String tokenKey = 'TOKEN_KEY';
  static const String userKey = 'USER_KEY';
  static const String themeKey = 'THEME_KEY';
  static const String hasSeenOnboardingKey = 'HAS_SEEN_ONBOARDING_KEY';
  static const String isLoggedInKey = 'IS_LOGGED_IN_KEY';
}
