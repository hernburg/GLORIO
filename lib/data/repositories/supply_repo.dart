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