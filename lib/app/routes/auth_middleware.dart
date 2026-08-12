import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/shared_pref_service.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<SharedPrefService>()) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final prefService = Get.find<SharedPrefService>();
    final isLoggedIn = prefService.isLoggedIn();

    if (!isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}
