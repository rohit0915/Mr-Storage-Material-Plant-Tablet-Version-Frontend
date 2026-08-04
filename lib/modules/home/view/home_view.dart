import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/widgets/common_appbar.dart';
import '../../../app/widgets/common_error_widget.dart';
import '../../../app/widgets/common_loader.dart';
import '../controller/home_controller.dart';
import '../widgets/home_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Home'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CommonLoader();
        }

        if (controller.errorMessage.isNotEmpty) {
          return CommonErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadData,
          );
        }

        return ListView.builder(
          itemCount: controller.homeData.length,
          itemBuilder: (context, index) {
            final item = controller.homeData[index];
            return HomeWidget(model: item);
          },
        );
      }),
    );
  }
}
