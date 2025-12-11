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
              'Дата: ${sale.date.day}.${sale.date.month}.${sale.date.year}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Цена: ${sale.price.toStringAsFixed(0)} ₽',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Товар: ${sale.product.name}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Клиент: ${sale.clientName ?? 'Без клиента'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Продавец: ${sale.soldBy}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ингредиенты',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sale.ingredients.map(
              (ing) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(ing.materialName),
                subtitle: Text('Количество: ${ing.usedQuantity}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
