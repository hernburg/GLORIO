import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 3)
class Ingredient extends HiveObject {
  @HiveField(0)
  final String materialId;

  @HiveField(1)
  final double quantity;

  @HiveField(2)
  final double costPerUnit;

  Ingredient({
    required this.materialId,
    required this.quantity,
    required this.costPerUnit,
  });

  double get totalCost => quantity * costPerUnit;
}