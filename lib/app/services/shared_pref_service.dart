import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class SharedPrefService extends GetxService {
  late SharedPreferences _prefs;

  Future<SharedPrefService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Onboarding Status
  Future<bool> setHasSeenOnboarding(bool seen) async {
    return await _prefs.setBool(AppConstants.hasSeenOnboardingKey, seen);
  }

  bool getHasSeenOnboarding() {
    return _prefs.getBool(AppConstants.hasSeenOnboardingKey) ?? false;
  }

  // Auth Status & Tokens
  Future<bool> setIsLoggedIn(bool loggedIn) async {
    return await _prefs.setBool(AppConstants.isLoggedInKey, loggedIn);
  }

  bool isLoggedIn() {
    final tokenExists = getToken() != null && getToken()!.isNotEmpty;
    return tokenExists;
  }

  Future<bool> setToken(String token) async {
    await setIsLoggedIn(token.isNotEmpty);
    return await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<bool> setRefreshToken(String refreshToken) async {
    return await _prefs.setString(AppConstants.refreshTokenKey, refreshToken);
  }

  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }

  // User Data Storage
  Future<bool> setUserData(String userDataJson) async {
    return await _prefs.setString(AppConstants.userKey, userDataJson);
  }

  String? getUserData() {
    return _prefs.getString(AppConstants.userKey);
  }

  // Clear session on logout
  Future<bool> clearSession() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userKey);
    return await _prefs.setBool(AppConstants.isLoggedInKey, false);
  }

  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
