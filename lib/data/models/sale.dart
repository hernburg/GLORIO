import 'assembled_product.dart';

class SoldIngredient {
  final String materialId;
  final double usedQuantity;

  SoldIngredient({
    required this.materialId,
    required this.usedQuantity,
  });
}

class Sale {
  final String id;
  final dynamic product;
  final int quantity;
  final double price;
  final DateTime date;
  final List<SoldIngredient> ingredients;

  Sale({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.date,
    required this.ingredients,
  });

  double get total => price * quantity;
}

