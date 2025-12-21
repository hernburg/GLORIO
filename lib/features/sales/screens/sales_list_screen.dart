import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/app_card.dart';
import '../../../ui/app_button.dart';
import '../../../ui/app_image.dart';

import '../../../data/models/assembled_product.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/sold_ingredient.dart';
import '../../../data/models/client.dart';

import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/supply_repo.dart';
import '../../../data/repositories/auth_repo.dart';
import '../../../data/repositories/clients_repo.dart';

import '../widgets/client_selector.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_text.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_radius.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  int tabIndex = 0; // 0 — В продаже, 1 — Продано

  @override
  Widget build(BuildContext context) {
    final showcase = context.watch<ShowcaseRepo>().products;
    final sales = context.watch<SalesRepo>().sales;

    return Scaffold(
      backgroundColor: GlorioColors.background,
      body: Padding(
        padding: EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
          bottom: GlorioSpacing.page,
        ),
        child: Column(
          children: [
            _buildTabs(),
            const SizedBox(height: GlorioSpacing.gapSmall),
            Expanded(
              child: tabIndex == 0 ? _buildAvailable(showcase) : _buildSold(sales),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABS
  // ---------------------------------------------------------------------------
  Widget _buildTabs() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GlorioRadius.large),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(GlorioSpacing.card),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GlorioRadius.large),
            border: Border.all(color: GlorioColors.border),
            color: GlorioColors.card.withAlpha((0.6 * 255).round()),
          ),
          child: Row(
            children: [
              Expanded(
                child: _tabButton('В продаже', 0),
              ),
              Expanded(
                child: _tabButton('Продано', 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final active = tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => tabIndex = index),
        child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active ? Colors.white : Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // В ПРОДАЖЕ
  // ---------------------------------------------------------------------------
  Widget _buildAvailable(List<AssembledProduct> products) {
    if (products.isEmpty) {
      return Center(child: Text('На витрине пока пусто', style: GlorioText.muted));
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        left: GlorioSpacing.page,
        right: GlorioSpacing.page,
        top: GlorioSpacing.page,
        bottom: MediaQuery.of(context).viewPadding.bottom + GlorioSpacing.page,
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final p = products[i];

        return AppCard(
          onTap: () => context.push('/product_view/${p.id}'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage.square(p.photoUrl, size: 84),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: GlorioText.heading),
                    const SizedBox(height: 6),
                    Text('Себестоимость: ${p.costPrice.toStringAsFixed(0)} ₽', style: GlorioText.muted),
                    Text('Цена продажи: ${p.sellingPrice.toStringAsFixed(0)} ₽', style: GlorioText.body),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Продать',
                            onTap: () => _sell(p),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Удалить',
                            onTap: () => _dismantle(p),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ПРОДАНО
  // ---------------------------------------------------------------------------
  Widget _buildSold(List<Sale> sales) {
    if (sales.isEmpty) {
      return Center(child: Text('Пока нет завершённых продаж', style: GlorioText.muted));
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        left: GlorioSpacing.page,
        right: GlorioSpacing.page,
        top: GlorioSpacing.page,
        bottom: MediaQuery.of(context).viewPadding.bottom + GlorioSpacing.page,
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: sales.length,
      itemBuilder: (_, i) {
        final s = sales[i];
        return AppCard(
          onTap: () => context.push('/sale_info/${s.id}'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage.square(s.product.photoUrl, size: 72),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.product.name, style: GlorioText.heading),
                    const SizedBox(height: 4),
                    Text('Итог: ${s.total.toStringAsFixed(0)} ₽', style: GlorioText.body),
                    Text('Дата: ${s.date.day}.${s.date.month}.${s.date.year}', style: GlorioText.muted),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ПРОДАЖА
  // ---------------------------------------------------------------------------
  Future<void> _sell(AssembledProduct p) async {
    // Capture repos and other context-dependent objects before awaiting
    final salesRepo = context.read<SalesRepo>();
    final showcaseRepo = context.read<ShowcaseRepo>();
    final supplyRepo = context.read<SupplyRepository>();
    final materialsRepo = context.read<MaterialsRepo>();
    final authRepo = context.read<AuthRepo>();
    final clientsRepo = context.read<ClientsRepo>();

    final selection = await pickClient(context);
    if (selection == null) return;

    final client = selection.withoutClient ? null : selection.client;

    int usedPoints = 0;
    double finalTotal = p.sellingPrice;
    int earnedPoints = 0;

    if (client != null) {
      usedPoints = await _askUsedPoints(client) ?? 0;
      usedPoints = usedPoints.clamp(0, client.pointsBalance);
      finalTotal = (p.sellingPrice - usedPoints).clamp(0, double.infinity);
      earnedPoints = (finalTotal * client.cashbackPercent / 100).floor();

      final updatedClient = client.copyWith(
        pointsBalance: client.pointsBalance - usedPoints + earnedPoints,
      );
      clientsRepo.updateClient(updatedClient);
    }

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      product: p,
      quantity: 1,
      price: p.sellingPrice,
      date: DateTime.now(),
      clientId: client?.id,
      clientName: client?.name,
      soldBy: authRepo.currentUserLogin,
      usedPoints: usedPoints,
      finalTotal: finalTotal,
      paymentMethod: 'Наличные',
      ingredients: p.ingredients.map((ing) {
        final m = materialsRepo.getByKey(ing.materialKey);
        return SoldIngredient(
          materialKey: ing.materialKey,
          quantity: ing.quantity,
          costPerUnit: ing.costPerUnit,
          materialName: m?.name ?? ing.materialKey,
        );
      }).toList(),
    );

    for (final ing in p.ingredients) {
      supplyRepo.consumeMaterial(
        materialKey: ing.materialKey,
        qty: ing.quantity,
      );
    }

    salesRepo.addSale(sale);
    showcaseRepo.removeProduct(p.id);

    setState(() => tabIndex = 1);
  }

  Future<int?> _askUsedPoints(Client client) async {
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

  // ---------------------------------------------------------------------------
  // УДАЛЕНИЕ БУКЕТА
  // ---------------------------------------------------------------------------
  void _dismantle(AssembledProduct p) {
    final showcaseRepo = context.read<ShowcaseRepo>();
    showcaseRepo.removeProduct(p.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар удалён')),
    );
  }
}