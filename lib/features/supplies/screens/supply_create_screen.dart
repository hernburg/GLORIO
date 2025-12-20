import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/supply_item.dart';
import '../../../data/repositories/supply_repo.dart';

import '../../../ui/app_card.dart';
import '../../../ui/app_button.dart';

import '../widgets/supply_item_editor.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';

class SupplyCreateScreen extends StatefulWidget {
  final String? editId;

  const SupplyCreateScreen({super.key, this.editId});

  @override
  State<SupplyCreateScreen> createState() => _SupplyCreateScreenState();
}

class _SupplyCreateScreenState extends State<SupplyCreateScreen> {
  final List<SupplyItem> items = [];
  DateTime? _date;
  bool get isEditing => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final repo = context.read<SupplyRepository>();
      final s = repo.getById(widget.editId!);
      if (s != null) {
        _date = s.date;
        items.addAll(s.items.map((e) => e.copyWith()));
      }
    }
    _date ??= DateTime.now();
  }

  // ---------------------------------------------------------------------------
  // SAVE SUPPLY
  // ---------------------------------------------------------------------------
  void _save() {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы одну позицию')),
      );
      return;
    }

    final repo = context.read<SupplyRepository>();

    if (isEditing) {
      repo.updateSupply(id: widget.editId!, date: _date ?? DateTime.now(), items: items);
    } else {
      repo.addSupply(date: _date ?? DateTime.now(), items: items);
    }

    Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // ADD POSITION
  // ---------------------------------------------------------------------------
  Future<void> _addItem() async {
    final result = await showModalBottomSheet<SupplyItem>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const SupplyItemEditor(),
    );

    if (result != null) {
      setState(() {
        items.add(result);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlorioColors.background,
      appBar: AppBar(backgroundColor: GlorioColors.background, title: const Text('Новая поставка')),
      body: ListView(
          padding: EdgeInsets.only(
            left: GlorioSpacing.page,
            right: GlorioSpacing.page,
            top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
            bottom: GlorioSpacing.page,
          ),
        children: [
          // -------------------------------------------------
          // POSITIONS
          // -------------------------------------------------
          if (items.isEmpty)
            const Text(
              'Позиции не добавлены',
              style: TextStyle(color: Color(0xFF7A7A7A)),
            ),

          ...items.map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${i.categoryName} • ${i.quantity} × ${i.costPerUnit} ₽',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------
          // ADD POSITION
          // -------------------------------------------------
          AppButton(
            text: 'Добавить позицию',
            onTap: _addItem,
          ),

          const SizedBox(height: 24),

          // -------------------------------------------------
          // SAVE SUPPLY
          // -------------------------------------------------
          AppButton(
            text: 'Сохранить поставку',
            onTap: _save,
          ),
        ],
      ),
    );
  }
}