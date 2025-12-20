import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ui/app_card.dart';
import '../../../ui/app_button.dart';

import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/supply_repo.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';

class ReportsDashboard extends StatelessWidget {
  const ReportsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final salesRepo = context.watch<SalesRepo>();
    final showcaseRepo = context.watch<ShowcaseRepo>();
    final supplyRepo = context.watch<SupplyRepository>();

    final totalRevenue = salesRepo.sales.fold<double>(
      0,
      (sum, s) => sum + s.total,
    );

    final totalCost = salesRepo.sales.fold<double>(
      0,
      (sum, s) =>
          sum +
          s.ingredients.fold(
            0,
            (iSum, ing) => iSum + ing.totalCost,
          ),
    );

    final profit = totalRevenue - totalCost;

    return Scaffold(
      backgroundColor: GlorioColors.background,
      body: ListView(
        padding: EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
          bottom: GlorioSpacing.page,
        ),
        children: [
          /// -----------------------------
          /// ИТОГО
          /// -----------------------------
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Итог', style: GlorioText.heading),
                const SizedBox(height: 12),

                _MetricRow(
                  label: 'Выручка',
                  value: '${totalRevenue.toStringAsFixed(0)} ₽',
                ),
                _MetricRow(
                  label: 'Себестоимость',
                  value: '${totalCost.toStringAsFixed(0)} ₽',
                ),
                const Divider(height: 24),
                _MetricRow(
                  label: 'Прибыль',
                  value: '${profit.toStringAsFixed(0)} ₽',
                  isPrimary: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// -----------------------------
          /// ПРОДАЖИ
          /// -----------------------------
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Продажи', style: GlorioText.heading),
                const SizedBox(height: 12),

                _MetricRow(
                  label: 'Продано букетов',
                  value: salesRepo.sales.length.toString(),
                ),
                _MetricRow(
                  label: 'В витрине сейчас',
                  value: showcaseRepo.products.length.toString(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// -----------------------------
          /// СКЛАД
          /// -----------------------------
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Склад', style: GlorioText.heading),
                const SizedBox(height: 12),

                _MetricRow(
                  label: 'Поставок',
                  value: supplyRepo.supplies.length.toString(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// -----------------------------
          /// ДЕЙСТВИЯ
          /// -----------------------------
          AppButton(
            text: 'Экспорт отчёта (в разработке)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Экспорт будет добавлен позже'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Вспомогательный виджет строки метрики
/// ---------------------------------------------------------------------------
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _MetricRow({
    required this.label,
    required this.value,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: GlorioText.muted),
          ),
          Text(value, style: isPrimary ? GlorioText.heading : GlorioText.body),
        ],
      ),
    );
  }
}