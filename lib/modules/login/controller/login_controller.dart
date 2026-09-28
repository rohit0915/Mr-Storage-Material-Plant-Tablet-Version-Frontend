import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';
import '../../../app/network/exceptions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/shared_pref_service.dart';
import '../../../app/services/plant_socket_service.dart';
import '../../../app/widgets/common_snackbar.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isFormValid = false.obs;
  final RxBool rememberMe = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final identifier = emailController.text.trim();
    final phone = identifier.replaceAll(RegExp(r'[\s()-]'), '');
    final emailValid = GetUtils.isEmail(identifier) ||
        RegExp(r'^\+?\d{7,15}$').hasMatch(phone);
    isFormValid.value = emailValid && passwordController.text.isNotEmpty;
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
          'password': passwordController.text,
        },
      );

      final responseData = response.data;
      if (responseData is Map && responseData['success'] == true) {
        final data = responseData['data'];
        if (data is! Map) throw ServerException('Invalid login response.');
        final accessToken = data['accessToken'] ?? '';
        final refreshToken = data?['refreshToken'] ?? '';
        final userObj = data?['user'];

        final role = (data['role'] ?? (userObj is Map ? userObj['role'] : null))?.toString().toLowerCase();
        if (role != 'plant') {
          throw UnauthorizedException('Access denied. Only plant accounts can sign in.');
        }
        if (accessToken is! String || accessToken.isEmpty || userObj is! Map) {
          throw ServerException('Invalid login response: session information is missing.');
        }
        if (Get.isRegistered<SharedPrefService>()) {
          final prefService = Get.find<SharedPrefService>();
          await prefService.clearSession();
          await prefService.setToken(accessToken.toString());
          if (refreshToken.toString().isNotEmpty) {
            await prefService.setRefreshToken(refreshToken.toString());
          }
          await prefService.setIsLoggedIn(true);
          if (userObj != null) {
            await prefService.setUserData(jsonEncode(userObj));
          }
        }

        CommonSnackbar.showSuccess(
          title: 'Success',
          message: responseData['message'] ?? 'Logged in successfully!',
        );

        if (Get.isRegistered<PlantSocketService>()) {
          Get.find<PlantSocketService>().connect();
        }

        Get.offAllNamed(AppRoutes.home);
      } else {
        final msg = responseData?['message'] ?? 'Login failed';
        CommonSnackbar.showError(title: 'Login Error', message: msg.toString());
      }
    } on AppException catch (e) {
      CommonSnackbar.showError(title: 'Login Error', message: e.message);
    } catch (e) {
      CommonSnackbar.showError(title: 'Login Error', message: e.toString());
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
