import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/auth_repo.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';

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
      backgroundColor: GlorioColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(GlorioSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GLORIO', style: GlorioText.heading.copyWith(fontSize: 32)),
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
                Text(errorText!, style: GlorioText.body.copyWith(color: GlorioColors.warning)),
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