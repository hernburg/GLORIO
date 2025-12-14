import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/client.dart';
import '../../../data/repositories/clients_repo.dart';
import '../../../ui/app_input.dart';
import '../../../ui/app_button.dart';
import '../../../ui/app_card.dart';
import 'relative_form.dart';

class ClientEditScreen extends StatefulWidget {
  final Client? client;

  const ClientEditScreen({super.key, this.client});

  @override
  State<ClientEditScreen> createState() => _ClientEditScreenState();
}

class _ClientEditScreenState extends State<ClientEditScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final birthdayCtrl = TextEditingController();

  List<Relative> relatives = [];

  @override
  void initState() {
    super.initState();

    if (widget.client != null) {
      nameCtrl.text = widget.client!.name;
      phoneCtrl.text = widget.client!.phone;
      birthdayCtrl.text = widget.client!.birthday ?? '';
      relatives = List.from(widget.client!.relatives);
    }
  }

  void save() {
    final repo = context.read<ClientsRepo>();

    final newClient = Client(
      id: widget.client?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      birthday: birthdayCtrl.text.trim().isEmpty
          ? null
          : birthdayCtrl.text.trim(),
      relatives: relatives,
    );

    if (widget.client == null) {
      repo.addClient(newClient);
    } else {
      repo.updateClient(newClient);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EE),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),

          /// Данные клиента
          AppCard(
            child: Column(
              children: [
                AppInput(
                  controller: nameCtrl,
                  hint: 'Имя клиента',
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: phoneCtrl,
                  hint: 'Телефон',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: birthdayCtrl,
                  hint: 'Дата рождения (дд.мм.гггг)',
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          /// Близкие
          const Text(
            'Близкие',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E2E2E),
            ),
          ),

          const SizedBox(height: 12),

          if (relatives.isEmpty)
            const Text(
              'Связанные лица не добавлены',
              style: TextStyle(
                color: Color(0xFF7A7A7A),
                fontSize: 14,
              ),
            ),

          ...relatives.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ДР: ${r.birthday}',
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

AppButton(
  text: 'Добавить близкого',
  onTap: () async {
    final newRelative = await showDialog<Relative>(
      context: context,
      builder: (_) => const RelativeFormDialog(),
    );

    if (newRelative != null) {
      setState(() => relatives.add(newRelative));
    }
  },
),

          const SizedBox(height: 32),

          AppButton(
  text: 'Сохранить',
  onTap: save,
),
        ],
      ),
    );
  }
}