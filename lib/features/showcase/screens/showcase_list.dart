import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/add_button.dart';

import '../../../data/models/assembled_product.dart';
import '../../../data/models/sale.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/materials_repo.dart';

class ShowcaseListScreen extends StatelessWidget {
  const ShowcaseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final showcase = context.watch<ShowcaseRepo>();
    final items = showcase.products;

    return Scaffold(
      floatingActionButton: AddButton(
        onTap: () => context.push('/assemble'),
      ),

      body: items.isEmpty
          ? const Center(
              child: Text(
                'Пока пусто.\nНажмите + чтобы собрать букет',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: 50,
                left: 15,
                right: 15,
                bottom: 50,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _ShowcaseCard(item: items[index]),
            ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  final AssembledProduct item;

  const _ShowcaseCard({required this.item});

  bool _hasMissingIngredients(BuildContext context) {
    final materials = context.read<MaterialsRepo>().materials;

    for (final ing in item.ingredients) {
      final exists = materials.any((m) => m.id == ing.materialId);
      if (!exists) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isBroken = _hasMissingIngredients(context);

    return AppCard(
      title: item.name,
      subtitles: [
        'Себестоимость: ${item.costPrice.toStringAsFixed(0)} ₽',
        'Цена продажи: ${item.sellingPrice.toStringAsFixed(0)} ₽',
        if (isBroken)
          'Требует корректировки состава'
      ],
      photoUrl: item.photoUrl,

      actions: [
        /// ПРОДАЖА
        AppCardAction(
          icon: Icons.shopping_cart_checkout,
          color: Colors.green,
          onTap: () {
            final showcaseRepo = context.read<ShowcaseRepo>();
            final salesRepo = context.read<SalesRepo>();

            final sale = Sale(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              product: item,
              quantity: 1,
              price: item.sellingPrice,
              date: DateTime.now(),
              ingredients: item.ingredients.map((ing) {
                return SoldIngredient(
                  materialId: ing.materialId,
                  usedQuantity: ing.quantity,
                );
              }).toList(),
            );

            salesRepo.addSale(sale);
            showcaseRepo.removeProduct(item.id);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Букет продан!")),
            );
          },
        ),

        /// РЕДАКТИРОВАНИЕ
        AppCardAction(
          icon: Icons.settings,
          color: const Color.fromARGB(74, 94, 94, 94),
          onTap: () {
            context.pushNamed(
              'assemble_edit',
              pathParameters: {'id': item.id},
              extra: item,
            );
          },
        ),

        /// УДАЛЕНИЕ
        AppCardAction(
          icon: Icons.delete,
          color: Colors.red,
          onTap: () {
            context.read<ShowcaseRepo>().removeProduct(item.id);
          },
        ),
      ],
    );
  }
}