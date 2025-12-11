import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthRepo extends ChangeNotifier {
  bool isLoggedIn = false;
  String currentUserLogin = '';

  void login({required BuildContext context, required String login}) {
    isLoggedIn = true;
    currentUserLogin = login;
    notifyListeners();
    context.go('/supplies');
  }

  void logout() {
    isLoggedIn = false;
    currentUserLogin = '';
    notifyListeners();
  }
}