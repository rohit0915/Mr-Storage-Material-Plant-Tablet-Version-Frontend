import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1D51A4); // The deep blue used in buttons and accents
  static const Color primaryLight = Color(0xFFAEC4FA); // Disabled button state
  static const Color accent = Color(0xFF22C55E); // Green for the checkbox
  
  static const Color background = Color(0xFFEAF0FA); // Light blue tinted background matching Figma
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputBackground = Color(0xFFF8FAFC);
  
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  
  static const Color divider = Color(0xFFE2E8F0);

  // Gradient for Eye Action Buttons matching design
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF5850EC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Top metric card colors
  static const Color totalProjectsCard = Color(0xFF1D51A4); // Deep Blue
  static const Color inProductionCard = Color(0xFF3AB449); // Vibrant Green
  static const Color readyToDispatchCard = Color(0xFFEAB308); // Golden Yellow
  static const Color dispatchedTodayCard = Color(0xFF6840D4); // Purple
  static const Color pendingApprovalCard = Color(0xFFFD8D5B); // Orange

  // Badge Status Colors
  static const Color badgeYellowBg = Color(0xFFFEF9C3);
  static const Color badgeYellowText = Color(0xFFA16207);

  static const Color badgeGreenBg = Color(0xFFDCFCE7);
  static const Color badgeGreenText = Color(0xFF15803D);

  static const Color badgeBlueBg = Color(0xFFDBEAFE);
  static const Color badgeBlueText = Color(0xFF1D4ED8);

  static const Color badgeRedBg = Color(0xFFFEE2E2);
  static const Color badgeRedText = Color(0xFFDC2626);

  static const Color badgePurpleBg = Color(0xFFF3E8FF);
  static const Color badgePurpleText = Color(0xFF7E22CE);
}
