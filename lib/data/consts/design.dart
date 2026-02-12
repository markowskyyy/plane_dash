import 'package:flutter/material.dart';

class AppColors {
  static const Color skyTop = Color(0xFF4FC3F7);
  static const Color skyBottom = Color(0xFF81D4FA);
  static const Gradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyTop, skyBottom],
  );

  static const Color accentRed = Color(0xFFFF5252);
  static const Color starYellow = Color(0xFFFFD740);
  static const Color obstacleDark = Color(0xFF546E7A);

  static const Color panelWhite = Color(0x99FFFFFF);
  static const Color shadow = Color(0x26000000);

  static const Color darkBlueText = Color(0xFF0D47A1);
}

class AppTextStyles {
  static const TextStyle score = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlueText,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkBlueText,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.darkBlueText,
  );

// и т.д.
}