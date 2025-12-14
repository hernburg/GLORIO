import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/app_card.dart';
import '../../../ui/app_button.dart';

import '../../../data/models/assembled_product.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/sold_ingredient.dart';

import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/supply_repo.dart';
import '../../../data/repositories/auth_repo.dart';

import '../widgets/client_selector.dart';

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
      backgroundColor: const Color(0xFFF6F3EE),
      body: Column(
        children: [
          const SizedBox(height: 40),
          _buildTabs(),
          const SizedBox(height: 12),
          Expanded(
            child: tabIndex == 0
                ? _buildAvailable(showcase)
                : _buildSold(sales),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABS
  // ---------------------------------------------------------------------------
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black12),
              color: Colors.white.withValues(alpha: 0.6),
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
      return const Center(child: Text('На витрине пока пусто'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final p = products[i];

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Себестоимость: ${p.costPrice.toStringAsFixed(0)} ₽'),
              Text('Цена продажи: ${p.sellingPrice.toStringAsFixed(0)} ₽'),
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
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ПРОДАНО
  // ---------------------------------------------------------------------------
  Widget _buildSold(List<Sale> sales) {
    if (sales.isEmpty) {
      return const Center(child: Text('Пока нет завершённых продаж'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: sales.length,
      itemBuilder: (_, i) {
        final s = sales[i];
        return AppCard(
          onTap: () => context.push('/sale_info/${s.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.product.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text('Итог: ${s.total.toStringAsFixed(0)} ₽'),
              Text(
                  'Дата: ${s.date.day}.${s.date.month}.${s.date.year}'),
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
    final sale = await _createSale(context, p);
    if (!mounted || sale == null) return;

    final salesRepo = context.read<SalesRepo>();
    final showcaseRepo = context.read<ShowcaseRepo>();
    final supplyRepo = context.read<SupplyRepository>();

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

  Future<Sale?> _createSale(
      BuildContext context, AssembledProduct p) async {
    final selection = await pickClient(context);
    if (selection == null) return null;

    final materialsRepo = context.read<MaterialsRepo>();
    final authRepo = context.read<AuthRepo>();

    return Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      product: p,
      quantity: 1,
      price: p.sellingPrice,
      date: DateTime.now(),
      clientId: selection.client?.id,
      clientName: selection.client?.name,
      soldBy: authRepo.currentUserLogin,
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