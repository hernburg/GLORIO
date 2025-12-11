import 'package:hive/hive.dart';
import 'ingredient.dart';

part 'assembled_product.g.dart';

@HiveType(typeId: 4)
class AssembledProduct extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? photoUrl;

  @HiveField(3)
  final List<Ingredient> ingredients;

  @HiveField(4)
  final double costPrice;

  @HiveField(5)
  final double sellingPrice;

  AssembledProduct({
    String? id,
    required this.name,
    required this.photoUrl,
    required this.ingredients,
    required this.costPrice,
    required this.sellingPrice,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  AssembledProduct copyWith({
    String? name,
    String? photoUrl,
    List<Ingredient>? ingredients,
    double? costPrice,
    double? sellingPrice,
  }) {
    return AssembledProduct(
      id: id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      ingredients: ingredients ?? this.ingredients,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }
}