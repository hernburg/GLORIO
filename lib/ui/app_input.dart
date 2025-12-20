import 'package:flutter/material.dart';
import '../design/glorio_colors.dart';
import '../design/glorio_radius.dart';
import '../design/glorio_spacing.dart';

class AppInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const AppInput({
  super.key,
  required this.controller,
  required this.hint,
  this.obscure = false,
  this.keyboardType,
  this.errorText,
  this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: GlorioColors.card,
  contentPadding: const EdgeInsets.symmetric(horizontal: GlorioSpacing.card, vertical: 14),
        border: _border(GlorioColors.border),
        enabledBorder: _border(GlorioColors.border),
        focusedBorder: _border(
          GlorioColors.pale,
          width: 1.5,
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
  borderRadius: BorderRadius.circular(GlorioRadius.card),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}