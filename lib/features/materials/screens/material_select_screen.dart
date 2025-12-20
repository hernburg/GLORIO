import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/models/materialitem.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';

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
      backgroundColor: GlorioColors.background,
      appBar: AppBar(
        backgroundColor: GlorioColors.background,
        title: const Text('Выбор материала'),
        centerTitle: true,
      ),
      body: materials.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: GlorioSpacing.page,
                  right: GlorioSpacing.page,
                  top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
                ),
                child: const Text(
                  'Нет материалов на складе',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(
                left: GlorioSpacing.page,
                right: GlorioSpacing.page,
                top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
                bottom: GlorioSpacing.page,
              ),
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
