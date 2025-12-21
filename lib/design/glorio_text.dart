import 'package:flutter/material.dart';
import 'glorio_colors.dart';

class GlorioText {
  GlorioText._();

  static const TextStyle heading = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: GlorioColors.textPrimary);
  static const TextStyle body = TextStyle(fontSize: 15, color: GlorioColors.textPrimary, height: 1.3);
  static const TextStyle muted = TextStyle(fontSize: 14, color: GlorioColors.textMuted);
}
