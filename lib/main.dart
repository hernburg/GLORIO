import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app_router.dart';

class FlowerApp extends StatelessWidget {
  const FlowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = context.watch<AppRouter>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.router,   // ← ВАЖНО!
      theme: _glorioSkyGlassTheme(),
    );
  }

  ThemeData _glorioSkyGlassTheme() {
    // осталась твоя тема, оставляй как есть
    const baseSeed = Color(0xFF74C8FF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: baseSeed,
      brightness: Brightness.light,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFB8E2F5),
      // ... остальное без изменений ...
    );
  }
}