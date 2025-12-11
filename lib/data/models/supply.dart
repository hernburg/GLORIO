import 'package:hive/hive.dart';

part 'supply.g.dart';

@HiveType(typeId: 6)
class Supply extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final double usedInBouquets;

  @HiveField(4)
  final double writtenOff;

  @HiveField(5)
  final double purchasePrice;

  @HiveField(6)
  final DateTime supplyDate;

  @HiveField(7)
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