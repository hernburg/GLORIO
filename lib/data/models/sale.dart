import 'package:hive/hive.dart';
import 'assembled_product.dart';
import 'sold_ingredient.dart';
import 'ingredient.dart';

part 'sale.g.dart';

@HiveType(typeId: 22)
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

  @HiveField(6)
  final String? clientId;

  @HiveField(7)
  final String? clientName;

  @HiveField(8)
  final String soldBy;

  Sale({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.date,
    required this.ingredients,
    required this.soldBy,
    this.clientId,
    this.clientName,
  });

  double get total => price * quantity;
}