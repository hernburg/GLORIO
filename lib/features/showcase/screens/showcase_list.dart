import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/assembled_product.dart';
import '../../../data/models/client.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/sold_ingredient.dart';
import '../../../data/repositories/auth_repo.dart';
import '../../../data/repositories/clients_repo.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';
import '../../../ui/add_button.dart';
import '../../../ui/app_card.dart';
import '../../../ui/app_image.dart';
import '../../sales/widgets/client_selector.dart';

class ShowcaseListScreen extends StatelessWidget {
  const ShowcaseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final showcase = context.watch<ShowcaseRepo>();
    final items = showcase.products;
    final router = GoRouter.of(context);

    return Scaffold(
      backgroundColor: GlorioColors.background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom + 96,
          right: 6,
        ),
        child: AddButton(onTap: () => router.push('/assemble')),
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
              itemBuilder: (context, index) => _ShowcaseCard(item: items[index]),
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
      final exists = materials.any((m) => m.id == ing.materialKey);
      if (!exists) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isBroken = _hasMissingIngredients(context);

    return AppCard(
      onTap: () => context.push('/product_view/${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage.square(item.photoUrl, size: 84),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: GlorioText.heading),
                    const SizedBox(height: 6),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                onTap: () => context.push('/assemble_edit/${item.id}'),
              ),
              const SizedBox(width: 12),
              _ActionIcon(
                icon: Icons.delete_outline,
                tooltip: 'Удалить',
                onTap: () => context.read<ShowcaseRepo>().removeProduct(item.id),
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

    messenger.showSnackBar(
      const SnackBar(content: Text('Букет продан')),
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
                final v = int.tryParse(ctrl.text) ?? 0;
                Navigator.pop(ctx, v);
              },
              child: const Text('Списать'),
            ),
          ],
        );
      },
    );
  }
}

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