import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_card.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/models/sale.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/supply_repo.dart';

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
      body: Column(
        children: [
          const SizedBox(height: 12),

          // -------------------------------
          //       LIQUID GLASS ТАБЫ
          // -------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.28),
                        Colors.white.withOpacity(0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Пузырь
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        alignment: tabIndex == 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.55),
                                  Colors.white.withOpacity(0.20),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => tabIndex = 0),
                              child: SizedBox(
                              height: 36,
                              child: Center(
                                child: Text(
                                  "В продаже",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: tabIndex == 0
                                        ? Colors.black
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => tabIndex = 1),
                              child: SizedBox(
                              height: 36,
                              child: Center(
                                child: Text(
                                  "Продано",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: tabIndex == 1
                                        ? Colors.black
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // -------------------------------
          //         КОНТЕНТ ВКЛАДОК
          // -------------------------------
          Expanded(
            child: tabIndex == 0
                ? _buildAvailable(showcase)
                : _buildSold(sales),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  //     ВКЛАДКА "В ПРОДАЖЕ"
  // -------------------------------
  Widget _buildAvailable(List products) {
    if (products.isEmpty) {
      return const Center(child: Text("На витрине пока пусто"));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];

        return AppCard(
          title: p.name,
          photoUrl: p.photoUrl,
          subtitles: [
            "Себестоимость: ${p.costPrice} ₽",
            "Цена продажи: ${p.sellingPrice} ₽",
          ],
          actions: [
            AppCardAction(
              icon: Icons.shopping_bag,
              color: Colors.green,
              onTap: () => _sell(p),
            ),
            AppCardAction(
              icon: Icons.delete_sweep,
              color: Colors.red,
              onTap: () => _dismantle(p),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------
  //       ВКЛАДКА "ПРОДАНО"
  // -------------------------------
  Widget _buildSold(List<Sale> sales) {
    if (sales.isEmpty) {
      return const Center(child: Text("Пока нет завершённых продаж"));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: sales.length,
      itemBuilder: (context, i) {
        final s = sales[i];

        return AppCard(
          title: s.product.name,
          photoUrl: s.product.photoUrl,
          subtitles: [
            "Итог: ${s.total.toStringAsFixed(0)} ₽",
            "Количество: ${s.quantity}",
            "Дата: ${s.date.day}.${s.date.month}.${s.date.year}",
          ],
          actions: [
            AppCardAction(
              icon: Icons.info_outline,
              color: Colors.blue,
              onTap: () {
                // TODO: детали продажи
              },
            ),
          ],
        );
      },
    );
  }

  // -------------------------------
  //         ЛОГИКА ПРОДАЖ
  // -------------------------------
void _sell(product) {
  final salesRepo = context.read<SalesRepo>();
  final showcaseRepo = context.read<ShowcaseRepo>();
  final materialsRepo = context.read<MaterialsRepo>();
  final suppliesRepo = context.read<SupplyRepository>();

  final sale = Sale(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    product: product,
    quantity: 1,
    price: product.sellingPrice,
    date: DateTime.now(),
    ingredients: product.ingredients.map((ing) {
      return SoldIngredient(
        materialId: ing.materialId,
        usedQuantity: ing.quantity,
      );
    }).toList(),
  );

  salesRepo.addSale(sale);
  showcaseRepo.removeProduct(product);

  // списываем материалы
  for (final ing in product.ingredients) {
    materialsRepo.returnQuantity(ing.materialId, ing.quantity);
    suppliesRepo.returnFromBouquet(ing.materialId, ing.quantity);
  }

  setState(() => tabIndex = 1);
}

  void _dismantle(product) {
    final showcaseRepo = context.read<ShowcaseRepo>();
    final materials = context.read<MaterialsRepo>();
    final supplies = context.read<SupplyRepository>();

    for (final ing in product.ingredients) {
      materials.returnQuantity(ing.materialId, ing.quantity);
      supplies.returnFromBouquet(ing.materialId, ing.quantity);
    }

    showcaseRepo.removeProduct(product);
  }
}