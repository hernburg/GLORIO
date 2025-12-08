import 'package:flutter/foundation.dart';
import '../models/materialitem.dart';

class MaterialsRepo extends ChangeNotifier {
  final List<MaterialItem> _materials = [];

  List<MaterialItem> get materials => List.unmodifiable(_materials);

  /// Добавление материала из поставки
  void addMaterial(MaterialItem item) {
    _materials.add(item);
    notifyListeners();
  }

  MaterialItem? getById(String id) {
    try {
      return _materials.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Списание (уменьшение) остатка
  void reduceQuantity(String id, double qty) {
    final index = _materials.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final material = _materials[index];

    if (material.isInfinite) return;

    double newQty = material.quantity - qty;
    if (newQty < 0) newQty = 0;

    _materials[index] = material.copyWith(quantity: newQty);
    notifyListeners();
  }

  /// Возврат количества (если удалили ингредиент)
  void returnQuantity(String id, double qty) {
    final index = _materials.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final material = _materials[index];

    if (material.isInfinite) return;

    _materials[index] =
        material.copyWith(quantity: material.quantity + qty);

    notifyListeners();
  }

  /// Полное удаление карточки материала
  void removeMaterial(String id) {
    _materials.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
