import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/materialitem.dart';

class MaterialsRepo extends ChangeNotifier {
  static const boxName = 'materialsBox';

  late Box<MaterialItem> _box;

  List<MaterialItem> get materials => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<MaterialItem>(boxName);
    notifyListeners();
  }

  void addMaterial(MaterialItem item) {
    _box.put(item.id, item);
    notifyListeners();
  }

  MaterialItem? getById(String id) {
    return _box.get(id);
  }

  void reduceQuantity(String id, double qty) {
    final m = _box.get(id);
    if (m == null || m.isInfinite) return;

    final double newQty =
        (m.quantity - qty).clamp(0, double.infinity).toDouble();

    _box.put(id, m.copyWith(quantity: newQty));
    notifyListeners();
  }

  void returnQuantity(String id, double qty) {
    final m = _box.get(id);
    if (m == null || m.isInfinite) return;

    final double newQty = (m.quantity + qty).toDouble();

    _box.put(id, m.copyWith(quantity: newQty));
    notifyListeners();
  }

  void removeMaterial(String id) {
    _box.delete(id);
    notifyListeners();
  }
  bool exists(String id) {
  return _box.containsKey(id);
}
}