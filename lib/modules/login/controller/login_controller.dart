import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  void login() {
    if (isFormValid.value) {
      // Perform login API call
      // For now, simulate success
      Get.snackbar('Success', 'Logged in successfully!', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
