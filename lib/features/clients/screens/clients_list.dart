import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/clients_repo.dart';
import '../../../ui/app_card.dart';
import '../../../ui/add_button.dart';
import '../../../ui/app_input.dart';
import 'client_edit_screen.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_text.dart';
import '../../../design/glorio_spacing.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ClientsRepo>();
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = repo.clients
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.phone.toLowerCase().contains(query))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final Map<String, List<int>> grouped = {};
    for (final c in filtered) {
      final letter = c.name.isNotEmpty
          ? c.name[0].toUpperCase()
          : '#';
      grouped.putIfAbsent(letter, () => []).add(filtered.indexOf(c));
    }
    final letters = grouped.keys.toList()..sort();
    _sectionKeys.clear();
    for (final l in letters) {
      _sectionKeys[l] = GlobalKey();
    }

    return Scaffold(
      backgroundColor: GlorioColors.background,
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: GlorioSpacing.page,
              right: GlorioSpacing.page,
              top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
              bottom: MediaQuery.of(context).viewPadding.bottom + GlorioSpacing.page,
            ),
            children: [
              AppInput(
                controller: _searchCtrl,
                hint: 'Поиск по имени или телефону',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: GlorioSpacing.gap),
              ...letters.map((letter) {
                final indices = grouped[letter]!;
                return Column(
                  key: _sectionKeys[letter],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(letter, style: GlorioText.heading.copyWith(fontSize: 18)),
                    ),
                    ...indices.map((idx) {
                      final c = filtered[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
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
                              Text(c.name, style: GlorioText.heading),
                              const SizedBox(height: 4),
                              Text(c.phone, style: GlorioText.muted),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: GlorioSpacing.gap),
                  child: Center(
                    child: Text('Нет клиентов', style: GlorioText.muted),
                  ),
                ),
            ],
          ),

          // Alphabet index bar
          Positioned(
            right: 4,
            top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
            bottom: MediaQuery.of(context).viewPadding.bottom + GlorioSpacing.page,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: letters.map((l) {
                return GestureDetector(
                  onTap: () {
                    final key = _sectionKeys[l];
                    if (key?.currentContext != null) {
                      Scrollable.ensureVisible(
                        key!.currentContext!,
                        duration: const Duration(milliseconds: 250),
                        alignment: 0.0,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                    child: Text(
                      l,
                      style: GlorioText.muted.copyWith(fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom + 96,
          right: 6,
        ),
        child: AddButton(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ClientEditScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}