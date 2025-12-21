import 'package:hive/hive.dart';

part 'sold_ingredient.g.dart';

@HiveType(typeId: 23)
class SoldIngredient {
  @HiveField(0)
  final String materialKey;

  @HiveField(1)
  final double quantity;

  @HiveField(2)
  final double costPerUnit;

  @HiveField(3)
  final String materialName;

  SoldIngredient({
    required this.materialKey,
    required this.quantity,
    required this.costPerUnit,
    required this.materialName,
  });

  double get totalCost => quantity * costPerUnit;
}