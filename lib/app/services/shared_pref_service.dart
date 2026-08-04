import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class SharedPrefService extends GetxService {
  late SharedPreferences _prefs;

  Future<SharedPrefService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<bool> setToken(String token) async {
    return await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
