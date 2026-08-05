import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steel_building_plant_panel/app/utils/app_images.dart';
import '../../../app/utils/app_colors.dart';
import '../../../app/utils/app_text_styles.dart';
import '../controller/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

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
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 700;
                
                return PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.onboardingPages.length,
                  itemBuilder: (context, index) {
                    final page = controller.onboardingPages[index];
                    
                    if (isTablet) {
                      // Tablet / Web Layout (Exactly as Figma)
                      return Row(
                        children: [
                          // Left Column: Logo and Text
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 60.0, right: 32.0, top: 60.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Logo
                                  Image.asset(
                                    AppImages.logo,
                                    height: 60,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.business, size: 60, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 64),
                                  // Title
                                  RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${page.title.split('\n').first}\n',
                                          style: AppTextStyles.headline1.copyWith(
                                            color: const Color(0xFF2B66FF), // Blue from Figma
                                            fontSize: 48,
                                            fontWeight: FontWeight.w900,
                                            height: 1.2,
                                          ),
                                        ),
                                        if (page.title.split('\n').length > 1)
                                          TextSpan(
                                            text: page.title.split('\n').skip(1).join('\n'),
                                            style: AppTextStyles.headline1.copyWith(
                                              color: const Color(0xFF0D2554), // Dark blue from Figma
                                              fontSize: 48,
                                              fontWeight: FontWeight.w900,
                                              height: 1.2,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Description
                                  Text(
                                    page.description,
                                    textAlign: TextAlign.left,
                                    style: AppTextStyles.bodyText1.copyWith(
                                      color: Colors.grey.shade600,
                                      height: 1.5,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Right Column: Image and Controls
                          Expanded(
                            flex: 1,
                            child: Stack(
                              children: [
                                // Full width/height image covering the right side without cropping
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Image.asset(
                                      page.imagePath,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.bottomRight,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                                        );
                                      }
                                    ),
                                  ),
                                ),
                                // Bottom Controls inside the right side
                                Positioned(
                                  bottom: 48,
                                  left: 64,
                                  right: 64,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: controller.next,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2B66FF),
                                            padding: const EdgeInsets.symmetric(vertical: 20),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Next', 
                                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Obx(() => Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          controller.onboardingPages.length,
                                          (dotIndex) => Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 6),
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: controller.currentIndex.value == dotIndex
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.4),
                                            ),
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile Layout
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 24.0, top: 24.0),
                            child: Image.asset(
                              AppImages.logo,
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.business, size: 40, color: AppColors.primary),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${page.title.split('\n').first}\n',
                                        style: AppTextStyles.headline1.copyWith(
                                          color: const Color(0xFF2B66FF), // Blue from Figma
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          height: 1.2,
                                        ),
                                      ),
                                      if (page.title.split('\n').length > 1)
                                        TextSpan(
                                          text: page.title.split('\n').skip(1).join('\n'),
                                          style: AppTextStyles.headline1.copyWith(
                                            color: const Color(0xFF0D2554),
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            height: 1.2,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyText1.copyWith(
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    page.imagePath,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomCenter,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                                      );
                                    }
                                  ),
                                ),
                                Positioned(
                                  bottom: 32,
                                  left: 24,
                                  right: 24,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: controller.next,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2B66FF),
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Next', 
                                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Obx(() => Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          controller.onboardingPages.length,
                                          (dotIndex) => Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: controller.currentIndex.value == dotIndex
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.4),
                                            ),
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
