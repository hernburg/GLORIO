import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/assembled_product.dart';

class ShowcaseRepo extends ChangeNotifier {
  static const boxName = 'showcaseBox';

  late Box<AssembledProduct> _box;

  List<AssembledProduct> get products => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<AssembledProduct>(boxName);
    notifyListeners();
  }

  void addProduct(AssembledProduct p) {
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