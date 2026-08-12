import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/shared_pref_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isFormValid = false.obs;
  final RxBool rememberMe = true.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final emailValid = emailController.text.isNotEmpty && emailController.text.contains('@');
    final passwordValid = passwordController.text.isNotEmpty && passwordController.text.length >= 6;
    isFormValid.value = emailValid && passwordValid;
  }

  void toggleRememberMe(bool? value) {
    if (value != null) {
      rememberMe.value = value;
    }
  }

  void login() async {
    if (isFormValid.value) {
      // Save token and login status in SharedPrefService
      if (Get.isRegistered<SharedPrefService>()) {
        final prefService = Get.find<SharedPrefService>();
        await prefService.setToken('sample_auth_token_steel_depot_2025');
        await prefService.setIsLoggedIn(true);
      }

      Get.snackbar(
        'Success',
        'Logged in successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22C55E),
        colorText: Colors.white,
      );

      // Navigate to Home Dashboard after login
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.snackbar(
        'Invalid Input',
        'Please enter a valid email and password (min 6 chars)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
