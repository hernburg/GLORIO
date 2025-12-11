import 'package:flutter/material.dart';
import '../../../data/models/materialitem.dart';
import '../../../data/models/ingredient.dart';

class IngredientSelector extends StatefulWidget {
  final List<MaterialItem> materials;

  const IngredientSelector({super.key, required this.materials});

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  final TextEditingController searchCtrl = TextEditingController();
  String query = "";

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

  /// окно ввода количества
  Future<double?> _enterQty(MaterialItem m) async {
    final qtyCtrl = TextEditingController();

    return showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Сколько использовать: ${m.name}?"),
        content: TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Количество",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(qtyCtrl.text);
              Navigator.pop(context, v);
            },
            child: const Text("Добавить"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.materials.where((m) {
      return m.name.toLowerCase().contains(query) ||
          m.categoryName.toLowerCase().contains(query);
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 15),

          const Text(
            "Выбор ингредиента",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "Поиск...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final m = filtered[i];

                return ListTile(
                  title: Text(m.name),
                  subtitle: Text("Остаток: ${m.quantity}"),
                  trailing:
                      const Icon(Icons.add_circle, color: Colors.blue),
                  onTap: () async {
                    final qty = await _enterQty(m);
                    if (qty == null || qty <= 0) return;

                    if (!mounted) return;

                    final ingredient = Ingredient(
                      materialId: m.id,
                      quantity: qty,
                      costPerUnit: m.costPerUnit,
                    );

                    Navigator.pop(context, ingredient);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}