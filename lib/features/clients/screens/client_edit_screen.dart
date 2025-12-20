import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/client.dart';
import '../../../data/repositories/clients_repo.dart';
import '../../../data/repositories/sales_repo.dart';
import '../../../data/models/sale.dart';
import '../../../ui/app_input.dart';
import '../../../ui/app_button.dart';
import '../../../ui/app_card.dart';
import 'relative_form.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';
import '../../../ui/widgets/mini_back_button.dart';

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
  final cashbackCtrl = TextEditingController();
  final pointsCtrl = TextEditingController();

  List<Relative> relatives = [];

  @override
  void initState() {
    super.initState();

    if (widget.client != null) {
      nameCtrl.text = widget.client!.name;
      phoneCtrl.text = widget.client!.phone;
      birthdayCtrl.text = widget.client!.birthday ?? '';
      cashbackCtrl.text = widget.client!.cashbackPercent.toString();
      pointsCtrl.text = widget.client!.pointsBalance.toString();
      relatives = List.from(widget.client!.relatives);
    }
  }

  void save() {
    final repo = context.read<ClientsRepo>();

    final cashback = double.tryParse(cashbackCtrl.text.trim()) ?? 0;
    final points = int.tryParse(pointsCtrl.text.trim()) ?? 0;

    final newClient = Client(
      id: widget.client?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      birthday: birthdayCtrl.text.trim().isEmpty
          ? null
          : birthdayCtrl.text.trim(),
      relatives: relatives,
      cashbackPercent: cashback,
      pointsBalance: points,
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
    final sales = context.watch<SalesRepo>().sales;
    final clientId = widget.client?.id;
    final List<Sale> purchaseHistory = clientId == null
        ? []
        : (sales.where((s) => s.clientId == clientId).toList()
          ..sort((a, b) => b.date.compareTo(a.date)));

    return Scaffold(
      backgroundColor: GlorioColors.background,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              left: GlorioSpacing.page,
              right: GlorioSpacing.page,
              top: GlorioSpacing.page,
              bottom: GlorioSpacing.page,
            ),
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
                    const SizedBox(height: 16),
                    AppInput(
                      controller: cashbackCtrl,
                      hint: 'Cashback %',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: pointsCtrl,
                      hint: 'Баллы лояльности',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// События
              Text('События', style: GlorioText.heading),

              const SizedBox(height: 12),

              if (relatives.isEmpty)
                Text('События не добавлены', style: GlorioText.muted),

              ...relatives.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: GlorioText.heading),
                        const SizedBox(height: 2),
                        Text('Дата события: ${r.birthday}', style: GlorioText.muted),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              AppButton(
                text: 'Добавить событие',
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

              const SizedBox(height: 28),

              /// История покупок
              Text('История покупок', style: GlorioText.heading),
              const SizedBox(height: 12),
              if (purchaseHistory.isEmpty)
                Text('Покупок пока нет', style: GlorioText.muted),
              ...purchaseHistory.map(
                (sale) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${sale.product.name} — ${sale.finalTotal.toStringAsFixed(0)} ₽',
                          style: GlorioText.heading,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Дата: ${sale.date.day.toString().padLeft(2, '0')}.${sale.date.month.toString().padLeft(2, '0')}.${sale.date.year}',
                          style: GlorioText.muted,
                        ),
                        Text('Оплата: ${sale.paymentMethod}', style: GlorioText.muted),
                        Text('Списано баллов: ${sale.usedPoints}', style: GlorioText.muted),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: MiniBackButton(
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}