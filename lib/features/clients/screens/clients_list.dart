import 'package:flower_accounting_app/core/widgets/add_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/clients_repo.dart';
import 'client_edit_screen.dart';

class ClientsListScreen extends StatelessWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ClientsRepo>();

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: repo.clients.length,
        itemBuilder: (context, i) {
          final c = repo.clients[i];

          return ListTile(
            tileColor: Colors.white.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(c.name),
            subtitle: Text(c.phone),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientEditScreen(client: c),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: AddButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ClientEditScreen(),
            ),
          );
        },
      ),
    );
  }
}