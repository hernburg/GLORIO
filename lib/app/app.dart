import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';

class FlowerApp extends StatelessWidget {
  const FlowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = context.read<AppRouter>();

    return MaterialApp.router(
      routerConfig: appRouter.router,
      debugShowCheckedModeBanner: false,
      theme: _glorioSkyGlassTheme(),
    );
  }
}

  ThemeData _glorioSkyGlassTheme() {
    // Основной фирменный небесный цвет
    const baseSeed = Color(0xFF74C8FF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: baseSeed,
      brightness: Brightness.light,
      surfaceTint: Colors.transparent, // важное! убирает синюшные фильтры M3
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Фон приложения
      scaffoldBackgroundColor: const Color(0xFFB8E2F5),

      // -------------------------------
      // ТЕКСТ
      // -------------------------------
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0D1B26),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D1B26),
        ),
      ),

      // -------------------------------
      // APP BAR — стеклянный
      // -------------------------------
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.20),
        foregroundColor: const Color(0xFF0D1B26),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
      ),

      // -------------------------------
      // FAB — стекло
      // -------------------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.35),
        foregroundColor: Colors.black87,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      // -------------------------------
      // КНОПКИ M3
      // -------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
            baseSeed.withValues(alpha: 0.85),
          ),
          overlayColor: WidgetStatePropertyAll(
            Colors.white.withValues(alpha: 0.15),
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.black87),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),

      // -------------------------------
      // КАРТОЧКИ
      // -------------------------------
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.30),
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // -------------------------------
      // ПОЛЯ ВВОДА
      // -------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: baseSeed.withValues(alpha: 0.9),
            width: 1.4,
          ),
        ),
      ),
    );
  }