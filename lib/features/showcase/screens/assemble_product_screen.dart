import 'package:flower_accounting_app/core/widgets/add_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/ingredient.dart';
import '../../../data/models/assembled_product.dart';
import '../../../data/models/materialitem.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/supply_repo.dart';

class AssembleProductScreen extends StatefulWidget {
  final AssembledProduct? editProduct;

  const AssembleProductScreen({super.key, this.editProduct});

  @override
  State<AssembleProductScreen> createState() => _AssembleProductScreenState();
}

class _AssembleProductScreenState extends State<AssembleProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();

  List<Ingredient> ingredients = [];
  String searchQuery = "";

  double get totalCost =>
      ingredients.fold(0, (sum, item) => sum + item.totalCost);

  @override
  void initState() {
    super.initState();

    if (widget.editProduct != null) {
      final p = widget.editProduct!;
      nameController.text = p.name;
      priceController.text = p.sellingPrice.toString();
      ingredients.addAll(p.ingredients);
    }

    searchCtrl.addListener(() {
      setState(() => searchQuery = searchCtrl.text.trim().toLowerCase());
    });
  }

  /// Добавление ингредиента
  void addIngredient(MaterialItem material) {
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Добавить: ${material.name}'),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Количество'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            child: const Text('Добавить'),
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 0;
              if (qty > 0) {
                final materials = context.read<MaterialsRepo>();
                final supplies = context.read<SupplyRepository>();

                materials.reduceQuantity(material.id, qty);
                supplies.consumeFromSupply(material.supplyId, qty);

                setState(() {
                  ingredients.add(
                    Ingredient(
                      materialId: material.id,
                      quantity: qty,
                      costPerUnit: material.costPerUnit,
                    ),
                  );
                });
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }


  void saveProduct() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text) ?? 0;

    if (name.isEmpty || price <= 0 || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля!')),
      );
      return;
    }

    final showcase = context.read<ShowcaseRepo>();
    final materials = context.read<MaterialsRepo>();
    final supplies = context.read<SupplyRepository>();

    if (widget.editProduct == null) {
      /// Создание нового
      final product = AssembledProduct(
        name: name,
        photoUrl: null,
        ingredients: ingredients,
        costPrice: totalCost,
        sellingPrice: price,
      );

      showcase.addProduct(product, materials, supplies);
    } else {
      /// Обновление
      final updated = widget.editProduct!.copyWith(
        name: name,
        sellingPrice: price,
        ingredients: ingredients,
        costPrice: totalCost,
      );

      showcase.updateProduct(updated);
    }

    context.pop();
  }


  void _onExit() {
    if (widget.editProduct != null) return;

    final materials = context.read<MaterialsRepo>();
    final supplies = context.read<SupplyRepository>();

    for (final ing in ingredients) {
      materials.returnQuantity(ing.materialId, ing.quantity);
      supplies.returnFromBouquet(ing.materialId, ing.quantity);
    }
  }


  @override
  Widget build(BuildContext context) {
    final allMaterials = context.watch<MaterialsRepo>().materials;

    // фильтрация
    final filtered = allMaterials.where((m) {
      final q = searchQuery;
      return m.name.toLowerCase().contains(q) ||
          m.categoryName.toLowerCase().contains(q);
    }).toList();

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _onExit();
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Сборка букета')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название букета'),
              ),
              const SizedBox(height: 20),

              Text('Себестоимость: ${totalCost.toStringAsFixed(0)} ₽',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),

              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Цена продажи'),
              ),
              const SizedBox(height: 20),

              const Text('Ингредиенты:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // список выбранных ингредиентов
              Expanded(
                child: ListView(
                  children: [

                    // 🔍 ПОИСК ПО МАТЕРИАЛАМ
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: "Поиск цветка...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // список выбранных ингредиентов
                    ...ingredients.map((ing) {
                      final mat = allMaterials.firstWhere((m) => m.id == ing.materialId);
                      return ListTile(
                        title: Text(mat.name),
                        subtitle: Text(
                          '${ing.quantity} × ${ing.costPerUnit} ₽ = ${ing.totalCost.toStringAsFixed(0)} ₽',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            final materials = context.read<MaterialsRepo>();
                            final supplies = context.read<SupplyRepository>();

                            materials.returnQuantity(ing.materialId, ing.quantity);
                            supplies.returnFromBouquet(mat.supplyId, ing.quantity);

                            setState(() => ingredients.remove(ing));
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    const Text("Добавить ингредиент:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // Список материалов по поиску
                    ...filtered.map((m) => ListTile(
                      title: Text(m.name),
                      subtitle: Text("Остаток: ${m.quantity}"),
                      trailing: const Icon(Icons.add_circle, color: Colors.blue),
                      onTap: () => addIngredient(m),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: saveProduct,
            child:
                const Text('Сохранить букет', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}