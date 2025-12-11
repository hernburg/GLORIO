import 'package:hive/hive.dart';

part 'sold_ingredient.g.dart';

@HiveType(typeId: 21)
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