import 'package:flutter/material.dart';
import '../../../data/models/client.dart';

class RelativeFormDialog extends StatefulWidget {
  const RelativeFormDialog({super.key});

  @override
  State<RelativeFormDialog> createState() => _RelativeFormDialogState();
}

class _RelativeFormDialogState extends State<RelativeFormDialog> {
  final nameCtrl = TextEditingController();
  final birthdayCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Добавить близкого"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Имя"),
          ),
          TextField(
            controller: birthdayCtrl,
            decoration: const InputDecoration(
                labelText: "Дата рождения (dd.mm.yyyy)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Отмена"),
        ),
        ElevatedButton(
          onPressed: () {
            final r = Relative(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: nameCtrl.text.trim(),
              birthday: birthdayCtrl.text.trim(),
            );
            Navigator.pop(context, r);
          },
          child: const Text("Добавить"),
        ),
      ],
    );
  }
}