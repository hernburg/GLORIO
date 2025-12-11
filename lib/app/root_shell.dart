import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/glorio_tabbar.dart';

class RootShell extends StatelessWidget {
  final Widget child;
  const RootShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    // Определяем активный пункт меню
    final index = [
      '/supplies',
      '/showcase',
      '/sales',
      '/clients',
      '/writeoff',
      '/reports'
    ].indexWhere((path) => location.startsWith(path));

    final currentIndex = index >= 0 ? index : 0;

    void onTap(int i) {
      const routes = [
        '/supplies',
        '/showcase',
        '/sales',
        '/clients',
        '/writeoff',
        '/reports'
      ];
      context.go(routes[i]);
    }

    return Scaffold(
      body: child,

      // 🔥 Подключаем новый GLORIO Telegram-style таббар
      bottomNavigationBar: GlorioTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}