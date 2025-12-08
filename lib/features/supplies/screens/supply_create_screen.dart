import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/supply.dart';
import '../../../data/repositories/supply_repo.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/models/materialitem.dart';

class SupplyCreateScreen extends StatefulWidget {
  const SupplyCreateScreen({super.key});

  @override
  State<SupplyCreateScreen> createState() => _SupplyCreateScreenState();
}

class _SupplyCreateScreenState extends State<SupplyCreateScreen> {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  XFile? pickedImage;

  // 📸 Выбор фото
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() => pickedImage = img);
    }
  }

  // 💾 Сохранение поставки
  void save() {
    final name = nameCtrl.text.trim();
    final qty = double.tryParse(qtyCtrl.text) ?? 0;
    final price = double.tryParse(priceCtrl.text) ?? 0;

    if (name.isEmpty || qty <= 0 || price <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final supply = Supply(
      id: id,
      name: name,
      quantity: qty,
      purchasePrice: price,
      supplyDate: DateTime.now(),
      usedInBouquets: 0,
      writtenOff: 0,
      photoUrl: pickedImage?.path,
    );

    final supplies = context.read<SupplyRepository>();
    final materials = context.read<MaterialsRepo>();

    supplies.addSupply(supply);

    materials.addMaterial(
      MaterialItem(
        id: id,
        name: name,
        quantity: qty,
        costPerUnit: price,
        supplyId: id,
        photoUrl: pickedImage?.path,
        categoryId: 'flowers',
        categoryName: 'Цветы',
        isInfinite: false,
      ),
    );

    context.pop();
  }

  // 🎨 Стиль полей ввода
  InputDecoration _decor(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.28),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая поставка')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------- БЛОК С ФОТО ----------
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade300,
                  image: pickedImage != null
                      ? DecorationImage(
                          image: FileImage(File(pickedImage!.path)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: pickedImage == null
                    ? const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            TextField(controller: nameCtrl, decoration: _decor('Название товара')),
            const SizedBox(height: 18),

            TextField(
              controller: qtyCtrl,
              decoration: _decor('Количество'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),

            TextField(
              controller: priceCtrl,
              decoration: _decor('Цена закупки'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: save,
                child: const Text('Сохранить поставку'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}