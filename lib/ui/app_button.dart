import 'package:flutter/material.dart';

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
    final bgColor = primary
        ? const Color(0xFFBFC9B8)
        : Colors.white;

    final textColor = primary
        ? const Color(0xFF2E2E2E)
        : const Color(0xFF2E2E2E);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}