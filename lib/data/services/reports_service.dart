import 'package:flutter/foundation.dart';

import '../models/reports.dart';
import '../models/sale.dart';
import '../models/supply.dart';
import '../models/writeoff.dart';
import '../repositories/clients_repo.dart';
import '../repositories/loyalty_repo.dart';
import '../repositories/materials_repo.dart';
import '../repositories/sales_repo.dart';
import '../repositories/showcase_repo.dart';
import '../repositories/supply_repo.dart';
import '../repositories/writeoff_repo.dart';

enum ReportRange { today, week, month, all }

class ReportsService extends ChangeNotifier {
  final SalesRepo salesRepo;
  final SupplyRepository supplyRepo;
  final WriteoffRepository writeoffRepo;
  final MaterialsRepo materialsRepo;
  final ClientsRepo clientsRepo;
  final LoyaltyRepository loyaltyRepo;
  final ShowcaseRepo showcaseRepo;

  ReportsService({
    required this.salesRepo,
    required this.supplyRepo,
    required this.writeoffRepo,
    required this.materialsRepo,
    required this.clientsRepo,
    required this.loyaltyRepo,
    required this.showcaseRepo,
  }) {
    salesRepo.addListener(_onSourceChanged);
    supplyRepo.addListener(_onSourceChanged);
    writeoffRepo.addListener(_onSourceChanged);
    materialsRepo.addListener(_onSourceChanged);
    clientsRepo.addListener(_onSourceChanged);
    loyaltyRepo.addListener(_onSourceChanged);
    showcaseRepo.addListener(_onSourceChanged);
  }

  void _onSourceChanged() => notifyListeners();

  @override
  void dispose() {
    salesRepo.removeListener(_onSourceChanged);
    supplyRepo.removeListener(_onSourceChanged);
    writeoffRepo.removeListener(_onSourceChanged);
    materialsRepo.removeListener(_onSourceChanged);
    clientsRepo.removeListener(_onSourceChanged);
    loyaltyRepo.removeListener(_onSourceChanged);
    showcaseRepo.removeListener(_onSourceChanged);
    super.dispose();
  }

  Period resolvePeriod(ReportRange range, {DateTime? now}) {
    final ts = now ?? DateTime.now();
    final end = DateTime(ts.year, ts.month, ts.day, 23, 59, 59, 999);

    switch (range) {
      case ReportRange.today:
        final start = DateTime(ts.year, ts.month, ts.day);
        return Period(from: start, to: end);
      case ReportRange.week:
        final weekday = ts.weekday; // 1 = Monday
        final start = DateTime(ts.year, ts.month, ts.day).subtract(Duration(days: weekday - 1));
        return Period(from: start, to: end);
      case ReportRange.month:
        final start = DateTime(ts.year, ts.month, 1);
        return Period(from: start, to: end);
      case ReportRange.all:
        return Period(from: DateTime.fromMillisecondsSinceEpoch(0), to: end);
    }
  }

  // ---------------------------------------------------------------------------
  // SALES
  // ---------------------------------------------------------------------------
  SalesReport salesReport(Period period) {
    final periodSales = _salesInPeriod(period);
  final revenue = periodSales.fold<double>(0, (sum, s) => sum + s.total);
  final salesCount = periodSales.length;
  final averageCheck = salesCount == 0 ? 0.0 : revenue / salesCount;

    final Map<String, double> revenueByProduct = {};
    for (final sale in periodSales) {
      revenueByProduct[sale.product.name] =
          (revenueByProduct[sale.product.name] ?? 0) + sale.total;
    }

    final topProducts = revenueByProduct.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    return SalesReport(
      totalRevenue: revenue,
      salesCount: salesCount,
      averageCheck: averageCheck,
      topProducts: topProducts
          .take(5)
          .map((e) => TopProduct(name: e.key, revenue: e.value))
          .toList(),
      breakdownByCategory: topProducts
          .map((e) => CategoryBreakdown(categoryName: e.key, revenue: e.value))
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // PROFIT
  // ---------------------------------------------------------------------------
  ProfitReport profitReport(Period period) {
    final periodSales = _salesInPeriod(period);
    final revenue = periodSales.fold<double>(0, (sum, s) => sum + s.total);
    final cost = periodSales.fold<double>(0, (sum, s) {
      final ingredientsCost = s.ingredients.fold<double>(0, (iSum, ing) => iSum + ing.totalCost);
      return sum + ingredientsCost;
    });
  final gross = revenue - cost;
  final margin = revenue == 0 ? 0.0 : (gross / revenue) * 100;

    return ProfitReport(
      totalRevenue: revenue,
      totalCost: cost,
      grossProfit: gross,
      marginPercent: margin,
    );
  }

  // ---------------------------------------------------------------------------
  // SUPPLIES
  // ---------------------------------------------------------------------------
  SupplyReport supplyReport(Period period) {
    final periodSupplies = _suppliesInPeriod(period);
    final totalCost = periodSupplies.fold<double>(0, (sum, s) => sum + s.totalCost);
    final Map<String, double> costByMaterial = {};

    for (final supply in periodSupplies) {
      for (final item in supply.items) {
        costByMaterial[item.name] =
            (costByMaterial[item.name] ?? 0) + item.totalCost;
      }
    }

    final topMaterials = costByMaterial.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    return SupplyReport(
      totalSupplyCost: totalCost,
      suppliesCount: periodSupplies.length,
      topMaterialsByCost: topMaterials
          .take(5)
          .map((e) => TopMaterial(name: e.key, cost: e.value))
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // WRITEOFF
  // ---------------------------------------------------------------------------
  WriteOffReport writeOffReport(Period period) {
    final periodWriteoffs = _writeoffsInPeriod(period);
    final supplyCost = _suppliesInPeriod(period).fold<double>(0, (sum, s) => sum + s.totalCost);

    double totalWriteOffCost = 0;
    final Map<String, int> reasonCounts = {};

    for (final w in periodWriteoffs) {
      reasonCounts[w.reason] = (reasonCounts[w.reason] ?? 0) + 1;
      totalWriteOffCost += _estimateWriteoffCost(w);
    }

    final breakdown = reasonCounts.entries
        .map((e) => BreakdownItem(name: e.key, value: e.value.toDouble()))
        .toList();

    return WriteOffReport(
      totalWriteOffCost: totalWriteOffCost,
      writeOffPercentFromSupply: supplyCost == 0 ? 0 : (totalWriteOffCost / supplyCost) * 100,
      breakdownByReason: breakdown,
      topWrittenOffMaterials: const [], // not enough data to resolve materials in current model
    );
  }

  double _estimateWriteoffCost(Writeoff writeoff) {
    if (writeoff.costPerUnit != null) {
      return writeoff.costPerUnit! * writeoff.quantity;
    }

    if (writeoff.supplyId == null) return 0;

  final supply = supplyRepo.getById(writeoff.supplyId!);
    if (supply == null || supply.items.isEmpty) return 0;

    final totalQty = supply.items.fold<double>(0, (sum, i) => sum + i.quantity);
    final totalCost = supply.items.fold<double>(0, (sum, i) => sum + i.totalCost);
    if (totalQty == 0) return 0;

    final avgCost = totalCost / totalQty;
    return avgCost * writeoff.quantity;
  }

  // ---------------------------------------------------------------------------
  // STOCK
  // ---------------------------------------------------------------------------
  StockReport stockReport() {
    final mats = materialsRepo.materials;
    final totalValue = mats.fold<double>(0, (sum, m) => sum + m.totalCost);
    final deadStock = mats.where((m) => m.quantity == 0).take(5).map((m) => TopMaterial(name: m.name, cost: m.totalCost)).toList();
    final riskStock = mats.where((m) => m.quantity < 1 && m.quantity > 0).take(5).map((m) => TopMaterial(name: m.name, cost: m.totalCost)).toList();

    return StockReport(
      totalStockValue: totalValue,
      itemsCount: mats.length,
      deadStock: deadStock,
      riskStock: riskStock,
    );
  }

  // ---------------------------------------------------------------------------
  // LOYALTY
  // ---------------------------------------------------------------------------
  LoyaltyReport loyaltyReport(Period period) {
    final periodSales = _salesInPeriod(period);
    final uniqueClients = periodSales.where((s) => s.clientId != null).map((s) => s.clientId!).toSet();
    final revenue = periodSales.fold<double>(0, (sum, s) => sum + s.total);

    final loyaltyData = loyaltyRepo.all;
    final pointsEarned = loyaltyData.fold<int>(0, (sum, l) => sum + l.bonusEarned);
    final pointsSpent = periodSales.fold<int>(0, (sum, s) => sum + s.usedPoints);
    final pointsBalance = loyaltyData.fold<int>(0, (sum, l) => sum + l.currentBalance);

    return LoyaltyReport(
      uniqueClientsCount: uniqueClients.length,
      newClients: 0, // creation date is not tracked in model
      returningClients: uniqueClients.length,
      averageCheckPerClient: uniqueClients.isEmpty ? 0 : revenue / uniqueClients.length,
      pointsEarned: pointsEarned,
      pointsSpent: pointsSpent,
      totalPointsBalance: pointsBalance,
    );
  }

  // ---------------------------------------------------------------------------
  // CASHFLOW
  // ---------------------------------------------------------------------------
  CashflowReport cashflowReport(Period period) {
    final revenue = _salesInPeriod(period).fold<double>(0, (sum, s) => sum + s.total);
    final supplyCost = _suppliesInPeriod(period).fold<double>(0, (sum, s) => sum + s.totalCost);
    final writeOffCost = _writeoffsInPeriod(period).fold<double>(0, (sum, w) => sum + _estimateWriteoffCost(w));

    final inflow = revenue;
    final outflow = supplyCost + writeOffCost;
    return CashflowReport(
      inflow: inflow,
      outflow: outflow,
      netCashFlow: inflow - outflow,
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  List<Sale> _salesInPeriod(Period period) {
    return salesRepo.sales.where((s) => _within(period, s.date)).toList();
  }

  List<Supply> _suppliesInPeriod(Period period) {
    return supplyRepo.supplies.where((s) => _within(period, s.date)).toList();
  }

  List<Writeoff> _writeoffsInPeriod(Period period) {
    return writeoffRepo.writeoffs.where((w) => _within(period, w.writeoffDate)).toList();
  }

  bool _within(Period period, DateTime date) {
    return !date.isBefore(period.from) && !date.isAfter(period.to);
  }
}
