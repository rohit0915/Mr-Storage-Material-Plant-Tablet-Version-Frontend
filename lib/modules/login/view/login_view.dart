import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steel_building_plant_panel/app/utils/app_images.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_text_styles.dart';
import '../../../app/widgets/common_button.dart';
import '../../../app/widgets/log_viewer_dialog.dart';
import '../controller/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Pattern Image
          Positioned.fill(
            child: Image.asset(
              AppImages.background,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          
          // Log Viewer Quick Trigger Icon at top-right
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.bug_report_outlined, color: AppColors.textSecondary),
                tooltip: 'View App Logs',
                onPressed: () => LogViewerDialog.show(),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with Long-Press Log Trigger
                    GestureDetector(
                      onLongPress: () => LogViewerDialog.show(),
                      child: Image.asset(
                        AppImages.logo,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.business, size: 60, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // White Card
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Container(
                        padding: const EdgeInsets.all(24),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Sign In',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headline1,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Plant App',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headline2,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please enter below details to\naccess the dashboard',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyText2,
                          ),
                          const SizedBox(height: 32),
                          
                          // Email Field
                          const Text('Email or phone number', style: AppTextStyles.labelText),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Enter your email or phone',
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
                          const SizedBox(height: 20),
                          
                          // Password Field
                          const Text('Password', style: AppTextStyles.labelText),
                          const SizedBox(height: 8),
                          Obx(() => TextField(
                            controller: controller.passwordController,
                            obscureText: !controller.isPasswordVisible.value,
                            decoration: InputDecoration(
                              hintText: '****************',
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
                          
                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Obx(() => SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: controller.rememberMe.value,
                                      onChanged: controller.toggleRememberMe,
                                      activeColor: AppColors.accent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                  )),
                                  const SizedBox(width: 8),
                                  const Text('Remember Me', style: AppTextStyles.bodyText2),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                child: const Text('Forgot password?', style: AppTextStyles.linkText),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Login Button
                          Obx(() => controller.isLoading.value
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: CircularProgressIndicator(color: AppColors.primary),
                                  ),
                                )
                              : CommonButton(
                                  text: 'Login',
                                  backgroundColor: controller.isFormValid.value ? AppColors.primary : AppColors.primaryLight,
                                  onPressed: controller.isFormValid.value ? controller.login : () {},
                                )),
                        ],
                      ),
                    ),
                    )],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
