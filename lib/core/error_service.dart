import 'package:flutter/material.dart';

class ErrorService extends ChangeNotifier {
  String? _lastError;

  String? get lastError => _lastError;

  void report(String message) {
    _lastError = message;
    notifyListeners();
  }

  void clear() {
    _lastError = null;
    notifyListeners();
  }
}
