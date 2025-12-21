import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';
import '../../../ui/app_image.dart';
import '../../../data/repositories/showcase_repo.dart';

class ProductViewScreen extends StatelessWidget {
  final String productId;
  const ProductViewScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final product = context.read<ShowcaseRepo>().getById(productId);
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Букет')),
        body: const Center(child: Text('Букет не найден')),
      );
    }

    return Scaffold(
      backgroundColor: GlorioColors.background,
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: GlorioColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: GlorioSpacing.page,
          bottom: MediaQuery.of(context).viewPadding.bottom + GlorioSpacing.page,
        ),
        children: [
          Center(child: AppImage.square(product.photoUrl, size: 200)),
          const SizedBox(height: 16),
          Text('Цена продажи: ${product.sellingPrice.toStringAsFixed(0)} ₽', style: GlorioText.heading),
          const SizedBox(height: 4),
          Text('Себестоимость: ${product.costPrice.toStringAsFixed(0)} ₽', style: GlorioText.muted),
          const SizedBox(height: 16),
          Text('Состав', style: GlorioText.heading),
          const SizedBox(height: 8),
          ...product.ingredients.map(
            (ing) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(ing.materialKey, style: GlorioText.body)),
                  Text(ing.quantity.toStringAsFixed(2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
