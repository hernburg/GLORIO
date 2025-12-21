import 'package:hive/hive.dart';

part 'supply_item.g.dart';

@HiveType(typeId: 6)
class SupplyItem extends HiveObject {
  @HiveField(0)
  final String materialKey; // КЛЮЧ МАТЕРИАЛА (name+category)

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final String categoryName;

  @HiveField(4)
  final double quantity;

  @HiveField(5)
  final double costPerUnit;

  SupplyItem({
    required this.materialKey,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.quantity,
    required this.costPerUnit,
  });

  double get totalCost => quantity * costPerUnit;

  SupplyItem copyWith({
    double? quantity,
    double? costPerUnit,
  }) {
    return SupplyItem(
      materialKey: materialKey,
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
      quantity: quantity ?? this.quantity,
      costPerUnit: costPerUnit ?? this.costPerUnit,
    );
  }
}