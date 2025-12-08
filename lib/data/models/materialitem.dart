import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class MaterialItem {
  final String id;
  final String name;
  final double quantity;        // Текущий остаток
  final double costPerUnit;     // Себестоимость
  final String? photoUrl;       // Фото материала
  final String supplyId;        // Из какой поставки
  final String categoryId;      // Категория (цветы, трава, упаковка...)
  final String categoryName;    // Название категории для отображения
  final bool isInfinite;        // Неиссякаемый материал (лента, упаковка)

  MaterialItem({
    String? id,
    required this.name,
    required this.quantity,
    required this.costPerUnit,
    required this.supplyId,
    this.photoUrl,
    required this.categoryId,
    required this.categoryName,
    this.isInfinite = false,
  }) : id = id ?? _uuid.v4();

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
