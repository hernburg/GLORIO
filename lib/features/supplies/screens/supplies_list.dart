import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/supply_repo.dart';
import '../../../ui/app_card.dart';
import '../../../ui/add_button.dart';

class SuppliesListScreen extends StatelessWidget {
  const SuppliesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<SupplyRepository>();
    final supplies = repo.supplies;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EE),
      floatingActionButton: AddButton(
        onTap: () => context.push('/supplies/new'),
      ),
      body: supplies.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: supplies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final supply = supplies[index];

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 📅 Дата поставки
                      Text(
                        'Поставка от ${_formatDate(supply.date)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 📦 Количество позиций
                      Text(
                        'Позиций: ${supply.items.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// 🔢 Общее количество единиц
                      Text(
                        'Единиц всего: ${supply.totalQuantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A7A7A),
                        ),
                      ),

                      /// 💰 Сумма закупки
                      Text(
                        'Сумма закупки: ${supply.totalCost.toStringAsFixed(0)} ₽',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A7A7A),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 🗑 Действия
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFF7A7A7A),
                          ),
                          tooltip: 'Удалить',
                          onPressed: () {
                            repo.deleteSupply(supply.id);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
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