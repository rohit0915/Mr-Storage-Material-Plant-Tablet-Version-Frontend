import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/shared_pref_service.dart';
import 'app/utils/app_constants.dart';
import 'app/utils/app_logger.dart';
import 'app/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'Uncaught Flutter Error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error('Uncaught Platform Async Error: $error', error, stack);
    return true;
  };

  AppLogger.info('--- Application Launching ---');
  AppLogger.info('Base API URL: ${AppConstants.baseUrl}');

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

  AppLogger.info('Initial Route Selected: $initialRoute');

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
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialBinding: InitialBinding(),
        initialRoute: initialRoute,
        getPages: AppPages.routes,
      ),
    );
  }
}
