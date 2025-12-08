class Ingredient {
  /// ID материала (цветок, лента и т.п.)
  final String materialId;

  /// Сколько единиц материала ушло в сборку
  final double quantity;

  /// Себестоимость одной единицы
  final double costPerUnit;

  Ingredient({
    required this.materialId,
    required this.quantity,
    required this.costPerUnit,
  });

  /// Общая себестоимость этого ингредиента
  double get totalCost => quantity * costPerUnit;
}
