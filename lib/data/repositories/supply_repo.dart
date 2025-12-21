import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/supply.dart';
import '../models/supply_item.dart';
import 'materials_repo.dart';

class SupplyRepository extends ChangeNotifier {
  static const _boxName = 'supplies';

  final MaterialsRepo materialsRepo;
  late Box<Supply> _box;

  SupplyRepository(this.materialsRepo);

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    _box = await Hive.openBox<Supply>(_boxName);
  }

  List<Supply> get supplies => _box.values.toList();

  Supply? getById(String id) {
    return _box.get(id);
  }

  // ---------------------------------------------------------------------------
  // ADD SUPPLY
  // ---------------------------------------------------------------------------

  void addSupply({
    required DateTime date,
    required List<SupplyItem> items,
  }) {
    final supplyId = DateTime.now().millisecondsSinceEpoch.toString();

    final supply = Supply(
      id: supplyId,
      date: date,
      items: items,
    );

    _box.put(supplyId, supply);

    // обновляем склад материалов
    for (final item in items) {
      materialsRepo.upsertFromSupplyItem(
        materialKey: item.materialKey,
        name: item.name,
        categoryId: item.categoryId,
        categoryName: item.categoryName,
        quantity: item.quantity,
        costPerUnit: item.costPerUnit,
        supplyId: supplyId,
      );
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // DELETE SUPPLY
  // ---------------------------------------------------------------------------

  void deleteSupply(String key) {
    _box.delete(key);
    notifyListeners();
  }

  /// Update an existing supply and adjust materials quantities based on deltas
  void updateSupply({
    required String id,
    required DateTime date,
    required List<SupplyItem> items,
  }) {
    final existing = _box.get(id);

    // compute deltas per materialKey
    final Map<String, double> oldMap = {};
    if (existing != null) {
      for (final it in existing.items) {
        oldMap[it.materialKey] = (oldMap[it.materialKey] ?? 0) + it.quantity;
      }
    }

    final Map<String, double> newMap = {};
    for (final it in items) {
      newMap[it.materialKey] = (newMap[it.materialKey] ?? 0) + it.quantity;
    }

    // apply deltas to materialsRepo
    for (final entry in newMap.entries) {
      final key = entry.key;
      final newQty = entry.value;
      final oldQty = oldMap[key] ?? 0.0;
      final delta = newQty - oldQty;

      if (delta > 0) {
        // increase available materials
        materialsRepo.upsertFromSupplyItem(
          materialKey: key,
          name: items.firstWhere((e) => e.materialKey == key).name,
          categoryId: items.firstWhere((e) => e.materialKey == key).categoryId,
          categoryName: items.firstWhere((e) => e.materialKey == key).categoryName,
          quantity: delta,
          costPerUnit: items.firstWhere((e) => e.materialKey == key).costPerUnit,
          supplyId: id,
        );
      } else if (delta < 0) {
        // reduce available materials
        materialsRepo.reduceQuantity(key, -delta);
      }
    }

    // handle keys that existed before but removed in new items
    for (final entry in oldMap.entries) {
      final key = entry.key;
      if (!newMap.containsKey(key)) {
        // removed entirely -> subtract old amount
        materialsRepo.reduceQuantity(key, entry.value);
      }
    }

    // persist updated supply
    final updated = Supply(id: id, date: date, items: items);
    _box.put(id, updated);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // STOCK CALCULATION
  // ---------------------------------------------------------------------------

  double totalAvailable(String materialKey) {
    double total = 0;

    for (final supply in supplies) {
      for (final item in supply.items) {
        if (item.materialKey == materialKey) {
          total += item.quantity;
        }
      }
    }

    return total;
  }

  double getAvailableQty(String materialKey) {
    return totalAvailable(materialKey);
  }

  // ---------------------------------------------------------------------------
  // FIFO CONSUMPTION
  // ---------------------------------------------------------------------------

  void consumeMaterial({
    required String materialKey,
    required double qty,
  }) {
    debugPrint('SupplyRepository.consumeMaterial: material=$materialKey qty=$qty');
    // сразу уменьшаем общий остаток материала
    materialsRepo.reduceQuantity(materialKey, qty);
    final sortedSupplies = [...supplies]
      ..sort((a, b) => a.date.compareTo(b.date));

    double remaining = qty;

    for (final supply in sortedSupplies) {
      if (remaining <= 0) break;

      final updatedItems = <SupplyItem>[];

      for (final item in supply.items) {
        if (item.materialKey != materialKey || remaining <= 0) {
          updatedItems.add(item);
          continue;
        }

        final used =
            remaining <= item.quantity ? remaining : item.quantity;

        remaining -= used;

        updatedItems.add(
          item.copyWith(
            quantity: item.quantity - used,
          ),
        );
      }

      _box.put(
        supply.id,
        supply.copyWith(items: updatedItems),
      );
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // PLACEHOLDERS
  // ---------------------------------------------------------------------------

  void consumeFromSupply({
    required String materialKey,
    required double qty,
  }) {
    notifyListeners();
  }

  void returnFromBouquet({
    required String materialKey,
    required double qty,
  }) {
    notifyListeners();
  }
}