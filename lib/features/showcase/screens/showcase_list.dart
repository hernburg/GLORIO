import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/app_card.dart';
import '../../../ui/add_button.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';

import '../../../data/models/assembled_product.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/sold_ingredient.dart';
import '../../../data/models/client.dart';

import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/auth_repo.dart';
import '../../../data/repositories/clients_repo.dart';

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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom + 96,
          right: 6,
        ),
        child: AddButton(
          onTap: () => router.push('/assemble'),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: GlorioSpacing.page,
                  right: GlorioSpacing.page,
                  top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
                ),
                child: Text(
                  'Пока витрина пуста\nНажмите +, чтобы собрать букет',
                  textAlign: TextAlign.center,
                  style: GlorioText.muted,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.only(
                left: GlorioSpacing.page,
                right: GlorioSpacing.page,
                top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
                bottom: MediaQuery.of(context).viewPadding.bottom + GlorioSpacing.page,
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
            style: GlorioText.heading,
          ),

          const SizedBox(height: 6),

          /// Цена и себестоимость
          Row(
            children: [
              Text('Цена: ${item.sellingPrice.toStringAsFixed(0)} ₽', style: GlorioText.body),
              const SizedBox(width: 12),
              Text('Себест.: ${item.costPrice.toStringAsFixed(0)} ₽', style: GlorioText.muted),
            ],
          ),

          if (isBroken) ...[
            SizedBox(height: GlorioSpacing.gapSmall),
            Text('Требует корректировки состава', style: GlorioText.muted.copyWith(color: GlorioColors.accent)),
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
  final clientsRepo = context.read<ClientsRepo>();

  // Capture messenger before awaiting UI operations to avoid using context after await
  final messenger = ScaffoldMessenger.of(context);

  final selection = await pickClient(context);
  if (selection == null) return;
  if (!context.mounted) return;

  final client = selection.withoutClient ? null : selection.client;

  int usedPoints = 0;
  double finalTotal = item.sellingPrice;
  int earnedPoints = 0;

  if (client != null) {
    usedPoints = await _askUsedPoints(context, client) ?? 0;
    usedPoints = usedPoints.clamp(0, client.pointsBalance);
    finalTotal = (item.sellingPrice - usedPoints).clamp(0, double.infinity);
    earnedPoints = (finalTotal * client.cashbackPercent / 100).floor();

    final updatedClient = client.copyWith(
      pointsBalance: client.pointsBalance - usedPoints + earnedPoints,
    );
    clientsRepo.updateClient(updatedClient);
  }

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      product: item,
      quantity: 1,
      price: item.sellingPrice,
      date: DateTime.now(),
      clientId: client?.id,
      clientName: client?.name,
      soldBy: authRepo.currentUserLogin,
      usedPoints: usedPoints,
      finalTotal: finalTotal,
      paymentMethod: 'Наличные',
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

  Future<int?> _askUsedPoints(BuildContext context, Client client) async {
    final ctrl = TextEditingController(text: '0');

    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Списать баллы'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Доступно: ${client.pointsBalance}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(ctrl.text.trim()) ?? 0;
                Navigator.pop(ctx, value);
              },
              child: const Text('Применить'),
            ),
          ],
        );
      },
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
      icon: Icon(icon, color: GlorioColors.textMuted),
      tooltip: tooltip,
      onPressed: onTap,
    );
  }
}