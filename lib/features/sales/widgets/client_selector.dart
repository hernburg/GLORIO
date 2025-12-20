import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/client.dart';
import '../../../data/repositories/clients_repo.dart';

class ClientSelectionResult {
  final Client? client;
  final bool withoutClient;
  final bool createNew;

  const ClientSelectionResult({
    this.client,
    this.withoutClient = false,
    this.createNew = false,
  });
}

Future<ClientSelectionResult?> pickClient(BuildContext context) async {
  // Capture router and other context-derived singletons before awaiting
  final router = GoRouter.of(context);

  while (true) {
    final result = await showModalBottomSheet<ClientSelectionResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        final searchCtrl = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final clients = context.watch<ClientsRepo>().clients;
              final query = searchCtrl.text.toLowerCase();
              final filtered = clients.where((c) {
                return c.name.toLowerCase().contains(query) ||
                    c.phone.toLowerCase().contains(query);
              }).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Выберите клиента',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Поиск...',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320,
                    child: filtered.isEmpty
                        ? const Center(child: Text('Список клиентов пуст'))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final client = filtered[i];
                              return ListTile(
                                title: Text(client.name),
                                subtitle: Text(client.phone),
                                onTap: () => Navigator.pop(
                                  sheetContext,
                                  ClientSelectionResult(client: client),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      const ClientSelectionResult(createNew: true),
                    ),
                    child: const Text('Создать клиента'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      const ClientSelectionResult(withoutClient: true),
                    ),
                    child: const Text('Продать без клиента'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result == null) return null;
    if (result.createNew) {
      await router.push('/clients/edit');
      continue;
    }
    return result;
  }
}
