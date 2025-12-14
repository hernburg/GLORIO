import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/materialitem.dart';

class MaterialsRepo extends ChangeNotifier {
  static const boxName = 'materialsBox';

  Box<MaterialItem>? _box;
  bool _isReady = false;

  // ---------------------------------------------------------------------------
  // SAFE GETTERS
  // ---------------------------------------------------------------------------
  bool get isReady => _isReady;

  List<MaterialItem> get materials {
    if (!_isReady || _box == null) return [];
    return _box!.values.toList();
  }

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------
  Future<void> init() async {
    if (_isReady) return;

    _box = await Hive.openBox<MaterialItem>(boxName);
    _isReady = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------
  void addMaterial(MaterialItem item) {
    if (!_isReady || _box == null) return;
    _box!.put(item.id, item); // id == materialKey
    notifyListeners();
  }

  /// 🔑 ОСНОВНОЙ МЕТОД
  MaterialItem? getByKey(String materialKey) {
    if (!_isReady || _box == null) return null;
    return _box!.get(materialKey
    );
  }

  bool exists(String materialKey) {
    if (!_isReady || _box == null) return false;
    return _box!.containsKey(materialKey);
  }

  void reduceQuantity(String materialKey, double qty) {
    if (!_isReady || _box == null) return;

    final m = _box!.get(materialKey);
    if (m == null || m.isInfinite) return;

    final newQty = (m.quantity - qty).clamp(0, double.infinity).toDouble();

    _box!.put(materialKey, m.copyWith(quantity: newQty));
    notifyListeners();
  }

  void returnQuantity(String materialKey, double qty) {
    if (!_isReady || _box == null) return;

    final m = _box!.get(materialKey);
    if (m == null || m.isInfinite) return;

    _box!.put(materialKey, m.copyWith(quantity: m.quantity + qty));
    notifyListeners();
  }

  void removeMaterial(String materialKey) {
    if (!_isReady || _box == null) return;
    _box!.delete(materialKey);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // UPSERT FROM SUPPLY
  // ---------------------------------------------------------------------------
  void upsertFromSupplyItem({
    required String materialKey,
    required String name,
    required String categoryId,
    required String categoryName,
    required double quantity,
    required double costPerUnit,
    required String supplyId,
  }) {
    if (!_isReady || _box == null) return;

    final existing = _box!.get(materialKey);

    if (existing == null) {
      final item = MaterialItem(
        id: materialKey, // 🔑 ключ
        name: name,
        quantity: quantity,
        costPerUnit: costPerUnit,
        supplyId: supplyId,
        categoryId: categoryId,
        categoryName: categoryName,
        isInfinite: false,
        photoUrl: null,
      );

      _box!.put(materialKey, item);
    } else {
      _box!.put(
        materialKey,
        existing.copyWith(
          quantity: existing.quantity + quantity,
          costPerUnit: costPerUnit,
        ),
      );
    }

    notifyListeners();
  }
}