import 'package:flutter/material.dart';

class GlorioShadows {
  GlorioShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000), // very soft shadow (~4% alpha)
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];
}
