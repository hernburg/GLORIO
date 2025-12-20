import 'package:flutter/material.dart';
import 'glorio_colors.dart';

class GlorioTheme {
  GlorioTheme._();

  static ThemeData theme() => ThemeData(
        scaffoldBackgroundColor: GlorioColors.background,
        primaryColor: GlorioColors.accent,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: GlorioColors.textPrimary),
          bodySmall: TextStyle(color: GlorioColors.textMuted),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: GlorioColors.textPrimary),
        ),
      );
}
