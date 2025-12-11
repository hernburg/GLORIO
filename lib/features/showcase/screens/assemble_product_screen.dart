import 'dart:io';
import 'package:flower_accounting_app/core/widgets/add_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/models/assembled_product.dart';
import '../../../data/models/materialitem.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/supply_repo.dart';

class AssembleProductScreen extends StatefulWidget {
  final AssembledProduct? editProduct;
  final String? editId;

  const AssembleProductScreen({super.key, this.editProduct, this.editId});

  @override
  State<AssembleProductScreen> createState() => _AssembleProductScreenState();
}

class _AssembleProductScreenState extends State<AssembleProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List<Ingredient> ingredients = [];
  String? photoUrl;

  double get totalCost =>
      ingredients.fold(0, (sum, item) => sum + item.totalCost);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.editProduct != null) {
        _applyProduct(widget.editProduct!);
      } else if (widget.editId != null) {
        final repo = context.read<ShowcaseRepo>();
        final product = repo.getById(widget.editId!);
        if (product != null) {
          _applyProduct(product);
        }
      }
    });
  }

  void _applyProduct(AssembledProduct p) {
    nameController.text = p.name;
    priceController.text = p.sellingPrice.toString();
    ingredients
      ..clear()
      ..addAll(List.from(p.ingredients));
    photoUrl = p.photoUrl;
    setState(() {});
  }

  /// Пикер фото
  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        photoUrl = img.path;
      });
    }
  }

  /// Открытие выбора ингредиентов
  void openIngredientsSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => IngredientSelector(
        onAdd: (material, qty) {
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
        },
      ),
    );
  }

  /// Сохранение букета
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

    if (widget.editProduct == null) {
      final product = AssembledProduct(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        photoUrl: photoUrl,
        ingredients: ingredients,
        costPrice: totalCost,
        sellingPrice: price,
      );

      showcase.addProduct(product);
    } else {
      final updated = widget.editProduct!.copyWith(
        name: name,
        sellingPrice: price,
        ingredients: ingredients,
        costPrice: totalCost,
        photoUrl: photoUrl,
      );

      showcase.updateProduct(updated);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      final value = photoUrl!.trim();
      final uri = Uri.tryParse(value);

      if (uri != null &&
          uri.hasAbsolutePath &&
          (uri.scheme == 'http' || uri.scheme == 'https')) {
        imageProvider = NetworkImage(value);
      } else if (!kIsWeb && File(value).existsSync()) {
        imageProvider = FileImage(File(value));
      }
    }

    return Scaffold(
    floatingActionButton: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AddButton(
          onTap: openIngredientsSelector,
        ),
        const SizedBox(height: 6),
        const Text(
          "Добавить ингредиенты",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Фото букета
              GestureDetector(
                onTap: pickPhoto,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider!,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: imageProvider == null
                      ? const Text(
                          "Загрузить фото",
                          style: TextStyle(color: Colors.black54),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 20),

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

              const Text(
                "Ингредиенты:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              Expanded(
                child: ListView(
                  children: ingredients.map((ing) {
                    final materialName =
                        context.read<MaterialsRepo>().getById(ing.materialId)?.name;
                    return ListTile(
                      title: Text(materialName ?? "ID: ${ing.materialId}"),
                      subtitle: Text(
                        "${ing.quantity} × ${ing.costPerUnit} ₽ = "
                        "${ing.totalCost.toStringAsFixed(0)} ₽",
                      ),
                      trailing:
                          const Icon(Icons.delete, color: Colors.red),
                      onTap: () {
                        setState(() => ingredients.remove(ing));
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: saveProduct,
          child: const Text(
            'Сохранить букет',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

/// ===================================================================
///  МОДАЛЬНОЕ ОКНО – ВЫБОР ИНГРЕДИЕНТОВ
/// ===================================================================

class IngredientSelector extends StatefulWidget {
  final void Function(MaterialItem material, double qty) onAdd;

  const IngredientSelector({super.key, required this.onAdd});

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  final TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final materials = context.watch<MaterialsRepo>().materials;

    final filtered = materials.where((m) {
      final q = searchCtrl.text.toLowerCase();
      return m.name.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Добавить ингредиент",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Поиск...",
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 350,
            child: ListView(
              children: filtered.map((m) {
                return ListTile(
                  title: Text(m.name),
                  trailing:
                      const Icon(Icons.add_circle, color: Colors.blueAccent),
                  onTap: () => _enterQty(context, m),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _enterQty(BuildContext context, MaterialItem m) {
    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Сколько добавить: ${m.name}?"),
        content: TextField(
          controller: qtyCtrl,
          decoration: const InputDecoration(labelText: "Количество"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: const Text("Отмена"),
            onPressed: () {
              Navigator.of(context).pop(); // закрыть только диалог
            },
          ),
          ElevatedButton(
            child: const Text("Добавить"),
            onPressed: () {
              final qty = double.tryParse(qtyCtrl.text) ?? 0;
              if (qty > 0) {
                widget.onAdd(m, qty);
              }

              // ОДИН раз закрываем весь стек модальных окон
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }
}