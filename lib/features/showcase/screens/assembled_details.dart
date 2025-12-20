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
        iconTheme: const IconThemeData(color: Color(0xFF2E2E2E)),
        title: const Text(
          'Букет',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.w600,
          ),
        ),
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
                color: Colors.grey.shade200,
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: imageProvider == null
                  ? const Text(
                      'Без фото',
                      style: TextStyle(color: Color(0xFF7A7A7A)),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 20),

          /// Название + цены
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Цена продажи: ${item.sellingPrice.toStringAsFixed(0)} ₽',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Себестоимость: ${item.costPrice.toStringAsFixed(0)} ₽',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Состав',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E2E2E),
            ),
          ),

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
                          Text(
                            material?.name ?? ing.materialKey,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${ing.quantity} × ${ing.costPerUnit} ₽',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A7A7A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${ing.totalCost.toStringAsFixed(0)} ₽',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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