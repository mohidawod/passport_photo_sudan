import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // Primary Palette (Minimalist Grayscale)
  static const Color primary = Color(0xFF212121); // Dark Grey
  static const Color secondary = Color(0xFF757575); // Medium Grey
  static const Color contrast = Color(0xFFFFFFFF); // White
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Background Colors for Passport Photos (Functional)
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundRed = Color(0xFFB71C1C); // Official Dark Red
  
  // Semantic Colors (Restricted)
  // We avoid colorful UI elements unless strictly necessary for errors
  static const Color success = Color(0xFF4CAF50); // Keep for internal logic if needed, but UI uses icons
  static const Color warning = Color(0xFFFFC107);
  static const Color error = backgroundRed; // Use official red for errors
  
  // Surface Colors
  static const Color surfaceDark = Color(0xFF000000); // Pure Black
  static const Color surfaceLight = Color(0xFFF5F5F5);
}
