import 'package:flutter/material.dart';

class ScreenContentLayout extends StatelessWidget {
  final Widget child;
  final Widget? bottom;

  const ScreenContentLayout({
    super.key,
    required this.child,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        if (bottom != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: bottom!,
          ),
      ],
    );
  }
}
