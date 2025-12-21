import 'package:flutter/material.dart';
import '../../../data/models/client.dart';
import '../../../ui/app_button.dart';

class RelativeFormDialog extends StatefulWidget {
  const RelativeFormDialog({super.key});

  @override
  State<RelativeFormDialog> createState() => _RelativeFormDialogState();
}

class _RelativeFormDialogState extends State<RelativeFormDialog> {
  final nameCtrl = TextEditingController();
  final birthdayCtrl = TextEditingController();

  void submit() {
    final name = nameCtrl.text.trim();
    final birthday = birthdayCtrl.text.trim();

    if (name.isEmpty || birthday.isEmpty) {
      return;
    }

    final relative = Relative(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      birthday: birthday,
    );

    Navigator.pop(context, relative);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Добавить событие',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Название события',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: birthdayCtrl,
              decoration: const InputDecoration(
                labelText: 'Дата события (дд.мм.гггг)',
              ),
            ),

            const SizedBox(height: 24),

            AppButton(
              text: 'Добавить событие',
              onTap: submit,
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }
}