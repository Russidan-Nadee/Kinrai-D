// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(
    0xFFFF6B35,
  ); // Orange from buttons and accent
  static const Color primaryVariant = Color(0xFFE55A2B);

  // Secondary Colors
  static const Color secondary = Color(0xFFF4CB57); // Yellow from header
  static const Color secondaryVariant = Color(0xFFF5A623);

  // Background Colors
  static const Color background = Color(
    0xFFFFFBF7,
  ); // Cream/off-white background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Gradient Colors
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF8A50), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFDB462), Color(0xFFF5A623)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Icon Colors
  static const Color iconActive = Color(0xFFFF6B35);
  static const Color iconInactive = Color(0xFFBDBDBD);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF2196F3);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);

  // Category Colors
  static const Color categorySnacks = Color(0xFFFDB462);
  static const Color categoryMeat = Color(0xFFFF8A50);
  static const Color categoryVegan = Color(0xFF81C784);
  static const Color categoryDessert = Color(0xFFFFAB91);
  static const Color categoryDrinks = Color(0xFF90CAF9);
}
