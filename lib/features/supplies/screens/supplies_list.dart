import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/supply_repo.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../ui/app_card.dart';
import '../../../ui/add_button.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_radius.dart';

class SuppliesListScreen extends StatefulWidget {
  const SuppliesListScreen({super.key});

  @override
  State<SuppliesListScreen> createState() => _SuppliesListScreenState();
}

class _SuppliesListScreenState extends State<SuppliesListScreen> {
  final ValueNotifier<int> tab = ValueNotifier<int>(0);

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<SupplyRepository>();
    final supplies = repo.supplies;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EE),
      floatingActionButton: AddButton(
        onTap: () => context.push('/supplies/new'),
      ),
      body: Padding(
                padding: EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
          bottom: GlorioSpacing.page,
        ),
        child: Column(
          children: [
            // Tabs: match the style used in SalesListScreen (blurred background + two buttons)
            ValueListenableBuilder<int>(
              valueListenable: tab,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(GlorioRadius.large),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(GlorioSpacing.card),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(GlorioRadius.large),
                        border: Border.all(color: GlorioColors.border),
                        color: GlorioColors.card.withOpacity(0.6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _tabButton('Активные', 0),
                          ),
                          Expanded(
                            child: _tabButton('Использованные', 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: tab,
                builder: (context, value, _) {
                  final filtered = supplies.where((s) {
                    final used = s.totalQuantity <= 0;
                    return value == 0 ? !used : used;
                  }).toList();

                  if (filtered.isEmpty) return const _EmptyState();

                  return ListView.separated(
                    padding: const EdgeInsets.only(top: 0),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final supply = filtered[index];

                      // compute extra stats
                      final inStock = supply.totalQuantity;

                      double inBouquets = 0.0;
                      final sr = context.read<ShowcaseRepo>();
                      for (final p in sr.products) {
                        for (final ing in p.ingredients) {
                          final m = context.read<MaterialsRepo>().getByKey(ing.materialKey);
                          if (m != null && m.supplyId == supply.id) {
                            inBouquets += ing.quantity;
                          }
                        }
                      }

                      double soldFromSupply = 0.0;
                      final srepo = context.read<SalesRepo>();
                      for (final s in srepo.sales) {
                        for (final ing in s.ingredients) {
                          final m = context.read<MaterialsRepo>().getByKey(ing.materialKey);
                          if (m != null && m.supplyId == supply.id) {
                            soldFromSupply += ing.quantity;
                          }
                        }
                      }

                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Поставка от ${_formatDate(supply.date)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Позиций: ${supply.items.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Единиц всего: ${supply.totalQuantity.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF7A7A7A),
                                        ),
                                      ),
                                      Text(
                                        'На складе: ${inStock.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF7A7A7A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'В букете: ${inBouquets.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF7A7A7A),
                                        ),
                                      ),
                                      Text(
                                        'Продано: ${soldFromSupply.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF7A7A7A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              'Сумма закупки: ${supply.totalCost.toStringAsFixed(0)} ₽',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7A7A7A),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF7A7A7A),
                                ),
                                tooltip: 'Редактировать',
                                onPressed: () {
                                  context.push('/supplies/edit/${supply.id}');
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final active = tab.value == index;
    return GestureDetector(
      onTap: () => tab.value = index,
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

  static String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }
}

/// ---------------------------------------------------------------------------
/// Пустое состояние
/// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Нет поставок\nНажмите +, чтобы добавить',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF7A7A7A),
        ),
      ),
    );
  }
}