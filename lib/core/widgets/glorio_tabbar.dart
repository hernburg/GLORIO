import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

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

  static const _tabs = [
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
              offset: Offset(0, (1 - t) * 20), // подъём снизу
              child: child,
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),

              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(170, 114, 227, 255),
                      Color.fromARGB(102, 75, 177, 255),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: SizedBox(
                  height: 64,

                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [

                          /// 💧 Пузырь
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment(alignX, 0),

                            child: AnimatedBuilder(
                              animation: Listenable.merge([_stretchController, _introController]),
                              builder: (context, child) {
                                final t = _stretchController.value;
                                final intro = Curves.easeOutBack.transform(_introController.value);

                                final stretchK =
                                    1 + 0.8 * math.sin(t * math.pi);

                                final widthFactor = (1 / count) * stretchK;

                                return Transform.scale(
                                  scale: 0.85 + intro * 0.15, // красивое появление
                                  child: FractionallySizedBox(
                                    widthFactor: widthFactor,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 16,
                                          sigmaY: 16,
                                        ),
                                        child: Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withOpacity(0.60),
                                                const Color(0xFFB2FFF3)
                                                    .withOpacity(0.32),
                                                Colors.white.withOpacity(0.35),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.50),
                                              width: 1.6,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color.fromARGB(
                                                  255,
                                                  0,
                                                  255,
                                                  214,
                                                ).withOpacity(0.10),
                                                blurRadius: 10,
                                                offset: const Offset(0, 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          /// 🔘 Пункты меню
                          Row(
                            children: [
                              for (int i = 0; i < count; i++)
                                Expanded(
                                  child: _NavItem(
                                    icon: _tabs[i].icon,
                                    label: _tabs[i].label,
                                    isActive: widget.currentIndex == i,
                                    onTap: () => widget.onTap(i),
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

class _TabConfig {
  final IconData icon;
  final String label;
  const _TabConfig(this.icon, this.label);
}

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
    const activeColor = Color.fromARGB(255, 139, 149, 160);
    final inactiveColor = Colors.grey.shade500;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// 🕊 Подпрыгивание иконки
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 1.0,
              end: isActive ? 1.18 : 1.0,
            ),
            duration: const Duration(milliseconds: 340),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Icon(
              icon,
              size: 24,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),

          const SizedBox(height: 4),

          /// 🕊 Подпрыгивание текста
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 1.0,
              end: isActive ? 1.08 : 1.0,
            ),
            duration: const Duration(milliseconds: 340),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}