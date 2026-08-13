import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';
import '../../../app/network/exceptions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/shared_pref_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isFormValid = false.obs;
  final RxBool rememberMe = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final emailValid = emailController.text.trim().isNotEmpty && emailController.text.contains('@');
    final passwordValid = passwordController.text.trim().isNotEmpty && passwordController.text.trim().length >= 5;
    isFormValid.value = emailValid && passwordValid;
  }

  void toggleRememberMe(bool? value) {
    if (value != null) {
      rememberMe.value = value;
    }
  }

  Future<void> login() async {
    if (!isFormValid.value || isLoading.value) return;

    isLoading.value = true;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      final responseData = response.data;
      if (responseData != null && responseData['success'] == true) {
        final data = responseData['data'];
        final accessToken = data?['accessToken'] ?? '';
        final refreshToken = data?['refreshToken'] ?? '';
        final userObj = data?['user'];

        if (Get.isRegistered<SharedPrefService>()) {
          final prefService = Get.find<SharedPrefService>();
          await prefService.setToken(accessToken.toString());
          if (refreshToken.toString().isNotEmpty) {
            await prefService.setRefreshToken(refreshToken.toString());
          }
          await prefService.setIsLoggedIn(true);
          if (userObj != null) {
            await prefService.setUserData(jsonEncode(userObj));
          }
        }

        Get.snackbar(
          'Success',
          responseData['message'] ?? 'Logged in successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.home);
      } else {
        final msg = responseData?['message'] ?? 'Login failed';
        Get.snackbar(
          'Login Error',
          msg.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      }
    } on AppException catch (e) {
      Get.snackbar(
        'Login Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
