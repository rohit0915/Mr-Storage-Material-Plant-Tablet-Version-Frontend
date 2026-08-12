import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/shared_pref_service.dart';
import '../../../app/utils/app_images.dart';
import '../model/onboarding_model.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      title: 'Scan, Verify &\nComplete Tasks',
      description: 'Quickly scan coils, panels, trims, and fasteners to verify production accuracy and update progress instantly.',
      imagePath: AppImages.onboarding1,
    ),
    OnboardingModel(
      title: 'Work Faster with\nSmart Guidance',
      description: 'Receive step-by-step instructions, AI recommendations, quality checks, and supervisor approvals directly on your tablet.',
      imagePath: AppImages.onboarding2,
    ),
    OnboardingModel(
      title: 'Track Performance &\nKPIs in Real-time',
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
      finishOnboarding();
    }
  }

  void finishOnboarding() async {
    if (Get.isRegistered<SharedPrefService>()) {
      await Get.find<SharedPrefService>().setHasSeenOnboarding(true);
    }
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
