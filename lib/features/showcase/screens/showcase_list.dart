import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/app_card.dart';
import '../../../ui/add_button.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';

import '../../../data/models/assembled_product.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/sold_ingredient.dart';

import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/auth_repo.dart';

import '../../sales/widgets/client_selector.dart';

class ShowcaseListScreen extends StatelessWidget {
  const ShowcaseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final showcase = context.watch<ShowcaseRepo>();
    final items = showcase.products;
    // Capture router from context to avoid using BuildContext across async gaps
    final router = GoRouter.of(context);

    return Scaffold(
      backgroundColor: GlorioColors.background,
      floatingActionButton: AddButton(
        onTap: () => router.push('/assemble'),
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: GlorioSpacing.page,
                  right: GlorioSpacing.page,
                  top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
                ),
                child: const Text(
                  'Пока витрина пуста\nНажмите +, чтобы собрать букет',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.only(
                left: GlorioSpacing.page,
                right: GlorioSpacing.page,
                top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
                bottom: GlorioSpacing.page,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ShowcaseCard(item: items[index]);
              },
            ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// КАРТОЧКА БУКЕТА (private, живёт только в этом файле)
/// ---------------------------------------------------------------------------
class _ShowcaseCard extends StatelessWidget {
  final AssembledProduct item;

  const _ShowcaseCard({required this.item});

  bool _hasMissingIngredients(BuildContext context) {
    final materials = context.read<MaterialsRepo>().materials;

    for (final ing in item.ingredients) {
      final exists = materials.any((m) => m.id == ing.materialKey);
      if (!exists) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isBroken = _hasMissingIngredients(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Название
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E2E2E),
            ),
          ),

          const SizedBox(height: 6),

          /// Цена и себестоимость
          Row(
            children: [
              Text(
                'Цена: ${item.sellingPrice.toStringAsFixed(0)} ₽',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Себест.: ${item.costPrice.toStringAsFixed(0)} ₽',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A7A7A),
                ),
              ),
            ],
          ),

          if (isBroken) ...[
            const SizedBox(height: 6),
            const Text(
              'Требует корректировки состава',
              style: TextStyle(
                fontSize: 13,
                color: Colors.redAccent,
              ),
            ),
          ],

          const SizedBox(height: 12),

          /// Действия
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionIcon(
                icon: Icons.shopping_cart_checkout,
                tooltip: 'Продать',
                onTap: () => _sell(context),
              ),
              const SizedBox(width: 12),
              _ActionIcon(
                icon: Icons.settings,
                tooltip: 'Редактировать',
                onTap: () {
                  context.push('/assemble_edit/${item.id}');
                },
              ),
              const SizedBox(width: 12),
              _ActionIcon(
                icon: Icons.delete_outline,
                tooltip: 'Удалить',
                onTap: () {
                  context.read<ShowcaseRepo>().removeProduct(item.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sell(BuildContext context) async {
    final showcaseRepo = context.read<ShowcaseRepo>();
    final salesRepo = context.read<SalesRepo>();
    final materialsRepo = context.read<MaterialsRepo>();
    final authRepo = context.read<AuthRepo>();

  // Capture messenger before awaiting UI operations to avoid using context after await
  final messenger = ScaffoldMessenger.of(context);

  final selection = await pickClient(context);
  if (selection == null) return;

  final client = selection.withoutClient ? null : selection.client;

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      product: item,
      quantity: 1,
      price: item.sellingPrice,
      date: DateTime.now(),
      clientId: client?.id,
      clientName: client?.name,
      soldBy: authRepo.currentUserLogin,
      ingredients: item.ingredients.map((ing) {
        final material = materialsRepo.getByKey(ing.materialKey);
        return SoldIngredient(
          materialKey: ing.materialKey,
          quantity: ing.quantity,
          costPerUnit: ing.costPerUnit,
          materialName: material?.name ?? ing.materialKey,
);
      }).toList(),
    );

    salesRepo.addSale(sale);
    showcaseRepo.removeProduct(item.id);

    // Show snackbar using messenger captured before await
    messenger.showSnackBar(
      const SnackBar(content: Text('\u0411\u0443\u043a\u0435\u0442 \u043f\u0440\u043e\u0434\u0430\u043d')),
    );
  }
}

/// ---------------------------------------------------------------------------
/// ИКОНКА ДЕЙСТВИЯ (private helper)
/// ---------------------------------------------------------------------------
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFF7A7A7A)),
      tooltip: tooltip,
      onPressed: onTap,
    );
  }
}