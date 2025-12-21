import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/reports.dart';
import '../../../data/services/reports_service.dart';
import '../../../data/services/report_exporter.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';
import '../../../design/glorio_text.dart';
import '../../../ui/app_card.dart';
import '../../../ui/app_button.dart';

class ReportsDashboard extends StatefulWidget {
  const ReportsDashboard({super.key});

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {
  ReportRange _range = ReportRange.month;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsService>();
    final period = reports.resolvePeriod(_range);

    final sales = reports.salesReport(period);
    final profit = reports.profitReport(period);
    final supply = reports.supplyReport(period);
    final writeoff = reports.writeOffReport(period);
    final stock = reports.stockReport();
    final loyalty = reports.loyaltyReport(period);
    final cashflow = reports.cashflowReport(period);

    return Scaffold(
      backgroundColor: GlorioColors.background,
      body: ListView(
        padding: EdgeInsets.only(
          left: GlorioSpacing.page,
          right: GlorioSpacing.page,
          top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
          // добавляем запас снизу, чтобы кнопки экспортов не перекрывались нижним меню
          bottom: MediaQuery.of(context).viewPadding.bottom + GlorioSpacing.page + 96,
        ),
        children: [
          Row(
            children: [
              Text('Отчёты', style: GlorioText.heading),
              const Spacer(),
              Text(_periodLabel(_range), style: GlorioText.muted),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ReportRange.values
                .map((r) => ChoiceChip(
                      label: Text(_periodLabel(r)),
                      selected: _range == r,
                      onSelected: (_) => setState(() => _range = r),
                    ))
                .toList(),
          ),

          const SizedBox(height: 16),

          _SummaryCard(
            period,
            profit,
            onPdf: () => _runExport(() => ReportExporter.exportPdfSection(context: context, reports: reports, range: _range, section: ReportSection.summary)),
            onExcel: () => _runExport(() => ReportExporter.exportExcelSection(context: context, reports: reports, range: _range, section: ReportSection.summary)),
          ),
          const SizedBox(height: 16),

          _SalesCard(
            sales: sales,
            showcaseCount: reports.showcaseRepo.products.length,
            onPdf: () => _runExport(() => ReportExporter.exportPdfSection(context: context, reports: reports, range: _range, section: ReportSection.sales)),
            onExcel: () => _runExport(() => ReportExporter.exportExcelSection(context: context, reports: reports, range: _range, section: ReportSection.sales)),
          ),
          const SizedBox(height: 16),

          _SupplyCard(
            supply: supply,
            onPdf: () => _runExport(() => ReportExporter.exportPdfSection(context: context, reports: reports, range: _range, section: ReportSection.supply)),
            onExcel: () => _runExport(() => ReportExporter.exportExcelSection(context: context, reports: reports, range: _range, section: ReportSection.supply)),
          ),
          const SizedBox(height: 16),

          _StockCard(
            stock: stock,
            onPdf: () => _runExport(() => ReportExporter.exportPdfSection(context: context, reports: reports, range: _range, section: ReportSection.stock)),
            onExcel: () => _runExport(() => ReportExporter.exportExcelSection(context: context, reports: reports, range: _range, section: ReportSection.stock)),
          ),
          const SizedBox(height: 16),

          _LoyaltyCard(
            loyalty: loyalty,
            onPdf: () => _runExport(() => ReportExporter.exportPdfSection(context: context, reports: reports, range: _range, section: ReportSection.loyalty)),
            onExcel: () => _runExport(() => ReportExporter.exportExcelSection(context: context, reports: reports, range: _range, section: ReportSection.loyalty)),
          ),
          const SizedBox(height: 16),

          _CashflowCard(
            cashflow: cashflow,
            writeoff: writeoff,
            onPdf: () => _runExport(() => ReportExporter.exportPdfSection(context: context, reports: reports, range: _range, section: ReportSection.cashflow)),
            onExcel: () => _runExport(() => ReportExporter.exportExcelSection(context: context, reports: reports, range: _range, section: ReportSection.cashflow)),
          ),
          const SizedBox(height: 16),

          _ExportActions(
            exporting: _exporting,
            onPdf: () => _runExport(
              () => ReportExporter.exportPdf(
                context: context,
                reports: reports,
                range: _range,
              ),
            ),
            onExcel: () => _runExport(
              () => ReportExporter.exportExcel(
                context: context,
                reports: reports,
                range: _range,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _periodLabel(ReportRange range) {
    switch (range) {
      case ReportRange.today:
        return 'Сегодня';
      case ReportRange.week:
        return 'Неделя';
      case ReportRange.month:
        return 'Месяц';
      case ReportRange.all:
        return 'Все время';
    }
  }

  Future<void> _runExport(Future<void> Function() action) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Экспорт завершён')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final Period period;
  final ProfitReport profit;
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  const _SummaryCard(this.period, this.profit, {required this.onPdf, required this.onExcel});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Итог за период', style: GlorioText.heading),
              const Spacer(),
              _MiniExport(onPdf: onPdf, onExcel: onExcel),
            ],
          ),
          const SizedBox(height: 4),
          Text(_formatRange(period), style: GlorioText.muted),
          const SizedBox(height: 12),
          _MetricRow(label: 'Выручка', value: _money(profit.totalRevenue)),
          _MetricRow(label: 'Себестоимость', value: _money(profit.totalCost)),
          const Divider(height: 24),
          _MetricRow(label: 'Прибыль', value: _money(profit.grossProfit), isPrimary: true),
          _MetricRow(label: 'Маржа', value: '${profit.marginPercent.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  final SalesReport sales;
  final int showcaseCount;
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  const _SalesCard({required this.sales, required this.showcaseCount, required this.onPdf, required this.onExcel});

  @override
  Widget build(BuildContext context) {
    final top = sales.topProducts.isNotEmpty ? sales.topProducts.first : null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Продажи', style: GlorioText.heading),
              const Spacer(),
              _MiniExport(onPdf: onPdf, onExcel: onExcel),
            ],
          ),
          const SizedBox(height: 12),
          _MetricRow(label: 'Продаж', value: sales.salesCount.toString()),
          _MetricRow(label: 'Средний чек', value: _money(sales.averageCheck)),
          _MetricRow(label: 'Выручка', value: _money(sales.totalRevenue)),
          _MetricRow(label: 'В витрине', value: showcaseCount.toString()),
          if (top != null)
            _MetricRow(label: 'Топ товар', value: '${top.name} (${_money(top.revenue)})'),
        ],
      ),
    );
  }
}

class _SupplyCard extends StatelessWidget {
  final SupplyReport supply;
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  const _SupplyCard({required this.supply, required this.onPdf, required this.onExcel});

  @override
  Widget build(BuildContext context) {
    final top = supply.topMaterialsByCost.isNotEmpty ? supply.topMaterialsByCost.first : null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Поставки', style: GlorioText.heading),
              const Spacer(),
              _MiniExport(onPdf: onPdf, onExcel: onExcel),
            ],
          ),
          const SizedBox(height: 12),
          _MetricRow(label: 'Поставок', value: supply.suppliesCount.toString()),
          _MetricRow(label: 'Сумма', value: _money(supply.totalSupplyCost)),
          if (top != null)
            _MetricRow(label: 'Топ материал', value: '${top.name} (${_money(top.cost)})'),
        ],
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final StockReport stock;
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  const _StockCard({required this.stock, required this.onPdf, required this.onExcel});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Склад', style: GlorioText.heading),
              const Spacer(),
              _MiniExport(onPdf: onPdf, onExcel: onExcel),
            ],
          ),
          const SizedBox(height: 12),
          _MetricRow(label: 'Позиции', value: stock.itemsCount.toString()),
          _MetricRow(label: 'Стоимость', value: _money(stock.totalStockValue)),
          if (stock.deadStock.isNotEmpty)
            _MetricRow(label: 'Неликвид', value: stock.deadStock.first.name),
        ],
      ),
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  final LoyaltyReport loyalty;
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  const _LoyaltyCard({required this.loyalty, required this.onPdf, required this.onExcel});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Лояльность', style: GlorioText.heading),
              const Spacer(),
              _MiniExport(onPdf: onPdf, onExcel: onExcel),
            ],
          ),
          const SizedBox(height: 12),
          _MetricRow(label: 'Клиентов', value: loyalty.uniqueClientsCount.toString()),
          _MetricRow(label: 'Средний чек/клиент', value: _money(loyalty.averageCheckPerClient)),
          _MetricRow(label: 'Баланс баллов', value: loyalty.totalPointsBalance.toString()),
          _MetricRow(label: 'Потрачено баллов', value: loyalty.pointsSpent.toString()),
        ],
      ),
    );
  }
}

class _CashflowCard extends StatelessWidget {
  final CashflowReport cashflow;
  final WriteOffReport writeoff;
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  const _CashflowCard({required this.cashflow, required this.writeoff, required this.onPdf, required this.onExcel});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Движение денег', style: GlorioText.heading),
              const Spacer(),
              _MiniExport(onPdf: onPdf, onExcel: onExcel),
            ],
          ),
          const SizedBox(height: 12),
          _MetricRow(label: 'Поступления', value: _money(cashflow.inflow)),
          _MetricRow(label: 'Списания', value: _money(cashflow.outflow)),
          _MetricRow(label: 'Списания (брак)', value: _money(writeoff.totalWriteOffCost)),
          const Divider(height: 24),
          _MetricRow(label: 'Итого', value: _money(cashflow.netCashFlow), isPrimary: true),
        ],
      ),
    );
  }
}

class _ExportActions extends StatelessWidget {
  final VoidCallback onPdf;
  final VoidCallback onExcel;
  final bool exporting;

  const _ExportActions({
    required this.onPdf,
    required this.onExcel,
    required this.exporting,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Экспорт', style: GlorioText.heading),
          const SizedBox(height: 12),
          AppButton(
            text: exporting ? 'Готовим PDF…' : 'Экспорт PDF',
            onTap: exporting ? () {} : onPdf,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: exporting ? 'Готовим Excel…' : 'Экспорт Excel',
            onTap: exporting ? () {} : onExcel,
            primary: false,
          ),
        ],
      ),
    );
  }
}

class _MiniExport extends StatelessWidget {
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  const _MiniExport({required this.onPdf, required this.onExcel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          onPressed: onPdf,
          tooltip: 'PDF',
        ),
        IconButton(
          icon: const Icon(Icons.grid_on, size: 18),
          onPressed: onExcel,
          tooltip: 'Excel',
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _MetricRow({
    required this.label,
    required this.value,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GlorioText.muted)),
          Text(value, style: isPrimary ? GlorioText.heading : GlorioText.body),
        ],
      ),
    );
  }
}

String _money(double value) {
  return '${value.toStringAsFixed(0)} ₽';
}

String _formatRange(Period period) {
  final from = _formatDate(period.from);
  final to = _formatDate(period.to);
  return '$from – $to';
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d.$m';
}