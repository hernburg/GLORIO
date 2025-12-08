import 'package:uuid/uuid.dart';
import 'ingredient.dart';

final _uuid = Uuid();

class AssembledProduct {
  final String id;
  final String name;
  final String? photoUrl;
  final List<Ingredient> ingredients;
  final double costPrice;
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

