import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/shared_pref_service.dart';
import 'app/utils/app_constants.dart';
import 'app/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  final prefService = await Get.putAsync(() => SharedPrefService().init());

  // Dynamic Routing Logic: Onboarding -> Login -> Home Dashboard
  final hasSeenOnboarding = prefService.getHasSeenOnboarding();
  final isLoggedIn = prefService.isLoggedIn();

  String initialRoute;
  if (!hasSeenOnboarding) {
    initialRoute = AppRoutes.onboarding;
  } else if (isLoggedIn) {
    initialRoute = AppRoutes.home;
  } else {
    initialRoute = AppRoutes.login;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
