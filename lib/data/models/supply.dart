import 'package:hive/hive.dart';
import 'supply_item.dart';

part 'supply.g.dart';

@HiveType(typeId: 7) // проверь свой typeId
class Supply extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<SupplyItem> items;

  Supply({
    required this.id,
    required this.date,
    required this.items,
  });

  double get totalCost => items.fold(0, (sum, i) => sum + i.totalCost);
  Supply copyWith({
  List<SupplyItem>? items,
  DateTime? date,
}) {
  return Supply(
    id: id,
    date: date ?? this.date,
    items: items ?? this.items,
  );
}
double get totalQuantity =>
    items.fold(0.0, (sum, item) => sum + item.quantity);
}