import 'package:flutter/material.dart';
import 'glorio_colors.dart';
import 'glorio_radius.dart';
// shadows are used by AppCard directly; not required here
import 'glorio_text.dart';

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
        appBarTheme: AppBarTheme(
          backgroundColor: GlorioColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: GlorioColors.textPrimary),
          titleTextStyle: GlorioText.heading,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: GlorioColors.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GlorioRadius.pill)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: GlorioText.heading,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: GlorioColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        // Card theming is handled by individual AppCard widget using tokens
      );
}
