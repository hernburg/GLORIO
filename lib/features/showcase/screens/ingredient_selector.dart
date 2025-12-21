import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/materialitem.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/repositories/supply_repo.dart';

import '../../../ui/app_card.dart';
import '../../../ui/app_input.dart';
import '../../../ui/app_button.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_text.dart';
import '../../../design/glorio_spacing.dart';

class IngredientSelector extends StatefulWidget {
  final List<MaterialItem> materials;
  final List<Ingredient> selectedIngredients;

  const IngredientSelector({
    super.key,
    required this.materials,
    required this.selectedIngredients,
  });

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  final TextEditingController searchCtrl = TextEditingController();
  String query = '';
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    searchCtrl.addListener(() {
      if (!mounted) return;
      setState(() => query = searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Диалог ввода количества с ограничением склада
  // ---------------------------------------------------------------------------
  Future<double?> _enterQty(
    MaterialItem m,
    double available,
  ) async {
    final qtyCtrl = TextEditingController();
    String? error;

    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setLocalState) {
            return Dialog(
              backgroundColor: const Color(0xFFF6F3EE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Доступно: ${available.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),

                    const SizedBox(height: 16),

                    AppInput(
                      controller: qtyCtrl,
                      hint: 'Количество',
                      keyboardType: TextInputType.number,
                      errorText: error,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext),
                            child: const Text('Отмена'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: 'Добавить',
                            onTap: () {
                              final value = double.tryParse(
                                qtyCtrl.text.replaceAll(',', '.'),
                              );

                              if (value == null || value <= 0) {
                                setLocalState(() {
                                  error = 'Введите корректное число';
                                });
                                return;
                              }

                              if (value > available) {
                                setLocalState(() {
                                  error = 'Недостаточно на складе';
                                });
                                return;
                              }

                              Navigator.pop(dialogContext, value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final supplyRepo = context.read<SupplyRepository>();

    final filtered = widget.materials
        .where(
          (m) =>
              m.name.toLowerCase().contains(query) ||
              m.categoryName.toLowerCase().contains(query),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return SafeArea(
      child: Container(
        color: GlorioColors.background,
        padding: const EdgeInsets.only(top: GlorioSpacing.page),
        child: Column(
          children: [
            const SizedBox(height: 6),

            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: GlorioColors.border,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 16),

            Text('Выбор ингредиента', style: GlorioText.heading),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GlorioSpacing.page),
              child: AppInput(
                controller: searchCtrl,
                hint: 'Поиск по названию или категории',
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(GlorioSpacing.page),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final m = filtered[i];

                  return AppCard(
                    onTap: () async {
                      if (_popped) return;

                        // Capture values derived from context before awaiting
                        final totalAvailable = supplyRepo.totalAvailable(m.id);

                        final alreadyUsed = widget.selectedIngredients
                            .where((i) => i.materialKey == m.id)
                            .fold<double>(
                              0,
                              (sum, i) => sum + i.quantity,
                            );

                        final available = totalAvailable - alreadyUsed;

                          if (available <= 0) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Нет на складе'),
                              ),
                            );
                            return;
                          }

                          // Capture navigator context/router before awaiting
                          final navigator = Navigator.of(context);

                          final qty = await _enterQty(m, available);
                          if (!mounted || qty == null) return;

                          _popped = true;

                          navigator.pop(
                            Ingredient(
                              materialKey: m.id,
                              quantity: qty,
                              costPerUnit: m.costPerUnit,
                            ),
                          );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: GlorioText.heading.copyWith(fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(m.categoryName, style: GlorioText.muted),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}