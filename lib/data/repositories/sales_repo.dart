import 'package:flutter/foundation.dart';
import '../models/sale.dart';

class SalesRepo extends ChangeNotifier {
  final List<Sale> _sales = [];

  List<Sale> get sales => List.unmodifiable(_sales);

  void addSale(Sale sale) {
    _sales.add(sale);
    notifyListeners();
  }

  void updateSale(Sale sale) {
    final index = _sales.indexWhere((s) => s.id == sale.id);
    if (index == -1) return;
    _sales[index] = sale;
    notifyListeners();
  }

  void deleteSale(String saleId) {
    _sales.removeWhere((s) => s.id == saleId);
    notifyListeners();
  }

  double getTotalForDate(DateTime date) {
    return _sales
        .where((s) =>
            s.date.year == date.year &&
            s.date.month == date.month &&
            s.date.day == date.day)
        .fold(0.0, (sum, s) => sum + s.total);
  }
}