import 'assembled_product.dart';

class Sale {
  final String id;
  final AssembledProduct product;
  final int quantity;
  final double price;
  final DateTime date;

  double get total => price * quantity;

  Sale({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.date,
  });
}