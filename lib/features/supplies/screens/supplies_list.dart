import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/supply.dart';
import '../../../data/repositories/supply_repo.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/writeoff_repo.dart';
import '../../../ui/app_card.dart';
import '../../../ui/add_button.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_text.dart';
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
      backgroundColor: GlorioColors.background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom + 96,
          right: 6,
        ),
        child: AddButton(
          onTap: () => context.push('/supplies/new'),
        ),
      ),
      body: Padding(
                padding: EdgeInsets.only(
                  left: GlorioSpacing.page,
                  right: GlorioSpacing.page,
                  top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
                  bottom: MediaQuery.of(context).viewPadding.bottom + GlorioSpacing.page,
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
                        color: GlorioColors.card.withAlpha((0.6 * 255).round()),
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
                  final isUsedTab = value == 1;
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
                      final materialsRepo = context.read<MaterialsRepo>();
                      final showcaseRepo = context.read<ShowcaseRepo>();
                      final salesRepo = context.read<SalesRepo>();
                      final writeoffRepo = context.read<WriteoffRepository>();
                      final itemStats = _buildItemStats(
                        supply,
                        materialsRepo: materialsRepo,
                        showcaseRepo: showcaseRepo,
                        salesRepo: salesRepo,
                        writeoffRepo: writeoffRepo,
                      );

                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Поставка от ${_formatDate(supply.date)}',
                              style: GlorioText.heading,
                            ),

                            const SizedBox(height: 6),

                            Text('Позиции: ${supply.items.length}', style: GlorioText.body),

                            const SizedBox(height: 8),

                            _SupplyItemsTable(stats: itemStats),

                            const SizedBox(height: 12),

                            Text('Сумма закупки: ${supply.totalCost.toStringAsFixed(0)} ₽', style: GlorioText.muted),

                            const SizedBox(height: 12),

                            if (!isUsedTab)
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: GlorioColors.textMuted,
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

  List<_SupplyItemStat> _buildItemStats(
    Supply supply, {
    required MaterialsRepo materialsRepo,
    required ShowcaseRepo showcaseRepo,
    required SalesRepo salesRepo,
    required WriteoffRepository writeoffRepo,
  }) {
    return supply.items.map((item) {
      double sold = 0;
      for (final sale in salesRepo.sales) {
        for (final ing in sale.ingredients) {
          if (ing.materialKey != item.materialKey) continue;
          final material = materialsRepo.getByKey(ing.materialKey);
          if (material != null && material.supplyId == supply.id) {
            sold += ing.quantity;
          }
        }
      }

      double spoiled = 0;
      for (final w in writeoffRepo.forSupply(supply.id)) {
        if (w.materialKey == item.materialKey) {
          spoiled += w.quantity;
        }
      }

      // item.quantity в поставке уже уменьшено списаниями/продажами (FIFO в SupplyRepository),
      // поэтому остаток считаем от фактического количества в этой поставке минус продажи.
  final remaining = (item.quantity - sold).clamp(0, double.infinity).toDouble();

      return _SupplyItemStat(
        name: item.name,
        supplyQty: item.quantity,
        soldQty: sold,
        spoiledQty: spoiled,
        remainingQty: remaining,
      );
    }).toList();
  }
}

class _SupplyItemsTable extends StatelessWidget {
  const _SupplyItemsTable({required this.stats});

  final List<_SupplyItemStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Text('Нет позиций', style: GlorioText.muted);
    }

    String fmt(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        headingRowHeight: 36,
        columns: const [
          DataColumn(label: Text('Товар')),
          DataColumn(label: Text('Кол-во')),
          DataColumn(label: Text('Продано')),
          DataColumn(label: Text('Списано')),
          DataColumn(label: Text('Остаток')),
        ],
        rows: stats
            .map(
              (s) => DataRow(
                cells: [
                  DataCell(Text(s.name)),
                  DataCell(Text(fmt(s.supplyQty))),
                  DataCell(Text(fmt(s.soldQty))),
                  DataCell(Text(fmt(s.spoiledQty))),
                  DataCell(Text(fmt(s.remainingQty))),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SupplyItemStat {
  final String name;
  final double supplyQty;
  final double soldQty;
  final double spoiledQty;
  final double remainingQty;

  _SupplyItemStat({
    required this.name,
    required this.supplyQty,
    required this.soldQty,
    required this.spoiledQty,
    required this.remainingQty,
  });
}

/// ---------------------------------------------------------------------------
/// Пустое состояние
/// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
                  child: Text(
                  'Нет поставок\nНажмите +, чтобы добавить',
                  textAlign: TextAlign.center,
                  style: GlorioText.muted,
                ),
    );
  }
}