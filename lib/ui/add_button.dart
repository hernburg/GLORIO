import 'dart:ui';
import 'package:flutter/material.dart';
import '../design/glorio_colors.dart';
import '../design/glorio_radius.dart';
import '../design/glorio_text.dart';
import '../design/glorio_shadows.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GlorioColors.accent.withAlpha((0.22 * 255).round()),
            border: Border.all(
              color: GlorioColors.border.withAlpha((0.6 * 255).round()),
              width: 1.0,
            ),
            boxShadow: [
              ...GlorioShadows.card,
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(GlorioRadius.pill),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Center(
                child: Text(
                  '+',
                  style: GlorioText.heading.copyWith(
                    fontSize: 32,
                    color: GlorioColors.textPrimary,
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