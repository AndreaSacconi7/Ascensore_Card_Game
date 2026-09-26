import 'package:flutter/material.dart';

/// Colours of the app: a night-blue room, a green felt table and gold for whatever needs attention
/// (your turn, the briscola, the winner).
class AppColors {
  AppColors._();

  static const backgroundTop = Color(0xFF1B2257);
  static const background = Color(0xFF0A0F26);
  static const sheet = Color(0xFF141A3C);

  /// Translucent layers over the background.
  static const surface = Color(0x14FFFFFF);
  static const surfaceStrong = Color(0x26FFFFFF);
  static const border = Color(0x24FFFFFF);

  static const gold = Color(0xFFF5C451);
  static const goldDeep = Color(0xFFE39A2F);
  static const onGold = Color(0xFF2A1A00);

  static const felt = Color(0xFF1C6E53);
  static const feltEdge = Color(0xFF0B3A2C);

  static const success = Color(0xFF34D399);
  static const danger = Color(0xFFF87171);

  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xC7FFFFFF);
  static const textMuted = Color(0x8AFFFFFF);

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFFBDD7E), gold, goldDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadius {
  AppRadius._();

  static const small = 12.0;
  static const medium = 18.0;
  static const large = 28.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: AppColors.onGold,
      secondary: AppColors.success,
      surface: AppColors.sheet,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: Brightness.dark);
    final text = base.textTheme.apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4),
        bodyMedium: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.sheet,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.sheet,
        showDragHandle: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large))),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.gold),
    );
  }
}
