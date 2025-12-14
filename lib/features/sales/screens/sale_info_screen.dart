import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/sales_repo.dart';

class SaleInfoScreen extends StatelessWidget {
  final String saleId;

  const SaleInfoScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    final sale = context.watch<SalesRepo>().getSaleById(saleId);

    if (sale == null) {
      return const Scaffold(
        body: Center(child: Text('Продажа не найдена')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация о продаже'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              sale.product.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Цена за единицу: ${sale.price.toStringAsFixed(0)} ₽'),
            Text('Количество: ${sale.quantity}'),
            Text('Итого: ${sale.total.toStringAsFixed(0)} ₽'),
            const SizedBox(height: 8),
            Text(
              'Дата: ${sale.date.day}.${sale.date.month}.${sale.date.year}',
            ),
            Text('Клиент: ${sale.clientName ?? 'Без клиента'}'),
            Text('Продавец: ${sale.soldBy.isEmpty ? '—' : sale.soldBy}'),
            const SizedBox(height: 16),
            const Text(
              'Ингредиенты',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sale.ingredients.map(
              (ing) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(ing.materialName ?? ing.materialKey),
                subtitle: Text('Количество: ${ing.quantity}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
