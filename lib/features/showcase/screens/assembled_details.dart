import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/app_card.dart';
import '../../../ui/app_button.dart';

import '../../../data/models/assembled_product.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';

class AssembledDetailsScreen extends StatelessWidget {
  final AssembledProduct item;

  const AssembledDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (item.photoUrl != null && item.photoUrl!.isNotEmpty) {
      final uri = Uri.tryParse(item.photoUrl!);
      if (uri != null &&
          uri.hasAbsolutePath &&
          (uri.scheme == 'http' || uri.scheme == 'https')) {
        imageProvider = NetworkImage(item.photoUrl!);
      } else if (!kIsWeb && File(item.photoUrl!).existsSync()) {
        imageProvider = FileImage(File(item.photoUrl!));
      }
    }

    return Scaffold(
      backgroundColor: GlorioColors.background,
        appBar: AppBar(
        backgroundColor: GlorioColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: GlorioColors.textPrimary),
        title: Text('Букет', style: GlorioText.heading),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
          bottom: GlorioSpacing.page,
        ),
        children: [
          /// Фото
          AppCard(
            padding: EdgeInsets.zero,
            child: Container(
                height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: GlorioColors.cardAlt,
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: imageProvider == null
                  ? Text('Без фото', style: GlorioText.muted)
                  : null,
            ),
          ),

          const SizedBox(height: 20),

          /// Название + цены
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: GlorioText.heading.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Цена продажи: ${item.sellingPrice.toStringAsFixed(0)} ₽', style: GlorioText.body),
                Text('Себестоимость: ${item.costPrice.toStringAsFixed(0)} ₽', style: GlorioText.muted),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text('Состав', style: GlorioText.heading),

          const SizedBox(height: 12),

          ...item.ingredients.map((ing) {
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
                          Text(material?.name ?? ing.materialKey, style: GlorioText.heading.copyWith(fontSize: 15)),
                          Text('${ing.quantity} × ${ing.costPerUnit} ₽', style: GlorioText.muted),
                        ],
                      ),
                    ),
                    Text('${ing.totalCost.toStringAsFixed(0)} ₽', style: GlorioText.heading),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          /// Действия
          AppButton(
            text: 'Редактировать',
            onTap: () {
              context.push('/assemble_edit/${item.id}');
            },
          ),
        ],
      ),
    );
  }
}