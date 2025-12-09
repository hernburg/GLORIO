import 'package:flutter/material.dart';

class AuthRepo extends ChangeNotifier {
  bool isLoggedIn = false;

  void login() {
    print("AUTH LOGIN()");
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}