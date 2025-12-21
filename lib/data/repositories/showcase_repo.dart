import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/assembled_product.dart';

class ShowcaseRepo extends ChangeNotifier {
  static const boxName = 'showcaseBox';

  late Box<AssembledProduct> _box;

  List<AssembledProduct> get products => _box.values.toList();

  AssembledProduct? getById(String id) => _box.get(id);

  Future<void> init() async {
    _box = await Hive.openBox<AssembledProduct>(boxName);
    notifyListeners();
  }

  void addProduct(AssembledProduct p) {
    // If a product with the same id already exists, treat this as an update
    // to avoid accidental duplicates (callers creating a new product should
    // generate a new id instead).
    if (_box.containsKey(p.id)) {
      updateProduct(p);
      return;
    }

    _box.put(p.id, p);
    notifyListeners();
  }

  void updateProduct(AssembledProduct updated) {
    _box.put(updated.id, updated);
    notifyListeners();
  }

  void removeProduct(String id) {
    _box.delete(id);
    notifyListeners();
  }
}