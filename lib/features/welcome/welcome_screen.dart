import 'package:flutter/material.dart';

import '../../widgets/liquid_navbar.dart';
import '../../design/glorio_colors.dart';
import '../../design/glorio_spacing.dart';
import '../../design/glorio_text.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlorioColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text(
                  'Система управления цветочным магазином',
                  textAlign: TextAlign.center,
                  style: GlorioText.heading.copyWith(fontSize: 18, color: GlorioColors.accent),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(GlorioSpacing.page, 4, GlorioSpacing.page, GlorioSpacing.page),
          child: LiquidNavbar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
      ),
    );
  }
}
