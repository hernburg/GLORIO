import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../design/glorio_colors.dart';
import '../../design/glorio_shadows.dart';
// unused import removed

class GlorioTabBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlorioTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<GlorioTabBar> createState() => _GlorioTabBarState();
}

class _GlorioTabBarState extends State<GlorioTabBar>
    with TickerProviderStateMixin {
  late final AnimationController _stretchController;
  late final AnimationController _introController;

  /// ❗️НЕ const
  static final List<_TabConfig> _tabs = [
    _TabConfig(Icons.inventory_2_outlined, 'Поставки'),
    _TabConfig(Icons.storefront_outlined, 'Витрина'),
    _TabConfig(Icons.shopping_cart_outlined, 'Продажи'),
    _TabConfig(Icons.group_outlined, 'Клиенты'),
    _TabConfig(Icons.delete_sweep_outlined, 'Списания'),
    _TabConfig(Icons.bar_chart_outlined, 'Отчёты'),
  ];

  @override
  void initState() {
    super.initState();

    _stretchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant GlorioTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _stretchController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _stretchController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = _tabs.length;
    final step = 2 / (count - 1);
    final alignX = -1 + step * widget.currentIndex;

    return SafeArea(
      child: AnimatedBuilder(
        animation: _introController,
        builder: (context, child) {
          final t = Curves.easeOutCubic.transform(_introController.value);
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 20),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),

              /// 🧊 СТЕКЛО (без собственного фона)
                child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: GlorioColors.card.withAlpha((0.08 * 255).round()),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: GlorioColors.border.withAlpha((0.35 * 255).round()),
                    width: 1.1,
                  ),
                  boxShadow: GlorioShadows.card,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// 💧 ПУЗЫРЬ
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(alignX, 0),
                      child: AnimatedBuilder(
                        animation: _stretchController,
                        builder: (context, _) {
                          final t = _stretchController.value;
                          final stretch =
                              1 + 0.8 * math.sin(t * math.pi);
                          final widthFactor = (1 / count) * stretch;

                          return FractionallySizedBox(
                            widthFactor: widthFactor,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 16,
                                  sigmaY: 16,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                        colors: [
                                          GlorioColors.card.withAlpha((0.55 * 255).round()),
                                          GlorioColors.cardAlt.withAlpha((0.30 * 255).round()),
                                          GlorioColors.card.withAlpha((0.35 * 255).round()),
                                        ],
                                    ),
                                      border: Border.all(
                                      color: GlorioColors.border.withAlpha((0.45 * 255).round()),
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    /// 🔘 ИКОНКИ
                    Row(
                      children: List.generate(
                        count,
                        (i) => Expanded(
                          child: _NavItem(
                            icon: _tabs[i].icon,
                            label: _tabs[i].label,
                            isActive: widget.currentIndex == i,
                            onTap: () => widget.onTap(i),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// MODELS
/// ---------------------------------------------------------------------------

class _TabConfig {
  final IconData icon;
  final String label;

  const _TabConfig(this.icon, this.label);
}

/// ---------------------------------------------------------------------------
/// ITEM
/// ---------------------------------------------------------------------------

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
  final activeColor = GlorioColors.accent;
  final inactiveColor = GlorioColors.textMuted;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 1,
              end: isActive ? 1.18 : 1,
            ),
            duration: const Duration(milliseconds: 340),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}