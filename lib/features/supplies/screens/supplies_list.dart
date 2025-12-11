import 'package:flower_accounting_app/core/widgets/add_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/supply_repo.dart';
import '../../../core/widgets/app_card.dart';

class SuppliesListScreen extends StatelessWidget {
  const SuppliesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<SupplyRepository>();
    final supplies = repo.supplies;

    return Scaffold(

      body: supplies.isEmpty
          ? const Center(
              child: Text(
                'Нет поставок.\nНажмите + чтобы добавить',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: 50,
                left: 15,
                right: 15,
                bottom: 50,),
              itemCount: supplies.length,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemBuilder: (context, index) {
                final s = supplies[index];

                return AppCard(
                  title: s.name,
                  subtitles: [
                      "Закуплено: ${s.quantity}",
                      "В букетах: ${s.usedInBouquets}",
                      "Списано: ${s.writtenOff}",
                      "Остаток: ${s.quantity - s.usedInBouquets - s.writtenOff}",
                      "Дата поставки: ${_format(s.supplyDate)}",
                      "Себестоимость за ед.: ${s.purchasePrice.toStringAsFixed(0)} ₽",
                  ],
                
                  photoUrl: s.photoUrl,

                  actions: [
                    AppCardAction(
                      icon: Icons.settings,
                      color: const Color.fromARGB(74, 94, 94, 94),
                      onTap: () {
                       context.push('/supplies/edit/${supplies[index].id}');
                      },
                    ),
                    AppCardAction(
                      icon: Icons.edit_document,
                      color: const Color.fromARGB(74, 94, 94, 94),
                      onTap: () {
                        // TODO: списание товара
                      },
                    ),
                    AppCardAction(
                      icon: Icons.delete,
                      color: const Color.fromARGB(255, 255, 0, 0),
                      onTap: () {
                        repo.removeSupply(s.id);
                      },
                    ),
                  ],
                );
              },
            ),

      floatingActionButton: AddButton(
        onTap: () => context.push('/supplies/new'),
      ),
    );
  }

  /// Форматируем дату под приятный вид
  String _format(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  }
}
