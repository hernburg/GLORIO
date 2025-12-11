import 'package:flutter/material.dart';

import '../../widgets/liquid_navbar.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentIndex = 0;
  double _iconScale = 1.0;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF0F8F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo/glorio_logo.png',
                width: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              const Text(
                'Система управления цветочным магазином',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D6B53),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LiquidNavbar(
                currentIndex: _currentIndex,
                iconScale: _iconScale,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                },
              ),
              const SizedBox(height: 12),
              Slider(
                value: _iconScale,
                min: 0.8,
                max: 1.4,
                activeColor: const Color(0xFF0D6B53),
                inactiveColor: const Color(0xFF0D6B53).withOpacity(0.25),
                onChanged: (value) {
                  setState(() => _iconScale = value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
