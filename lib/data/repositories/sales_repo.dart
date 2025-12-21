import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/sale.dart';

class SalesRepo extends ChangeNotifier {
  static const boxName = 'salesBox';

  late Box<Sale> _box;

  List<Sale> get sales => _box.values.toList();

  Sale? getSaleById(String id) => _box.get(id);

  Future<void> init() async {
    _box = await Hive.openBox<Sale>(boxName);
    notifyListeners();
  }

  void addSale(Sale sale) {
    _box.put(sale.id, sale);
    notifyListeners();
  }

  void updateSale(Sale sale) {
    _box.put(sale.id, sale);
    notifyListeners();
  }

  void deleteSale(String saleId) {
    _box.delete(saleId);
    notifyListeners();
  }

  double getTotalForDate(DateTime date) {
    return _box.values
        .where((s) =>
            s.date.year == date.year &&
            s.date.month == date.month &&
            s.date.day == date.day)
        .fold(0.0, (sum, s) => sum + s.total);
  }
}