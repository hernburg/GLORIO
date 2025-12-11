import 'package:flutter/material.dart';

class AuthRepo extends ChangeNotifier {
  bool isLoggedIn = false;
  String currentUserLogin = '';

  void login({required String login}) {
    isLoggedIn = true;
    currentUserLogin = login;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    currentUserLogin = '';
    notifyListeners();
  }
}