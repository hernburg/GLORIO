import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/supply.dart';
import '../models/materialitem.dart';
import 'materials_repo.dart';

class SupplyRepository extends ChangeNotifier {
  static const boxName = 'suppliesBox';

  late Box<Supply> _box;

  List<Supply> get supplies => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<Supply>(boxName);
    notifyListeners();
  }

  Supply? getById(String id) => _box.get(id);

  void addSupply(Supply s) {
    _box.put(s.id, s);
    notifyListeners();
  }

  void updateSupply(Supply updated) {
   _box.put(updated.id, updated);
   notifyListeners();
  }

  void removeSupply(String id) {
    _box.delete(id);
    notifyListeners();
  }

  void addSupplyAndMaterial(Supply supply, MaterialsRepo materials) {
    addSupply(supply);

    materials.addMaterial(
      MaterialItem(
        id: supply.id,
        name: supply.name,
        quantity: supply.quantity.toDouble(),
        costPerUnit: supply.purchasePrice.toDouble(),
        supplyId: supply.id,
        photoUrl: supply.photoUrl,
        categoryId: 'flowers',
        categoryName: 'Цветы',
        isInfinite: false,
      ),
    );
  }

  void consumeFromSupply(String id, double qty) {
    final s = getById(id);
    if (s == null) return;

    final double newUsed = (s.usedInBouquets + qty).toDouble();

    _box.put(
      id,
      s.copyWith(usedInBouquets: newUsed),
    );
    notifyListeners();
  }

  void returnFromBouquet(String id, double qty) {
    final s = getById(id);
    if (s == null) return;

    final double newUsed =
        (s.usedInBouquets - qty).clamp(0, double.infinity).toDouble();

    _box.put(
      id,
      s.copyWith(usedInBouquets: newUsed),
    );
    notifyListeners();
  }

  void writeOff(String id, double qty) {
    final s = getById(id);
    if (s == null) return;

    final double newWrittenOff = (s.writtenOff + qty).toDouble();

    _box.put(
      id,
      s.copyWith(writtenOff: newWrittenOff),
    );
    notifyListeners();
  }
}