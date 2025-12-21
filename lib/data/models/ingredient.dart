import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 21) // выбери ID, которого точно нет в проекте
class Ingredient {
  @HiveField(0)
  final String materialKey;

  @HiveField(1)
  final double quantity;

  @HiveField(2)
  final double costPerUnit;

  Ingredient({
    required this.materialKey,
    required this.quantity,
    required this.costPerUnit,
  });

  double get totalCost => quantity * costPerUnit;

  Ingredient copyWith({
    double? quantity,
    double? costPerUnit,
  }) {
    return Ingredient(
      materialKey: materialKey,
      quantity: quantity ?? this.quantity,
      costPerUnit: costPerUnit ?? this.costPerUnit,
    );
  }
}