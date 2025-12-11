import 'package:hive/hive.dart';
import 'assembled_product.dart';

part 'sale.g.dart';

@HiveType(typeId: 10)
class SoldIngredient {
  @HiveField(0)
  final String materialId;

  @HiveField(1)
  final double usedQuantity;

  SoldIngredient({
    required this.materialId,
    required this.usedQuantity,
  });
}

@HiveType(typeId: 11)
class Sale {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final AssembledProduct product;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
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