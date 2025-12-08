import 'package:flutter/material.dart';
import '../models/assembled_product.dart';
import 'materials_repo.dart';
import 'supply_repo.dart';

class ShowcaseRepo extends ChangeNotifier {
  final List<AssembledProduct> _products = [];

  List<AssembledProduct> get products => List.unmodifiable(_products);

  void addProduct(
    AssembledProduct product,
    MaterialsRepo materials,
    SupplyRepository supplies,
  ) {
    // Списание уже сделано на экране — здесь НИЧЕГО не списываем
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(AssembledProduct updated) {
    final index = _products.indexWhere((p) => p.id == updated.id);
    if (index == -1) return;

    _products[index] = updated;
    notifyListeners();
  }

  void removeProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
