import 'package:flutter/foundation.dart';
import '../models/loyalty.dart';

class LoyaltyRepository extends ChangeNotifier {
  final List<Loyalty> _loyalty = [];

  List<Loyalty> get all => List.unmodifiable(_loyalty);

  Loyalty? getByClient(String clientId) {
    try {
      return _loyalty.firstWhere((l) => l.clientId == clientId);
    } catch (_) {
      return null;
    }
  }

  void addOrUpdate(Loyalty data) {
    final index = _loyalty.indexWhere((l) => l.clientId == data.clientId);
    if (index == -1) {
      _loyalty.add(data);
    } else {
      _loyalty[index] = data;
    }
    notifyListeners();
  }
}
