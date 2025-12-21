import 'package:flutter/material.dart';
import '../design/glorio_colors.dart';

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
    final highlightColor = GlorioColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: GlorioColors.card.withAlpha((0.25 * 255).round()),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
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
                    Icon(item.icon, size: 24, color: isActive ? highlightColor : GlorioColors.textPrimary),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? highlightColor : GlorioColors.textMuted,
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
