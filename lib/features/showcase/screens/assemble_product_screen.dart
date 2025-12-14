import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../ui/app_card.dart';
import '../../../ui/add_button.dart';
import '../../../ui/app_button.dart';
import '../../../ui/app_input.dart';

import '../../../data/models/ingredient.dart';
import '../../../data/models/assembled_product.dart';

import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/showcase_repo.dart';

import 'ingredient_selector.dart';

class AssembleProductScreen extends StatefulWidget {
  final AssembledProduct? editProduct;
  final String? editId;

  const AssembleProductScreen({
    super.key,
    this.editProduct,
    this.editId,
  });

  @override
  State<AssembleProductScreen> createState() => _AssembleProductScreenState();
}

class _AssembleProductScreenState extends State<AssembleProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  final List<Ingredient> ingredients = [];
  String? photoUrl;

  double get totalCost => ingredients.fold(0, (sum, i) => sum + i.totalCost);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.editProduct != null) {
        _applyProduct(widget.editProduct!);
      } else if (widget.editId != null) {
        final product = context.read<ShowcaseRepo>().getById(widget.editId!);
        if (product != null) _applyProduct(product);
      }
    });
  }

  void _applyProduct(AssembledProduct p) {
  nameController.text = p.name;
  priceController.text = p.sellingPrice.toStringAsFixed(0);

  ingredients
    ..clear()
    ..addAll(p.ingredients);

  photoUrl = p.photoUrl;
  setState(() {});
}

  // ---------------------------------------------------------------------------
  // PHOTO
  // ---------------------------------------------------------------------------
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;

    if (img != null) {
      setState(() => photoUrl = img.path);
    }
  }

  // ---------------------------------------------------------------------------
  // INGREDIENT PICKER
  // ---------------------------------------------------------------------------
  Future<void> _openIngredientSelector() async {
    final materials = context.read<MaterialsRepo>().materials; // List<MaterialItem>

    final picked = await showModalBottomSheet<Ingredient>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return IngredientSelector(
          materials: materials,
          selectedIngredients: ingredients,
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      final index = ingredients.indexWhere(
        (i) => i.materialKey == picked.materialKey,
      );

      if (index >= 0) {
        ingredients[index] = ingredients[index].copyWith(
          quantity: ingredients[index].quantity + picked.quantity,
        );
      } else {
        ingredients.add(picked);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // SAVE PRODUCT
  // ---------------------------------------------------------------------------
  void _saveProduct() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0;

    if (name.isEmpty || price <= 0 || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    final showcase = context.read<ShowcaseRepo>();

    if (widget.editProduct == null) {
      showcase.addProduct(
        AssembledProduct(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          photoUrl: photoUrl,
          ingredients: ingredients,
          costPrice: totalCost,
          sellingPrice: price,
        ),
      );
    } else {
      showcase.updateProduct(
        widget.editProduct!.copyWith(
          name: name,
          sellingPrice: price,
          ingredients: ingredients,
          costPrice: totalCost,
          photoUrl: photoUrl,
        ),
      );
    }

    context.pop();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    ImageProvider? image;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      final uri = Uri.tryParse(photoUrl!);
      if (uri != null && uri.scheme.startsWith('http')) {
        image = NetworkImage(photoUrl!);
      } else if (!kIsWeb && File(photoUrl!).existsSync()) {
        image = FileImage(File(photoUrl!));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EE),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AddButton(onTap: _openIngredientSelector),
          const SizedBox(height: 6),
          const Text(
            'Добавить ингредиент',
            style: TextStyle(fontSize: 12, color: Color(0xFF7A7A7A)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // PHOTO
            GestureDetector(
              onTap: _pickPhoto,
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.grey.shade200,
                    image: image != null
                        ? DecorationImage(image: image, fit: BoxFit.cover)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: image == null
                      ? const Text(
                          'Загрузить фото',
                          style: TextStyle(color: Color(0xFF7A7A7A)),
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // MAIN DATA
            AppCard(
              child: Column(
                children: [
                  AppInput(
                    controller: nameController,
                    hint: 'Название букета',
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: priceController,
                    hint: 'Цена продажи',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Себестоимость: ${totalCost.toStringAsFixed(0)} ₽',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Ингредиенты',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            if (ingredients.isEmpty)
              const Text(
                'Ингредиенты не добавлены',
                style: TextStyle(color: Color(0xFF7A7A7A)),
              ),

            ...ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ing = entry.value;

              final material =
                  context.read<MaterialsRepo>().getByKey(ing.materialKey);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material?.name ?? ing.materialKey,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${ing.quantity} × ${ing.costPerUnit} ₽ = ${ing.totalCost.toStringAsFixed(0)} ₽',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7A7A7A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() => ingredients.removeAt(index));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: AppButton(
          text: 'Сохранить букет',
          onTap: _saveProduct,
        ),
      ),
    );
  }
}