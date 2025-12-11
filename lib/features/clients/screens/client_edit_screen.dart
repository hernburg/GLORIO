import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/client.dart';
import '../../../data/repositories/clients_repo.dart';
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
      birthdayCtrl.text = widget.client!.birthday ?? "";
      relatives = List.from(widget.client!.relatives);
    }
  }

  void save() {
    final repo = context.read<ClientsRepo>();

    final newClient = Client(
      id: widget.client?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 40),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Имя клиента"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneCtrl,
            decoration: const InputDecoration(labelText: "Телефон"),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: birthdayCtrl,
            decoration: const InputDecoration(
              labelText: "Дата рождения (dd.mm.yyyy)",
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            "Близкие",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...relatives.map((r) => ListTile(
                title: Text(r.name),
                subtitle: Text("ДР: ${r.birthday}"),
              )),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () async {
              final newRelative = await showDialog<Relative>(
                context: context,
                builder: (_) => RelativeFormDialog(),
              );

              if (newRelative != null) {
                setState(() => relatives.add(newRelative));
              }
            },
            child: const Text("Добавить близкого"),
          ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: save,
            child: const Text("Сохранить"),
          ),
        ],
      ),
    );
  }
}