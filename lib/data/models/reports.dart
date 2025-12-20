class Period {
  final DateTime from;
  final DateTime to;
  const Period({required this.from, required this.to});
}

class SalesReport {
  final double totalRevenue;
  final int salesCount;
  final double averageCheck;
  final List<TopProduct> topProducts;
  final List<CategoryBreakdown> breakdownByCategory;
  const SalesReport({
    required this.totalRevenue,
    required this.salesCount,
    required this.averageCheck,
    required this.topProducts,
    required this.breakdownByCategory,
  });
}

class TopProduct {
  final String name;
  final double revenue;
  const TopProduct({required this.name, required this.revenue});
}

class CategoryBreakdown {
  final String categoryName;
  final double revenue;
  const CategoryBreakdown({required this.categoryName, required this.revenue});
}

class ProfitReport {
  final double totalRevenue;
  final double totalCost;
  final double grossProfit;
  final double marginPercent;
  const ProfitReport({
    required this.totalRevenue,
    required this.totalCost,
    required this.grossProfit,
    required this.marginPercent,
  });
}

class SupplyReport {
  final double totalSupplyCost;
  final int suppliesCount;
  final List<TopMaterial> topMaterialsByCost;
  const SupplyReport({
    required this.totalSupplyCost,
    required this.suppliesCount,
    required this.topMaterialsByCost,
  });
}

class TopMaterial {
  final String name;
  final double cost;
  const TopMaterial({required this.name, required this.cost});
}

class WriteOffReport {
  final double totalWriteOffCost;
  final double writeOffPercentFromSupply;
  final List<BreakdownItem> breakdownByReason;
  final List<TopMaterial> topWrittenOffMaterials;
  const WriteOffReport({
    required this.totalWriteOffCost,
    required this.writeOffPercentFromSupply,
    required this.breakdownByReason,
    required this.topWrittenOffMaterials,
  });
}

class BreakdownItem {
  final String name;
  final double value;
  const BreakdownItem({required this.name, required this.value});
}

class StockReport {
  final double totalStockValue;
  final int itemsCount;
  final List<TopMaterial> deadStock;
  final List<TopMaterial> riskStock;
  const StockReport({
    required this.totalStockValue,
    required this.itemsCount,
    required this.deadStock,
    required this.riskStock,
  });
}

class LoyaltyReport {
  final int uniqueClientsCount;
  final int newClients;
  final int returningClients;
  final double averageCheckPerClient;
  final int pointsEarned;
  final int pointsSpent;
  final int totalPointsBalance;
  const LoyaltyReport({
    required this.uniqueClientsCount,
    required this.newClients,
    required this.returningClients,
    required this.averageCheckPerClient,
    required this.pointsEarned,
    required this.pointsSpent,
    required this.totalPointsBalance,
  });
}

class CashflowReport {
  final double inflow;
  final double outflow;
  final double netCashFlow;
  const CashflowReport({
    required this.inflow,
    required this.outflow,
    required this.netCashFlow,
  });
}
