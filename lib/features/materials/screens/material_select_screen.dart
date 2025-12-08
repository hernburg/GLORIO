import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/models/materialitem.dart';

class MaterialSelectScreen extends StatelessWidget {
  final Function(MaterialItem) onSelect;

  const MaterialSelectScreen({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final materials = context.watch<MaterialsRepo>().materials;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор материала'),
        centerTitle: true,
      ),
      body: materials.isEmpty
          ? const Center(
              child: Text(
                'Нет материалов на складе',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final m = materials[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: m.photoUrl != null
                        ? Image.network(m.photoUrl!)
                        : const Icon(Icons.local_florist, color: Colors.grey),
                  ),
                  title: Text(m.name),
                  subtitle: Text(
                    'Остаток: ${m.quantity} • Себестоимость: ${m.costPerUnit} ₽',
                  ),
                  onTap: () {
                    onSelect(m);
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}
