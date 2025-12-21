import '../models/writeoff.dart';
import '../repositories/materials_repo.dart';
import '../repositories/supply_repo.dart';
import '../repositories/writeoff_repo.dart';

class WriteoffService {
  final MaterialsRepo materialsRepo;
  final WriteoffRepository writeoffRepo;
  final SupplyRepository supplyRepo;

  WriteoffService({
    required this.materialsRepo,
    required this.writeoffRepo,
    required this.supplyRepo,
  });

  /// Списать испорченный товар с учётом количества и фиксацией причины
  /// Возвращает созданную запись списания
  Writeoff writeoffSpoiled({
    required String materialKey,
    required double quantity,
    required String reason,
    required String employee,
    DateTime? date,
  }) {
    final material = materialsRepo.getByKey(materialKey);
    if (material == null) {
      throw ArgumentError('Материал не найден: $materialKey');
    }
    final double normalizedQty = quantity <= 0 ? 0.0 : quantity;
    if (normalizedQty == 0.0) {
      throw ArgumentError('Количество для списания должно быть > 0');
    }

    final available = material.quantity;
    if (normalizedQty > available) {
      throw ArgumentError('Недостаточно остатка для списания');
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final costPerUnit = material.costPerUnit;

    // уменьшаем остаток на складе и в конкретных поставках (FIFO)
    supplyRepo.consumeMaterial(materialKey: materialKey, qty: normalizedQty);

    final writeoff = Writeoff(
      id: id,
      materialKey: materialKey,
      materialName: material.name,
      quantity: normalizedQty,
      reason: reason,
      writeoffDate: date ?? DateTime.now(),
      employee: employee,
      costPerUnit: costPerUnit,
      supplyId: material.supplyId,
    );

    writeoffRepo.addWriteoff(writeoff);
    return writeoff;
  }
}
