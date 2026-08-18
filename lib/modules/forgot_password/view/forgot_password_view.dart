import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_images.dart';
import '../../../app/utils/app_text_styles.dart';
import '../../../app/widgets/common_button.dart';
import '../controller/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Image.asset(
              AppImages.background,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      AppImages.logo,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.business, size: 60, color: AppColors.primary),
                    ),
                    const SizedBox(height: 32),

                    // White Card Container
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Obx(() {
                          switch (controller.currentStep.value) {
                            case 0:
                              return _buildStep1Email();
                            case 1:
                              return _buildStep2VerifyOtp();
                            case 2:
                            default:
                              return _buildStep3NewPassword();
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 1 UI: Request OTP
  Widget _buildStep1Email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            const Expanded(
              child: Text(
                'Forgot Password',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline1,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Please enter your registered email address.\nWe will send a 6-digit OTP code to your inbox.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText2,
        ),
        const SizedBox(height: 32),

        // Email Field
        const Text('Email Address', style: AppTextStyles.labelText),
        const SizedBox(height: 8),
        TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'john@gmail.com',
            hintStyle: const TextStyle(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Submit Button
        Obx(() => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : CommonButton(
                text: 'Send OTP Code',
                backgroundColor: AppColors.primary,
                onPressed: controller.sendOtp,
              )),

        const SizedBox(height: 20),

        TextButton(
          onPressed: () => Get.offAllNamed(AppRoutes.login),
          child: const Text('Back to Sign In', style: AppTextStyles.linkText),
        ),
      ],
    );
  }

  /// Step 2 UI: Enter & Verify 6-digit OTP
  Widget _buildStep2VerifyOtp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => controller.currentStep.value = 0,
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            const Expanded(
              child: Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline1,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'If that email is registered, you will receive a 6-digit code shortly.\nPlease check ${controller.emailController.text}.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText2,
        ),
        const SizedBox(height: 28),

        // OTP Field
        const Text('6-Digit OTP Code', style: AppTextStyles.labelText),
        const SizedBox(height: 8),
        TextField(
          controller: controller.otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: 'Enter 6-digit OTP',
            hintStyle: const TextStyle(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.security, color: AppColors.textSecondary),
            counterText: '',
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Verify OTP Button
        Obx(() => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : CommonButton(
                text: 'Verify OTP',
                backgroundColor: AppColors.primary,
                onPressed: controller.verifyOtp,
              )),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: controller.sendOtp,
              child: const Text('Resend Code', style: AppTextStyles.linkText),
            ),
            TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.login),
              child: const Text('Back to Sign In', style: AppTextStyles.linkText),
            ),
          ],
        ),
      ],
    );
  }

  /// Step 3 UI: Set New Password with See/Unsee Toggle
  Widget _buildStep3NewPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => controller.currentStep.value = 1,
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            const Expanded(
              child: Text(
                'Set New Password',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline1,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Please enter your new password below.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText2,
        ),
        const SizedBox(height: 24),

        // New Password Field with See/Unsee Toggle
        const Text('New Password', style: AppTextStyles.labelText),
        const SizedBox(height: 8),
        Obx(() => TextField(
              controller: controller.newPasswordController,
              obscureText: !controller.isPasswordVisible.value,
              decoration: InputDecoration(
                hintText: 'Minimum 6 characters',
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            )),
        const SizedBox(height: 16),

        // Confirm Password Field with See/Unsee Toggle
        const Text('Confirm New Password', style: AppTextStyles.labelText),
        const SizedBox(height: 8),
        Obx(() => TextField(
              controller: controller.confirmPasswordController,
              obscureText: !controller.isConfirmPasswordVisible.value,
              decoration: InputDecoration(
                hintText: 'Re-enter new password',
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.lock_clock_outlined, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            )),
        const SizedBox(height: 28),

        // Reset Password Submit Button
        Obx(() => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : CommonButton(
                text: 'Reset Password',
                backgroundColor: AppColors.primary,
                onPressed: controller.resetPassword,
              )),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () => Get.offAllNamed(AppRoutes.login),
          child: const Text('Cancel & Sign In', style: AppTextStyles.linkText),
        ),
      ],
    );
  }
}
