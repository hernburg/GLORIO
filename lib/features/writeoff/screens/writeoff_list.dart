import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/materialitem.dart';
import '../../../data/models/writeoff.dart';
import '../../../data/repositories/materials_repo.dart';
import '../../../data/repositories/writeoff_repo.dart';
import '../../../data/services/writeoff_service.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';

class WriteoffListScreen extends StatefulWidget {
  const WriteoffListScreen({super.key});

  @override
  State<WriteoffListScreen> createState() => _WriteoffListScreenState();
}

class _WriteoffListScreenState extends State<WriteoffListScreen> {
  String? _selectedMaterialKey;
  final _qtyController = TextEditingController();
  final _reasonController = TextEditingController();
  final _employeeController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    _employeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialsRepo = context.watch<MaterialsRepo>();
    final writeoffRepo = context.watch<WriteoffRepository>();
    final writeoffService = context.read<WriteoffService>();

    final materials = materialsRepo.materials.where((m) => !m.isInfinite).toList();

    return Scaffold(
      backgroundColor: GlorioColors.background,
      appBar: AppBar(
        title: const Text('Списания (брак)'),
        backgroundColor: GlorioColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: GlorioSpacing.page,
          bottom: GlorioSpacing.page,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WriteoffForm(
              materials: materials,
              selectedMaterialKey: _selectedMaterialKey,
              qtyController: _qtyController,
              reasonController: _reasonController,
              employeeController: _employeeController,
              onMaterialChanged: (value) => setState(() => _selectedMaterialKey = value),
              onSubmit: () => _handleSubmit(context, writeoffService),
            ),
            const SizedBox(height: 24),
            Text(
              'Журнал списаний',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (writeoffRepo.writeoffs.isEmpty)
              const Text('Пока нет списаний')
            else
              ...writeoffRepo.writeoffs.map((w) => _WriteoffTile(writeoff: w)),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context, WriteoffService service) {
    final materialKey = _selectedMaterialKey;
    if (materialKey == null) {
      _showSnack(context, 'Выберите материал');
      return;
    }

    final qty = double.tryParse(_qtyController.text.replaceAll(',', '.'));
    if (qty == null || qty <= 0) {
      _showSnack(context, 'Введите количество > 0');
      return;
    }

    final reason = _reasonController.text.trim();
    final employee = _employeeController.text.trim().isEmpty ? 'Не указано' : _employeeController.text.trim();

    try {
      service.writeoffSpoiled(
        materialKey: materialKey,
        quantity: qty,
        reason: reason.isEmpty ? 'Брак' : reason,
        employee: employee,
      );

      _qtyController.clear();
      _reasonController.clear();
      _employeeController.clear();
      setState(() => _selectedMaterialKey = null);

      _showSnack(context, 'Списание добавлено');
    } catch (e) {
      _showSnack(context, 'Ошибка: $e');
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _WriteoffForm extends StatelessWidget {
  const _WriteoffForm({
    required this.materials,
    required this.selectedMaterialKey,
    required this.qtyController,
    required this.reasonController,
    required this.employeeController,
    required this.onMaterialChanged,
    required this.onSubmit,
  });

  final List<MaterialItem> materials;
  final String? selectedMaterialKey;
  final TextEditingController qtyController;
  final TextEditingController reasonController;
  final TextEditingController employeeController;
  final ValueChanged<String?> onMaterialChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Списать испорченный товар',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedMaterialKey,
              items: materials
                  .map(
                    (m) => DropdownMenuItem(
                      value: m.id,
                      child: Text('${m.name} (ост: ${m.quantity.toStringAsFixed(2)})'),
                    ),
                  )
                  .toList(),
              onChanged: onMaterialChanged,
              decoration: const InputDecoration(
                labelText: 'Материал',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Количество',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Причина (опционально)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: employeeController,
              decoration: const InputDecoration(
                labelText: 'Сотрудник',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: materials.isEmpty ? null : onSubmit,
                child: const Text('Списать'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WriteoffTile extends StatelessWidget {
  const _WriteoffTile({required this.writeoff});

  final Writeoff writeoff;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(writeoff.materialName),
        subtitle: Text('${writeoff.quantity} • ${writeoff.reason}'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('-${writeoff.quantity.toStringAsFixed(2)}'),
            if (writeoff.totalCost > 0)
              Text('${writeoff.totalCost.toStringAsFixed(2)} ₽', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

