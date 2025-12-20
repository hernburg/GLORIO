import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/clients_repo.dart';
import '../../../ui/app_card.dart';
import '../../../ui/add_button.dart';
import 'client_edit_screen.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';

class ClientsListScreen extends StatelessWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ClientsRepo>();

    return Scaffold(
      backgroundColor: GlorioColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: GlorioSpacing.page,
          bottom: GlorioSpacing.page,
        ),
        itemCount: repo.clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = repo.clients[i];

          return AppCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientEditScreen(client: c),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c.phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
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