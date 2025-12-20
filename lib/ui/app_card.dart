import 'dart:ui';
import 'package:flutter/material.dart';
import '../design/glorio_colors.dart';
import '../design/glorio_radius.dart';
import '../design/glorio_shadows.dart';
import '../design/glorio_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(GlorioRadius.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding ?? const EdgeInsets.all(GlorioSpacing.card),
          decoration: BoxDecoration(
            color: GlorioColors.card,
            borderRadius: BorderRadius.circular(GlorioRadius.card),
            boxShadow: GlorioShadows.card,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GlorioRadius.card),
          child: card,
        ),
      );
    }

    return card;
  }
}
