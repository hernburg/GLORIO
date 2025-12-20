import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/models/materialitem.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';

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
      appBar: AppBar(backgroundColor: GlorioColors.background, title: Text('Выбор материала', style: GlorioText.heading), centerTitle: true,),
      body: materials.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: GlorioSpacing.page,
                  right: GlorioSpacing.page,
                  top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
                ),
                child: Text('Нет материалов на складе', style: GlorioText.muted.copyWith(fontSize: 18)),
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
                    backgroundColor: GlorioColors.cardAlt,
                    child: m.photoUrl != null ? Image.network(m.photoUrl!) : Icon(Icons.local_florist, color: GlorioColors.textMuted),
                  ),
                  title: Text(m.name, style: GlorioText.body),
                  subtitle: Text('Остаток: ${m.quantity} • Себестоимость: ${m.costPerUnit} ₽', style: GlorioText.muted),
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
