import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'reports_service.dart';
import '../models/reports.dart';

enum ReportSection { summary, sales, supply, stock, loyalty, cashflow }

class ReportExporter {
  ReportExporter._();

  static Future<void> exportPdfSection({
    required BuildContext context,
    required ReportsService reports,
    required ReportRange range,
    required ReportSection section,
  }) async {
    final origin = _shareOrigin(context);
    final period = reports.resolvePeriod(range);
    final data = _collect(reports, period);

    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansSemiBold();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
      ),
    );

    final heading = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, fontFallback: [baseFont]);
    final body = pw.TextStyle(fontSize: 12, fontFallback: [baseFont]);

    final widgets = _sectionWidgets(section, data, heading, body);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Text(_sectionTitle(section), style: heading),
          pw.SizedBox(height: 4),
          pw.Text('${_periodLabel(range)} — ${_rangeDates(period)}', style: body),
          pw.SizedBox(height: 12),
          ...widgets,
        ],
      ),
    );

    final bytes = await doc.save();
    final path = await _writeTemp(bytes, 'report_${section.name}_${range.name}.pdf');
    await _shareFile(path, 'Отчёт: ${_sectionTitle(section)} (${_periodLabel(range)})', origin);
  }

  static Future<void> exportExcelSection({
    required BuildContext context,
    required ReportsService reports,
    required ReportRange range,
    required ReportSection section,
  }) async {
    final origin = _shareOrigin(context);
    final period = reports.resolvePeriod(range);
    final data = _collect(reports, period);

    final excel = Excel.createExcel();
    final sheet = excel[_sectionTitle(section)];

    int r = 0;
    void add(String key, String value) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r)).value = key;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: r)).value = value;
      r++;
    }

    add('Период', _periodLabel(range));
    add('Даты', _rangeDates(period));
    r++;

    for (final row in _sectionRows(section, data)) {
      add(row.$1, row.$2);
    }

    final bytes = Uint8List.fromList(excel.encode()!);
    final path = await _writeTemp(bytes, 'report_${section.name}_${range.name}.xlsx');
    await _shareFile(path, 'Отчёт: ${_sectionTitle(section)} (${_periodLabel(range)})', origin);
  }

  static Future<void> exportPdf({
    required BuildContext context,
    required ReportsService reports,
    required ReportRange range,
  }) async {
    final origin = _shareOrigin(context);

    final period = reports.resolvePeriod(range);
    final sales = reports.salesReport(period);
    final profit = reports.profitReport(period);
    final supply = reports.supplyReport(period);
    final writeoff = reports.writeOffReport(period);
    final stock = reports.stockReport();
    final loyalty = reports.loyaltyReport(period);
    final cashflow = reports.cashflowReport(period);

    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansSemiBold();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
      ),
    );

    final titleStyle = pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, fontFallback: [baseFont]);
    final heading = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, fontFallback: [baseFont]);
    final body = pw.TextStyle(fontSize: 12, fontFallback: [baseFont]);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Отчёт', style: titleStyle),
              pw.Text(_periodLabel(range), style: body),
            ],
          ),
          pw.Text(_rangeDates(period), style: body),
          pw.SizedBox(height: 12),
          pw.Divider(),
          _section('Итог', [
            _line('Выручка', _money(profit.totalRevenue)),
            _line('Себестоимость', _money(profit.totalCost)),
            _line('Прибыль', _money(profit.grossProfit)),
            _line('Маржа', '${profit.marginPercent.toStringAsFixed(1)}%'),
          ], heading, body),
          _section('Продажи', [
            _line('Продаж', sales.salesCount.toString()),
            _line('Средний чек', _money(sales.averageCheck)),
            _line('Выручка', _money(sales.totalRevenue)),
            if (sales.topProducts.isNotEmpty)
              _line('Топ товар', '${sales.topProducts.first.name} (${_money(sales.topProducts.first.revenue)})'),
          ], heading, body),
          _section('Поставки', [
            _line('Поставок', supply.suppliesCount.toString()),
            _line('Сумма', _money(supply.totalSupplyCost)),
            if (supply.topMaterialsByCost.isNotEmpty)
              _line('Топ материал', '${supply.topMaterialsByCost.first.name} (${_money(supply.topMaterialsByCost.first.cost)})'),
          ], heading, body),
          _section('Склад', [
            _line('Позиции', stock.itemsCount.toString()),
            _line('Стоимость', _money(stock.totalStockValue)),
          ], heading, body),
          _section('Лояльность', [
            _line('Клиентов', loyalty.uniqueClientsCount.toString()),
            _line('Средний чек/клиент', _money(loyalty.averageCheckPerClient)),
            _line('Баланс баллов', loyalty.totalPointsBalance.toString()),
            _line('Потрачено баллов', loyalty.pointsSpent.toString()),
          ], heading, body),
          _section('Движение денег', [
            _line('Поступления', _money(cashflow.inflow)),
            _line('Списания', _money(cashflow.outflow)),
            _line('Списания (брак)', _money(writeoff.totalWriteOffCost)),
            _line('Итого', _money(cashflow.netCashFlow)),
          ], heading, body),
        ],
      ),
    );

    final bytes = await doc.save();
    final path = await _writeTemp(bytes, 'report_${range.name}.pdf');
    await _shareFile(path, 'Отчёт (${_periodLabel(range)})', origin);
  }

  static Future<void> exportExcel({
    required BuildContext context,
    required ReportsService reports,
    required ReportRange range,
  }) async {
    final origin = _shareOrigin(context);

    final period = reports.resolvePeriod(range);
    final sales = reports.salesReport(period);
    final profit = reports.profitReport(period);
    final supply = reports.supplyReport(period);
    final writeoff = reports.writeOffReport(period);
    final stock = reports.stockReport();
    final loyalty = reports.loyaltyReport(period);
    final cashflow = reports.cashflowReport(period);

    final excel = Excel.createExcel();
    final sheet = excel['Отчёт'];

    int r = 0;
    void add(String key, String value) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r)).value = key;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: r)).value = value;
      r++;
    }

    add('Период', _periodLabel(range));
    add('Даты', _rangeDates(period));
    r++;

    add('--- Итог ---', '');
    add('Выручка', _money(profit.totalRevenue));
    add('Себестоимость', _money(profit.totalCost));
    add('Прибыль', _money(profit.grossProfit));
    add('Маржа %', profit.marginPercent.toStringAsFixed(1));
    r++;

    add('--- Продажи ---', '');
    add('Продаж', sales.salesCount.toString());
    add('Средний чек', _money(sales.averageCheck));
    add('Выручка', _money(sales.totalRevenue));
    if (sales.topProducts.isNotEmpty) {
      add('Топ товар', '${sales.topProducts.first.name} (${_money(sales.topProducts.first.revenue)})');
    }
    r++;

    add('--- Поставки ---', '');
    add('Поставок', supply.suppliesCount.toString());
    add('Сумма', _money(supply.totalSupplyCost));
    if (supply.topMaterialsByCost.isNotEmpty) {
      add('Топ материал', '${supply.topMaterialsByCost.first.name} (${_money(supply.topMaterialsByCost.first.cost)})');
    }
    r++;

    add('--- Склад ---', '');
    add('Позиции', stock.itemsCount.toString());
    add('Стоимость', _money(stock.totalStockValue));
    r++;

    add('--- Лояльность ---', '');
    add('Клиентов', loyalty.uniqueClientsCount.toString());
    add('Средний чек/клиент', _money(loyalty.averageCheckPerClient));
    add('Баланс баллов', loyalty.totalPointsBalance.toString());
    add('Потрачено баллов', loyalty.pointsSpent.toString());
    r++;

    add('--- Движение денег ---', '');
    add('Поступления', _money(cashflow.inflow));
    add('Списания', _money(cashflow.outflow));
    add('Списания (брак)', _money(writeoff.totalWriteOffCost));
    add('Итого', _money(cashflow.netCashFlow));

    final bytes = Uint8List.fromList(excel.encode()!);
    final path = await _writeTemp(bytes, 'report_${range.name}.xlsx');
    await _shareFile(path, 'Отчёт (${_periodLabel(range)})', origin);
  }

  static Future<void> _shareFile(String path, String text, Rect origin) async {
    await Share.shareXFiles(
      [XFile(path)],
      text: text,
      sharePositionOrigin: origin,
    );
  }

  static Rect _shareOrigin(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final box = renderBox ?? Overlay.of(context).context.findRenderObject() as RenderBox?;
    return box == null
        ? const Rect.fromLTWH(0, 0, 1, 1)
        : box.localToGlobal(Offset.zero) & (box.size.isEmpty ? const Size(1, 1) : box.size);
  }

  static Future<String> _writeTemp(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static String _money(double value) => '${value.toStringAsFixed(0)} ₽';

  static _ReportData _collect(ReportsService reports, Period period) {
    return _ReportData(
      period: period,
      sales: reports.salesReport(period),
      profit: reports.profitReport(period),
      supply: reports.supplyReport(period),
      writeoff: reports.writeOffReport(period),
      stock: reports.stockReport(),
      loyalty: reports.loyaltyReport(period),
      cashflow: reports.cashflowReport(period),
    );
  }

  static String _periodLabel(ReportRange range) {
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

  static String _rangeDates(Period p) {
    final from = _fmtDate(p.from);
    final to = _fmtDate(p.to);
    return '$from – $to';
  }

  static String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd.$mm.$yyyy';
  }

  static pw.Widget _section(String title, List<pw.Widget> children, pw.TextStyle heading, pw.TextStyle body) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: heading),
          pw.SizedBox(height: 4),
          ...children,
          pw.SizedBox(height: 6),
        ],
      ),
    );
  }

  static pw.Widget _line(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static List<pw.Widget> _sectionWidgets(ReportSection section, _ReportData d, pw.TextStyle heading, pw.TextStyle body) {
    switch (section) {
      case ReportSection.summary:
        return [
          _line('Выручка', _money(d.profit.totalRevenue)),
          _line('Себестоимость', _money(d.profit.totalCost)),
          _line('Прибыль', _money(d.profit.grossProfit)),
          _line('Маржа', '${d.profit.marginPercent.toStringAsFixed(1)}%'),
        ];
      case ReportSection.sales:
        return [
          _line('Продаж', d.sales.salesCount.toString()),
          _line('Средний чек', _money(d.sales.averageCheck)),
          _line('Выручка', _money(d.sales.totalRevenue)),
          if (d.sales.topProducts.isNotEmpty)
            _line('Топ товар', '${d.sales.topProducts.first.name} (${_money(d.sales.topProducts.first.revenue)})'),
        ];
      case ReportSection.supply:
        return [
          _line('Поставок', d.supply.suppliesCount.toString()),
          _line('Сумма', _money(d.supply.totalSupplyCost)),
          if (d.supply.topMaterialsByCost.isNotEmpty)
            _line('Топ материал', '${d.supply.topMaterialsByCost.first.name} (${_money(d.supply.topMaterialsByCost.first.cost)})'),
        ];
      case ReportSection.stock:
        return [
          _line('Позиции', d.stock.itemsCount.toString()),
          _line('Стоимость', _money(d.stock.totalStockValue)),
        ];
      case ReportSection.loyalty:
        return [
          _line('Клиентов', d.loyalty.uniqueClientsCount.toString()),
          _line('Средний чек/клиент', _money(d.loyalty.averageCheckPerClient)),
          _line('Баланс баллов', d.loyalty.totalPointsBalance.toString()),
          _line('Потрачено баллов', d.loyalty.pointsSpent.toString()),
        ];
      case ReportSection.cashflow:
        return [
          _line('Поступления', _money(d.cashflow.inflow)),
          _line('Списания', _money(d.cashflow.outflow)),
          _line('Списания (брак)', _money(d.writeoff.totalWriteOffCost)),
          _line('Итого', _money(d.cashflow.netCashFlow)),
        ];
    }
  }

  static List<(String, String)> _sectionRows(ReportSection section, _ReportData d) {
    switch (section) {
      case ReportSection.summary:
        return [
          ('Выручка', _money(d.profit.totalRevenue)),
          ('Себестоимость', _money(d.profit.totalCost)),
          ('Прибыль', _money(d.profit.grossProfit)),
          ('Маржа', d.profit.marginPercent.toStringAsFixed(1)),
        ];
      case ReportSection.sales:
        return [
          ('Продаж', d.sales.salesCount.toString()),
          ('Средний чек', _money(d.sales.averageCheck)),
          ('Выручка', _money(d.sales.totalRevenue)),
          if (d.sales.topProducts.isNotEmpty)
            ('Топ товар', '${d.sales.topProducts.first.name} (${_money(d.sales.topProducts.first.revenue)})'),
        ].whereType<(String, String)>().toList();
      case ReportSection.supply:
        return [
          ('Поставок', d.supply.suppliesCount.toString()),
          ('Сумма', _money(d.supply.totalSupplyCost)),
          if (d.supply.topMaterialsByCost.isNotEmpty)
            ('Топ материал', '${d.supply.topMaterialsByCost.first.name} (${_money(d.supply.topMaterialsByCost.first.cost)})'),
        ].whereType<(String, String)>().toList();
      case ReportSection.stock:
        return [
          ('Позиции', d.stock.itemsCount.toString()),
          ('Стоимость', _money(d.stock.totalStockValue)),
        ];
      case ReportSection.loyalty:
        return [
          ('Клиентов', d.loyalty.uniqueClientsCount.toString()),
          ('Средний чек/клиент', _money(d.loyalty.averageCheckPerClient)),
          ('Баланс баллов', d.loyalty.totalPointsBalance.toString()),
          ('Потрачено баллов', d.loyalty.pointsSpent.toString()),
        ];
      case ReportSection.cashflow:
        return [
          ('Поступления', _money(d.cashflow.inflow)),
          ('Списания', _money(d.cashflow.outflow)),
          ('Списания (брак)', _money(d.writeoff.totalWriteOffCost)),
          ('Итого', _money(d.cashflow.netCashFlow)),
        ];
    }
  }

  static String _sectionTitle(ReportSection section) {
    switch (section) {
      case ReportSection.summary:
        return 'Итог';
      case ReportSection.sales:
        return 'Продажи';
      case ReportSection.supply:
        return 'Поставки';
      case ReportSection.stock:
        return 'Склад';
      case ReportSection.loyalty:
        return 'Лояльность';
      case ReportSection.cashflow:
        return 'Движение денег';
    }
  }
}

class _ReportData {
  final Period period;
  final SalesReport sales;
  final ProfitReport profit;
  final SupplyReport supply;
  final WriteOffReport writeoff;
  final StockReport stock;
  final LoyaltyReport loyalty;
  final CashflowReport cashflow;

  _ReportData({
    required this.period,
    required this.sales,
    required this.profit,
    required this.supply,
    required this.writeoff,
    required this.stock,
    required this.loyalty,
    required this.cashflow,
  });
}
