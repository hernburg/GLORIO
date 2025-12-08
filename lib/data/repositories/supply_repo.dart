import 'package:flutter/foundation.dart';
import '../models/supply.dart';
import '../models/materialitem.dart';
import 'materials_repo.dart';

class SupplyRepository extends ChangeNotifier {
  final List<Supply> _supplies = [];

  List<Supply> get supplies => List.unmodifiable(_supplies);

  void addSupply(Supply supply) {
    _supplies.add(supply);
    notifyListeners();
  }

  Supply? getById(String id) {
    try {
      return _supplies.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void removeSupply(String id) {
    _supplies.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Добавить поставку + создать материал
  void addSupplyAndMaterial(Supply supply, MaterialsRepo materials) {
    addSupply(supply);

    materials.addMaterial(
      MaterialItem(
        id: supply.id,
        name: supply.name,
        quantity: supply.quantity,
        costPerUnit: supply.purchasePrice,
        supplyId: supply.id,
        photoUrl: null,
        categoryId: 'flowers',
        categoryName: 'Цветы',
        isInfinite: false,
      ),
    );
  }

  /// Списание в букеты
  void consumeFromSupply(String supplyId, double qty) {
    final supply = getById(supplyId);
    if (supply == null) return;

    final updated = supply.copyWith(
      usedInBouquets: supply.usedInBouquets + qty,
    );

    _update(updated);
  }

  /// Возврат при удалении ингредиента
  void returnFromBouquet(String supplyId, double qty) {
    final supply = getById(supplyId);
    if (supply == null) return;

    double used = supply.usedInBouquets - qty;
    if (used < 0) used = 0;

    final updated = supply.copyWith(
      usedInBouquets: used,
    );

    _update(updated);
  }

  /// Ручное списание
  void writeOff(String supplyId, double qty) {
    final supply = getById(supplyId);
    if (supply == null) return;

    final updated = supply.copyWith(
      writtenOff: supply.writtenOff + qty,
    );

    _update(updated);
  }

  /// Обновление поставки
  void updateSupply(Supply updated) {
    _update(updated);
  }

  void _update(Supply updated) {
    final index = _supplies.indexWhere((s) => s.id == updated.id);
    if (index == -1) return;

    _supplies[index] = updated;
    notifyListeners();
  }
}