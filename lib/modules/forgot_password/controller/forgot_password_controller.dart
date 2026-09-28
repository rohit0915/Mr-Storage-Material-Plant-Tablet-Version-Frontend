import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/network/api_client.dart';
import '../../../app/network/api_endpoints.dart';
import '../../../app/network/exceptions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/common_snackbar.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Steps: 0 = Request OTP, 1 = Verify OTP, 2 = Set New Password
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Stored short-lived JWT returned by Step 2 (verify-otp)
  final RxString resetToken = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Step 1: Request OTP
  Future<void> sendOtp() async {
    if (isLoading.value) return;
    final email = emailController.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      CommonSnackbar.showWarning(
        title: 'Invalid Email',
        message: 'Please enter a valid email address.',
      );
      return;
    }

    isLoading.value = true;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email, 'role': 'plant'},
      );

      final responseData = response.data;
      if (responseData is! Map || responseData['success'] != true) {
        throw ServerException(_extractErrorMessage(responseData) ?? 'Unable to request OTP.');
      }
      resetToken.value = '';
      final msg = responseData['message'] ??
          'If that email exists, a 6-digit OTP code has been sent.';

      CommonSnackbar.showSuccess(
        title: 'OTP Sent',
        message: msg.toString(),
      );
      currentStep.value = 1;
    } on AppException catch (error) {
      CommonSnackbar.showError(title: 'Request Failed', message: error.message);
    } catch (_) {
      CommonSnackbar.showError(title: 'Request Failed', message: 'Invalid server response. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2: Verify 6-digit OTP -> Retrieve resetToken
  Future<void> verifyOtp() async {
    if (isLoading.value) return;
    final email = emailController.text.trim().toLowerCase();
    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length != 6 || int.tryParse(otp) == null) {
      CommonSnackbar.showWarning(
        title: 'Invalid OTP',
        message: 'Please enter the 6-digit numeric OTP code sent to your email.',
      );
      return;
    }

    isLoading.value = true;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final responseData = response.data;
      if (responseData is Map && responseData['success'] == true) {
        final token = responseData['data']?['resetToken']?.toString() ?? '';
        if (token.isEmpty) {
          throw ServerException('Invalid OTP response: reset token is missing.');
        }
        resetToken.value = token;
        CommonSnackbar.showSuccess(
          title: 'OTP Verified',
          message: responseData['message'] ?? 'OTP verified successfully.',
        );
        currentStep.value = 2;
      } else {
        final errorMsg = _extractErrorMessage(responseData) ?? 'Invalid or expired OTP';
        CommonSnackbar.showError(title: 'Verification Error', message: errorMsg);
      }
    } on AppException catch (error) {
      CommonSnackbar.showError(title: 'Verification Failed', message: error.message);
    } catch (_) {
      CommonSnackbar.showError(title: 'Verification Failed', message: 'Invalid server response. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 3: Submit New Password with resetToken
  Future<void> resetPassword() async {
    if (isLoading.value) return;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.length < 6) {
      CommonSnackbar.showWarning(
        title: 'Weak Password',
        message: 'New password must be at least 6 characters.',
      );
      return;
    }
    if (newPassword != confirmPassword) {
      CommonSnackbar.showWarning(
        title: 'Password Mismatch',
        message: 'New password and confirm password do not match.',
      );
      return;
    }
    if (resetToken.value.isEmpty) {
      CommonSnackbar.showWarning(
        title: 'Session Expired',
        message: 'Reset token is missing or expired. Please restart.',
      );
      currentStep.value = 0;
      return;
    }

    isLoading.value = true;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'resetToken': resetToken.value,
          'newPassword': newPassword,
        },
      );

      final responseData = response.data;
      if (responseData is Map && responseData['success'] == true) {
        CommonSnackbar.showSuccess(
          title: 'Password Reset Successful',
          message: responseData['message'] ?? 'Password reset successfully! Please sign in.',
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        final msg = _extractErrorMessage(responseData) ?? 'Unable to reset password';
        CommonSnackbar.showError(title: 'Reset Error', message: msg);
      }
    } on AppException catch (error) {
      CommonSnackbar.showError(title: 'Reset Error', message: error.message);
    } catch (_) {
      CommonSnackbar.showError(title: 'Reset Error', message: 'Invalid server response. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is! Map) return null;
    if (responseData['errors'] is List && (responseData['errors'] as List).isNotEmpty) {
      final firstErr = (responseData['errors'] as List).first;
      if (firstErr is Map && firstErr['msg'] != null) {
        return firstErr['msg'].toString();
      }
    }
    return responseData['message']?.toString();
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
