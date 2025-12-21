import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/app_button.dart';
import '../../../ui/app_input.dart';
import '../../../ui/app_card.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';
import '../../../design/glorio_colors.dart';
import '../../../data/models/supply_item.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/category_repo.dart';

class SupplyItemEditor extends StatefulWidget {
  const SupplyItemEditor({super.key});

  @override
  State<SupplyItemEditor> createState() => _SupplyItemEditorState();
}

class _SupplyItemEditorState extends State<SupplyItemEditor> {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final costCtrl = TextEditingController();

  Category? _selectedCategory;

  String? error;

  @override
  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    costCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final repo = context.read<CategoryRepo>();
    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final controller = TextEditingController();
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            bool showArchived = false;
            void rebuild() => setModalState(() {});

            return StatefulBuilder(
              builder: (ctx, innerSetState) {
                // use innerSetState to keep showArchived state inside modal
                showArchived = showArchived;
                final active = [...repo.activeCategories]..sort((a, b) => a.name.compareTo(b.name));
                final archived = [...repo.archivedCategories]..sort((a, b) => a.name.compareTo(b.name));

                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: GlorioSpacing.page,
                      right: GlorioSpacing.page,
                      top: MediaQuery.of(ctx).viewPadding.top + GlorioSpacing.page,
                      bottom: GlorioSpacing.page + MediaQuery.of(ctx).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text('Категория', style: GlorioText.heading),
                            const Spacer(),
                            if (archived.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => innerSetState(() => showArchived = !showArchived),
                                icon: Icon(
                                  showArchived ? Icons.expand_less : Icons.archive_outlined,
                                  size: 18,
                                  color: GlorioColors.textMuted,
                                ),
                                label: Text(
                                  showArchived ? 'Скрыть архив' : 'Показать архив',
                                  style: GlorioText.muted,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: GlorioSpacing.gapSmall),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: active.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final cat = active[i];
                              return AppCard(
                                onTap: () => Navigator.pop(ctx, cat),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(cat.name, style: GlorioText.body)),
                                    IconButton(
                                      icon: const Icon(Icons.archive_outlined, size: 20),
                                      color: GlorioColors.textMuted,
                                      tooltip: 'В архив',
                                      onPressed: () {
                                        repo.archive(cat.id);
                                        rebuild();
                                        innerSetState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        if (showArchived && archived.isNotEmpty) ...[
                          const SizedBox(height: GlorioSpacing.gapSmall),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Архив', style: GlorioText.muted),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: archived.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final cat = archived[i];
                                return AppCard(
                                  onTap: () => Navigator.pop(ctx, cat),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(cat.name, style: GlorioText.body)),
                                      IconButton(
                                        icon: const Icon(Icons.unarchive_outlined, size: 20),
                                        color: GlorioColors.textMuted,
                                        tooltip: 'Вернуть из архива',
                                        onPressed: () {
                                          repo.restore(cat.id);
                                          rebuild();
                                          innerSetState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: GlorioSpacing.gap),
                        AppInput(
                          controller: controller,
                          hint: 'Новая категория',
                        ),
                        const SizedBox(height: GlorioSpacing.gapSmall),
                        AppButton(
                          text: 'Создать и выбрать',
                          onTap: () {
                            final name = controller.text.trim();
                            if (name.isEmpty) return;
                            final created = repo.addCategory(name);
                            rebuild();
                            Navigator.pop(ctx, created);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _selectedCategory = result);
    }
  }

  void _submit() {
    final name = nameCtrl.text.trim();
    final category = _selectedCategory;

    final qty = double.tryParse(qtyCtrl.text.replaceAll(',', '.'));
    final cost = double.tryParse(costCtrl.text.replaceAll(',', '.'));

    if (name.isEmpty) {
      setState(() => error = 'Введите название');
      return;
    }
    if (category == null) {
      setState(() => error = 'Выберите категорию');
      return;
    }
    if (qty == null || qty <= 0) {
      setState(() => error = 'Введите количество');
      return;
    }
    if (cost == null || cost <= 0) {
      setState(() => error = 'Введите цену за единицу');
      return;
    }

    final materialKey = '${name}_${category.id}';

    final item = SupplyItem(
      materialKey: materialKey,
      name: name,
      categoryId: category.id,
      categoryName: category.name,
      quantity: qty,
      costPerUnit: cost,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: GlorioSpacing.page,
          bottom: GlorioSpacing.page + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Новая позиция', style: GlorioText.heading),
            const SizedBox(height: GlorioSpacing.gap),

            AppInput(
              controller: nameCtrl,
              hint: 'Название (например: Роза Эквадор)',
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickCategory,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: GlorioColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GlorioColors.border),
                ),
                child: Text(
                  _selectedCategory?.name ?? 'Выберите категорию',
                  style: _selectedCategory == null
                      ? GlorioText.muted
                      : GlorioText.body,
                ),
              ),
            ),
            const SizedBox(height: 12),

            AppInput(
              controller: qtyCtrl,
              hint: 'Количество',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            AppInput(
              controller: costCtrl,
              hint: 'Цена за единицу',
              keyboardType: TextInputType.number,
            ),

            if (error != null) ...[
              SizedBox(height: GlorioSpacing.gapSmall),
              Text(error!, style: GlorioText.body.copyWith(color: GlorioColors.warning)),
            ],

            const SizedBox(height: 16),
            AppButton(text: 'Добавить', onTap: _submit),
          ],
        ),
      ),
    );
  }
}