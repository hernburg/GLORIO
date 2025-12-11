import 'package:hive/hive.dart';

part 'sold_ingredient.g.dart';

@HiveType(typeId: 21)
class SoldIngredient {
  @HiveField(0)
  final String materialId;

  @HiveField(1)
  final double usedQuantity;

  @HiveField(2)
  final String? materialName;

  SoldIngredient({
    required this.materialId,
    required this.usedQuantity,
    this.materialName,
  });
}