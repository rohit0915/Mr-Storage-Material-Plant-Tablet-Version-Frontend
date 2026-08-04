import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_images.dart';
import '../model/onboarding_model.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      title: 'Scan, Verify &\nComplete Tasks',
      description: 'Quickly scan coils, panels, trims, and fasteners to verify production accuracy and update progress instantly.',
      imagePath: AppImages.onboarding1, // Replace with actual worker image
    ),
    OnboardingModel(
      title: 'Work Faster with\nSmart Guidance',
      description: 'Receive step-by-step instructions, AI recommendations, quality checks, and supervisor approvals directly on your tablet.',
      imagePath: AppImages.onboarding2, // Replace with actual workers image
    ),
    OnboardingModel(
      title: 'Track Performance &\nKPIs in Real-time', // Example 3rd page
      description: 'Monitor overall plant performance and individual metrics directly from your dashboard.',
      imagePath: AppImages.onboarding3,
    ),
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void next() {
    if (currentIndex.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
