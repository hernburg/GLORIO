import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import '../design/glorio_theme.dart';
import '../core/error_service.dart';

class FlowerApp extends StatelessWidget {
  const FlowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = context.read<AppRouter>();

    return MaterialApp.router(
      routerConfig: appRouter.router,
      debugShowCheckedModeBanner: false,
      theme: GlorioTheme.theme(),
      builder: (context, child) {
        final childWidget = child ?? const SizedBox.shrink();
        final err = context.watch<ErrorService>().lastError;

        if (err == null) return childWidget;

        return Stack(
          children: [
            childWidget,
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).padding.top,
              child: Material(
                color: Colors.red.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(err, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}