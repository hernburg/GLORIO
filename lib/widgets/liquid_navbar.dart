import 'package:flutter/material.dart';

class LiquidNavbar extends StatelessWidget {
  const LiquidNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

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

    return Container(
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
                      size: 24,
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
          );
        }),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
