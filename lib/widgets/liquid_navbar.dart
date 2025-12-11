import 'dart:ui';

import 'package:flutter/material.dart';

class LiquidNavbar extends StatelessWidget {
  const LiquidNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.iconScale,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final double iconScale;

  static const _navItems = [
    _NavItem('Поставка', Icons.local_shipping),
    _NavItem('Витрина', Icons.storefront),
    _NavItem('Продажи', Icons.shopping_cart),
    _NavItem('Клиенты', Icons.people),
    _NavItem('Списание', Icons.remove_circle_outline),
    _NavItem('Отчёты', Icons.bar_chart),
  ];

  @override
  Widget build(BuildContext context) {
    final highlightColor = const Color(0xFF0D6B53);
    final baseIconSize = 24.0 * iconScale;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = currentIndex == index;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.18) : null,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: highlightColor.withOpacity(0.45),
                              blurRadius: 18,
                              spreadRadius: 1.2,
                            ),
                          ]
                        : null,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onTap(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: baseIconSize,
                            color: isActive
                                ? highlightColor
                                : const Color(0xFF0D1B26),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? highlightColor
                                  : const Color(0xFF0D1B26).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
