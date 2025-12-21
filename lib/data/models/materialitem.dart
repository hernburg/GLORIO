import 'package:hive/hive.dart';

part 'materialitem.g.dart';

@HiveType(typeId: 5)
class MaterialItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final double costPerUnit;

  @HiveField(4)
  final String? photoUrl;

  @HiveField(5)
  final String supplyId;

  @HiveField(6)
  final String categoryId;

  @HiveField(7)
  final String categoryName;

  @HiveField(8)
  final bool isInfinite;

  MaterialItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.costPerUnit,
    required this.supplyId,
    this.photoUrl,
    required this.categoryId,
    required this.categoryName,
    this.isInfinite = false,
  });

  double get totalCost => quantity * costPerUnit;

  MaterialItem copyWith({
    String? name,
    double? quantity,
    double? costPerUnit,
    String? photoUrl,
    String? categoryId,
    String? categoryName,
    bool? isInfinite,
  }) {
    return MaterialItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      supplyId: supplyId,
      photoUrl: photoUrl ?? this.photoUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isInfinite: isInfinite ?? this.isInfinite,
    );
  }
}