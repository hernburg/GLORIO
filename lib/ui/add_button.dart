import 'dart:ui';
import 'package:flutter/material.dart';
import '../design/glorio_colors.dart';
import '../design/glorio_spacing.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const double lift = 100;

    return SizedBox(
      width: 64,
      height: 64 + lift,
      child: Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GlorioColors.accent.withAlpha((0.85 * 255).round()),
              GlorioColors.pale.withAlpha((0.9 * 255).round()),
            ],
          ),
          border: Border.all(
            color: Colors.white.withAlpha((0.6 * 255).round()),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBEE9FF).withAlpha((0.28 * 255).round()),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withAlpha((0.85 * 255).round()),
              blurRadius: 10,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: const Center(
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1,
                ),
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