class Writeoff {
  final String id;
  final String supplyId;
  final int quantity;
  final String reason;
  final DateTime writeoffDate;
  final String employee;

  Writeoff({
    required this.id,
    required this.supplyId,
    required this.quantity,
    required this.reason,
    required this.writeoffDate,
    required this.employee,
  });
}
