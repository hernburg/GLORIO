import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/supply.dart';
import '../../../data/repositories/supply_repo.dart';

class SupplyEditScreen extends StatefulWidget {
  final String id;

  const SupplyEditScreen({super.key, required this.id});

  @override
  State<SupplyEditScreen> createState() => _SupplyEditScreenState();
}

class _SupplyEditScreenState extends State<SupplyEditScreen> {
  Supply? supply;

  final nameController = TextEditingController();
  final qtyController = TextEditingController();
  final priceController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final repo = context.read<SupplyRepository>();
    final s = repo.getById(widget.id);

    if (s == null) {
      Navigator.pop(context);
      return;
    }

    supply = s;

    nameController.text = s.name;
    qtyController.text = s.quantity.toString();
    priceController.text = s.purchasePrice.toString();

    setState(() => loading = false);
  }

  Future<void> _save() async {
    if (supply == null) return;

    final repo = context.read<SupplyRepository>();

    final updated = supply!.copyWith(
      name: nameController.text,
      purchasePrice: double.tryParse(priceController.text) ?? supply!.purchasePrice,
      quantity: double.tryParse(qtyController.text) ?? supply!.quantity,
    );

    repo.updateSupply(updated);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Редактировать поставку")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Название материала"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Количество"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Цена закупки"),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text("Сохранить изменения"),
            ),
          ],
        ),
      ),
    );
  }
}
