import 'package:flutter/material.dart';
import '../../../ui/app_button.dart';
import '../../../ui/app_input.dart';
import '../../../data/models/supply_item.dart';

class SupplyItemEditor extends StatefulWidget {
  const SupplyItemEditor({super.key});

  @override
  State<SupplyItemEditor> createState() => _SupplyItemEditorState();
}

class _SupplyItemEditorState extends State<SupplyItemEditor> {
  final nameCtrl = TextEditingController();
  final categoryIdCtrl = TextEditingController();
  final categoryNameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final costCtrl = TextEditingController();

  String? error;

  @override
  void dispose() {
    nameCtrl.dispose();
    categoryIdCtrl.dispose();
    categoryNameCtrl.dispose();
    qtyCtrl.dispose();
    costCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = nameCtrl.text.trim();
    final categoryId = categoryIdCtrl.text.trim();
    final categoryName = categoryNameCtrl.text.trim();

    final qty = double.tryParse(qtyCtrl.text.replaceAll(',', '.'));
    final cost = double.tryParse(costCtrl.text.replaceAll(',', '.'));

    if (name.isEmpty) {
      setState(() => error = 'Введите название');
      return;
    }
    if (categoryId.isEmpty || categoryName.isEmpty) {
      setState(() => error = 'Введите категорию');
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

    final materialKey = '${name}_$categoryId';

    final item = SupplyItem(
      materialKey: materialKey,
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
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
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Новая позиция',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            AppInput(
              controller: nameCtrl,
              hint: 'Название (например: Роза Эквадор)',
            ),
            const SizedBox(height: 12),

            AppInput(
              controller: categoryIdCtrl,
              hint: 'Категория ID (например: flowers)',
            ),
            const SizedBox(height: 12),

            AppInput(
              controller: categoryNameCtrl,
              hint: 'Категория (например: Цветы)',
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
              const SizedBox(height: 10),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 16),
            AppButton(text: 'Добавить', onTap: _submit),
          ],
        ),
      ),
    );
  }
}