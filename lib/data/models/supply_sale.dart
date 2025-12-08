class Sale {
  final String id;
  final String supplyId;
  final String? clientId;
  final int quantity;
  final double salePrice;
  final DateTime saleDate;

  Sale({
    required this.id,
    required this.supplyId,
    this.clientId,
    required this.quantity,
    required this.salePrice,
    required this.saleDate,
  });

  double get total => quantity * salePrice;
}
