class Writeoff {
  final String id;
  final String? supplyId;
  final String materialKey;
  final String materialName;
  final double quantity;
  final String reason;
  final DateTime writeoffDate;
  final String employee;
  final double? costPerUnit;

  Writeoff({
    required this.id,
    required this.materialKey,
    required this.materialName,
    required this.quantity,
    required this.reason,
    required this.writeoffDate,
    required this.employee,
    this.costPerUnit,
    this.supplyId,
  });

  double get totalCost => (costPerUnit ?? 0) * quantity;
}
