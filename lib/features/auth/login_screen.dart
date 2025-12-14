import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/auth_repo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? errorText;

  void login() {
    final phone = phoneController.text.trim();
    final pass = passwordController.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      setState(() => errorText = 'Введите телефон и пароль');
      return;
    }

    context.read<AuthRepo>().login(
      context: context,
      login: phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GLORIO',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
              ),

              if (errorText != null) ...[
                const SizedBox(height: 12),
                Text(errorText!, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: login,
                child: const Text('Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}