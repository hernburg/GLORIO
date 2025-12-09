import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootShell extends StatelessWidget {
  final Widget child;

  const RootShell({super.key, required this.child});

    static const Color glorio = Color.fromARGB(105, 255, 255, 255);
    static const Color glorio2 = Color.fromARGB(105, 190, 238, 255);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int index = 0;
    if (location.startsWith('/supplies')) index = 0;
    if (location.startsWith('/showcase')) index = 1;
    if (location.startsWith('/sales')) index = 2;
    if (location.startsWith('/clients')) index = 3;
    if (location.startsWith('/writeoff')) index = 4;
    if (location.startsWith('/reports')) index = 5;

    void onTap(int i) {
      switch (i) {
        case 0:
          context.go('/supplies');
          break;
        case 1:
          context.go('/showcase');
          break;
        case 2:
          context.go('/sales');
          break;
        case 3:
          context.go('/clients');
          break;
        case 4:
          context.go('/writeoff');
          break;
        case 5:
          context.go('/reports');
          break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 36),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(70, 162, 165, 240).withOpacity(0.40),
                      const Color.fromARGB(78, 43, 174, 255).withOpacity(0.25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7),
                    width: 1.3,
                  ),
                ),
                child: SizedBox(
                  height: 64,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const itemsCount = 6;
                      // -1 ... 1 по оси X, равномерно по количеству пунктов
                      final step = 2 / (itemsCount - 1);
                      final alignX = -1 + step * index;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Пузырь-лупа под активным пунктом
                          AnimatedAlign(
                          duration: const Duration(milliseconds: 260),
                         curve: Curves.easeOutCubic,
                          alignment: Alignment(alignX, 0),
                            child: FractionallySizedBox(
                             widthFactor: 1 / itemsCount,
                             child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            // более «стеклянная» прозрачность
            gradient:
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.45),
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.28),
                ],
              ),
            
            // светлый стеклянный блик по контуру
             border: Border.all(
              color: Colors.white.withOpacity(0.45),
              width: 1.6,
            ),

            // мягкая тень для объёма
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 24, 255, 243).withOpacity(0.08),
                blurRadius: 5,
                offset: const Offset(0, 9),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),
                        

                          // Ряд пунктов поверх пузыря
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.inventory_2_outlined,
                                  label: "Поставки",
                                  isActive: index == 0,
                                  onTap: () => onTap(0),
                                ),
                              ),
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.storefront_outlined,
                                  label: "Витрина",
                                  isActive: index == 1,
                                  onTap: () => onTap(1),
                                ),
                              ),
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.shopping_cart_outlined,
                                  label: "Продажи",
                                  isActive: index == 2,
                                  onTap: () => onTap(2),
                                ),
                              ),
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.group_outlined,
                                  label: "Клиенты",
                                  isActive: index == 3,
                                  onTap: () => onTap(3),
                                ),
                              ),
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.delete_sweep_outlined,
                                  label: "Списания",
                                  isActive: index == 4,
                                  onTap: () => onTap(4),
                                ),
                              ),
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.bar_chart_outlined,
                                  label: "Отчёты",
                                  isActive: index == 5,
                                  onTap: () => onTap(5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const Color monceauGreen = Color(0xFF1A3E2A);

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Color.fromARGB(255, 166, 190, 232);
    final inactiveColor = Colors.grey.shade600;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isActive ? 1.15 : 1.0, // +15% как ты просил
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Icon(
              icon,
              size: 24,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isActive ? 12.5 : 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}