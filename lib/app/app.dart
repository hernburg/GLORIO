import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import '../design/glorio_theme.dart';
import '../app/router.dart';
import '../ui/widgets/mini_back_button.dart';

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
        final navigator = rootNavigatorKey.currentState;
        final canPop = navigator?.canPop() ?? false;

        // If there's nothing to pop, just return the child.
  if (child == null) return const SizedBox.shrink();
  if (!canPop) return child;

        final padding = MediaQuery.of(context).padding;

        return Stack(
          children: [
            child,
            Positioned(
              top: padding.top + 8,
              left: 12,
              child: MiniBackButton(
                onTap: () => navigator?.maybePop(),
              ),
            ),
          ],
        );
      },
    );
  }
}