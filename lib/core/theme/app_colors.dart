import 'package:flutter/material.dart';

/// Paleta de cores do aplicativo
/// Inspirada no Facebook para familiaridade e confiança
class AppColors {
  // Cores principais (Facebook)
  static const Color primaryBlue = Color(0xFF1877F2);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF1C1E21);
  static const Color lightGray = Color(0xFFF0F2F5);

  // Cores de feedback
  static const Color success = Color(0xFF42B72A);
  static const Color error = Color(0xFFE41E3F);
  static const Color warning = Color(0xFFF79F1A);
  static const Color info = Color(0xFF5851DB);

  // WhatsApp
  static const Color whatsapp = Color(0xFF25D366);

  // Accent colors
  static const Color accentOrange = Color(0xFFFF6B35);

  // Tons de cinza (gray scale)
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1877F2), Color(0xFF0C63E4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Opacidades
  static Color primaryBlueWithOpacity(double opacity) =>
      primaryBlue.withValues(alpha: opacity);
  static Color darkGrayWithOpacity(double opacity) =>
      darkGray.withValues(alpha: opacity);
  static Color whiteWithOpacity(double opacity) =>
      white.withValues(alpha: opacity);
}
