import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ui/app_card.dart';
import '../../../ui/app_button.dart';
import '../../../ui/screen_content_layout.dart';

import '../../../data/repositories/sales_repo.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/supply_repo.dart';

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

    return ScreenContentLayout(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// -----------------------------
          /// ИТОГО
          /// -----------------------------
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Итог',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                const Text(
                  'Продажи',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                const Text(
                  'Склад',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isPrimary ? 18 : 14,
              fontWeight:
                  isPrimary ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF2E2E2E),
            ),
          ),
        ],
      ),
    );
  }
}