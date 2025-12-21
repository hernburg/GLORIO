import 'package:flutter/material.dart';
import '../design/glorio_colors.dart';
import '../design/glorio_text.dart';
import '../design/glorio_radius.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool primary;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
  final bgColor = primary ? GlorioColors.pale : GlorioColors.card;
  final textColor = GlorioColors.textPrimary;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GlorioRadius.pill),
          ),
        ),
        child: Text(text, style: GlorioText.heading.copyWith(color: textColor)),
      ),
    );
  }
}