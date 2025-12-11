import 'dart:ui';

import 'package:flutter/material.dart';

class LiquidNavbar extends StatefulWidget {
  const LiquidNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<LiquidNavbar> createState() => _LiquidNavbarState();
}

class _LiquidNavbarState extends State<LiquidNavbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  late final Animation<double> wave;

  static const _navItems = [
    _NavItem('Поставка', Icons.local_shipping),
    _NavItem('Витрина', Icons.storefront),
    _NavItem('Продажи', Icons.shopping_cart),
    _NavItem('Клиенты', Icons.people),
    _NavItem('Списание', Icons.remove_circle_outline),
    _NavItem('Отчёты', Icons.bar_chart),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    wave = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFF0D6B53);

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 82,
          color: Colors.white.withOpacity(0.25),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = widget.currentIndex == index;
              final iconScale = isActive ? 1.05 : 1.0;

              return GestureDetector(
                onTap: () => widget.onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: iconScale,
                      child: Icon(
                        item.icon,
                        size: 24,
                        color: isActive ? highlightColor : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isActive)
                      AnimatedBuilder(
                        animation: wave,
                        builder: (context, _) {
                          return Container(
                            height: 6 * wave.value,
                            width: 26 * iconScale,
                            decoration: BoxDecoration(
                              color: highlightColor.withOpacity(0.30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      )
                    else
                      const SizedBox(height: 6),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? highlightColor : Colors.black54,
                      ),
                    ),
                  ],
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
