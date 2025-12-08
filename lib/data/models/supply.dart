class Supply {
  final String id;
  final String name;

  /// Всегда double — потому что в остатках у цветов бывают дроби
  final double quantity;

  /// Сколько использовано в букетах
  final double usedInBouquets;

  /// Сколько списано
  final double writtenOff;

  /// Цена закупки (за штуку/ветку)
  final double purchasePrice;

  /// Дата поставки
  final DateTime supplyDate;

  /// Фото (опционально)
  final String? photoUrl;

  Supply({
    required this.id,
    required this.name,
    required this.quantity,
    required this.usedInBouquets,
    required this.writtenOff,
    required this.purchasePrice,
    required this.supplyDate,
    this.photoUrl,
  });

  Supply copyWith({
    String? id,
    String? name,
    double? quantity,
    double? usedInBouquets,
    double? writtenOff,
    double? purchasePrice,
    DateTime? supplyDate,
    String? photoUrl,
  }) {
    return Supply(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      usedInBouquets: usedInBouquets ?? this.usedInBouquets,
      writtenOff: writtenOff ?? this.writtenOff,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      supplyDate: supplyDate ?? this.supplyDate,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}