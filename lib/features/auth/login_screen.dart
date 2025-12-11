import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/auth_repo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? errorText;

  void fakeLogin() {
    debugPrint("FAKE LOGIN CALLED");
    final phone = phoneController.text.trim();
    final pass = passwordController.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      setState(() {
        errorText = "Введите телефон и пароль";
      });
      return;
    }

    /// Фейковая авторизация — можно заменить позже на API
    setState(() {
      errorText = null;
    });

    /// После логина → перейти в приложение с нижним меню
    context.read<AuthRepo>().login(context: context, login: phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Фоновая картинка
          Positioned.fill(
            child: Image.asset(
              'assets/login_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// Лёгкое матовое затемнение, чтобы логотип читался
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Логотип
                  Image.asset(
                    'assets/glorio_logo.png',
                    height: 120,
                  ),

                  const SizedBox(height: 24),

                  /// Поле — телефон
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Телефон",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Поле — пароль
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Пароль",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: 26),

                  /// Кнопка входа
                  GestureDetector(
                    onTap: fakeLogin,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(255, 162, 162, 255),
                            Color.fromARGB(98, 3, 158, 255),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Войти",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}