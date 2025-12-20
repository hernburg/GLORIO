// AssembleProductScreen — create / edit bouquet
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../ui/app_card.dart';
import '../../../ui/add_button.dart';
import '../../../ui/app_button.dart';
import '../../../ui/app_input.dart';

import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_radius.dart';
import '../../../design/glorio_text.dart';

import '../../../data/models/ingredient.dart';
import '../../../data/models/assembled_product.dart';

import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/showcase_repo.dart';
import '../../../data/repositories/supply_repo.dart';

import 'ingredient_selector.dart';

class AssembleProductScreen extends StatefulWidget {
  final AssembledProduct? editProduct;
  final String? editId;

  const AssembleProductScreen({super.key, this.editProduct, this.editId});

  @override
  State<AssembleProductScreen> createState() => _AssembleProductScreenState();
}

class _AssembleProductScreenState extends State<AssembleProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final List<Ingredient> ingredients = [];
  String? photoUrl;
  AssembledProduct? _originalProduct;

  double get totalCost => ingredients.fold(0, (s, i) => s + i.totalCost);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.editProduct != null) {
        _applyProduct(widget.editProduct!);
      } else if (widget.editId != null) {
        final p = context.read<ShowcaseRepo>().getById(widget.editId!);
        if (p != null) _applyProduct(p);
      }
    });
  }

  void _applyProduct(AssembledProduct p) {
    _originalProduct = p;
    nameController.text = p.name;
    priceController.text = p.sellingPrice.toString();
    photoUrl = p.photoUrl;
    ingredients.clear();
    ingredients.addAll(p.ingredients.map((i) => i));
    setState(() {});
  }

  Future<void> _openIngredientSelector() async {
    final materials = context.read<MaterialsRepo>().materials;
    final result = await showModalBottomSheet<Ingredient>(
      context: context,
      isScrollControlled: true,
      builder: (_) => IngredientSelector(materials: materials, selectedIngredients: ingredients),
    );

    if (!mounted || result == null) return;
    setState(() => ingredients.add(result));
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (x == null) return;
    setState(() => photoUrl = x.path);
  }


  void _saveProduct() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0;

    if (name.isEmpty || price <= 0 || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }

    final showcase = context.read<ShowcaseRepo>();
    final supplyRepo = context.read<SupplyRepository>();
    final materialsRepo = context.read<MaterialsRepo>();

    final isEditing = widget.editProduct != null || widget.editId != null;

    if (isEditing) {
      final existingId = widget.editProduct?.id ?? widget.editId!;

      final updated = AssembledProduct(
        id: existingId,
        name: name,
        photoUrl: photoUrl,
        ingredients: ingredients,
        costPrice: totalCost,
        sellingPrice: price,
      );

      final oldMap = <String, double>{};
      if (_originalProduct != null) {
        for (final ing in _originalProduct!.ingredients) {
          oldMap[ing.materialKey] = ing.quantity;
        }
      }

      final newMap = <String, double>{};
      for (final ing in ingredients) {
        newMap[ing.materialKey] = ing.quantity;
      }

      final allKeys = {...oldMap.keys, ...newMap.keys};
      for (final key in allKeys) {
        final oldQty = oldMap[key] ?? 0.0;
        final newQty = newMap[key] ?? 0.0;
        final delta = newQty - oldQty;
        if (delta > 0) {
          debugPrint('AssembleProductScreen: editing -> consuming delta for $key: $delta (old: $oldQty -> new: $newQty)');
          supplyRepo.consumeMaterial(materialKey: key, qty: delta);
        } else if (delta < 0) {
          debugPrint('AssembleProductScreen: editing -> returning for $key: ${-delta} (old: $oldQty -> new: $newQty)');
          materialsRepo.returnQuantity(key, -delta);
        }
      }

      showcase.updateProduct(updated);
    } else {
      for (final ing in ingredients) {
        debugPrint('AssembleProductScreen: creating -> consuming ${ing.quantity} of ${ing.materialKey}');
        supplyRepo.consumeMaterial(materialKey: ing.materialKey, qty: ing.quantity);
      }

      showcase.addProduct(AssembledProduct(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        photoUrl: photoUrl,
        ingredients: ingredients,
        costPrice: totalCost,
        sellingPrice: price,
      ));
    }

  Navigator.of(context).pop();
  }

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
      backgroundColor: GlorioColors.background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom + 96,
          right: 6,
        ),
        child: AddButton(onTap: _openIngredientSelector),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
          bottom: MediaQuery.of(context).viewPadding.bottom + GlorioSpacing.page,
        ),
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(GlorioRadius.card),
                  color: GlorioColors.cardAlt,
                  image: image != null ? DecorationImage(image: image, fit: BoxFit.cover) : null,
                ),
                alignment: Alignment.center,
                child: image == null ? Text('Загрузить фото', style: GlorioText.muted) : null,
              ),
            ),
          ),

          const SizedBox(height: 20),

          AppCard(
            child: Column(
              children: [
                AppInput(controller: nameController, hint: 'Название букета'),
                const SizedBox(height: GlorioSpacing.gap),
                AppInput(controller: priceController, hint: 'Цена продажи', keyboardType: TextInputType.number),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text('Себестоимость: ${totalCost.toStringAsFixed(0)} ₽', style: GlorioText.heading),

          const SizedBox(height: 24),

          Text('Ингредиенты', style: GlorioText.heading),
          const SizedBox(height: GlorioSpacing.gapSmall),

          if (ingredients.isEmpty) const Text('Ингредиенты не добавлены', style: GlorioText.muted),

          ...ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ing = entry.value;
            final material = context.read<MaterialsRepo>().getByKey(ing.materialKey);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(material?.name ?? ing.materialKey, style: GlorioText.heading),
                            Text('${ing.quantity} × ${ing.costPerUnit} ₽ = ${ing.totalCost.toStringAsFixed(0)} ₽', style: GlorioText.muted),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => ingredients.removeAt(index))),
                    ],
                  ),
                ),
            );
          }),

          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(left: 12, right: 12, bottom: 18, top: 10),
        child: AppButton(text: 'Сохранить букет', onTap: _saveProduct),
      ),
    );
  }
}